# Vitmorph — rendimiento para sprites, efectos y mapas grandes

Investigación: 3 de octubre de 2026. Estado: **PROPUESTA TÉCNICA**, sin adoptar reglas de juego ni implementar estos sistemas. Documentación oficial de Godot consultada; renderer del proyecto confirmado por MCP: `gl_compatibility`. La base medida sigue siendo `checkpoint-v0.1.1` y sus límites están en `PERFORMANCE.md`.

## 1. Cargar contenido mientras se navega

Godot permite pedir recursos mediante `load_threaded_request`, consultar estado y obtenerlos cuando estén listos. Llamar `load_threaded_get` antes de finalizar puede bloquear. [Carga en segundo plano](https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html).

**Propuesta para Vitmorph:** catálogo por zona y referencias compartidas; anticipar carga alrededor del jugador, incluidos sentidos laterales y diagonales. Repartir incorporación de escenas entre fotogramas, conservar recursos usados por zonas vecinas y liberar los que pierdan todas sus referencias. Acotar solicitudes simultáneas y memoria residente. Esto mantiene el mismo mundo y el encuentro en su lugar.

La carga asíncrona no elimina todos los costes: interacción con la escena activa debe respetar el hilo principal; operaciones con imágenes/texturas pueden sincronizar con GPU. Medir carga, instanciación e incorporación por separado. [APIs y threads](https://docs.godotengine.org/en/stable/tutorials/performance/thread_safe_apis.html).

## 2. Evitar tirones de primer uso de efectos

Los mecanismos de ubershaders y precopilación de pipelines no se aplican a Compatibility. Godot documenta para este renderer el uso efectivo de materiales/shaders/partículas durante al menos un fotograma visible para anticipar su compilación. Cargar el archivo por sí solo no equivale a esa operación. [Compilación de shaders](https://docs.godotengine.org/en/stable/tutorials/performance/pipeline_compilations.html).

**Propuesta:** catálogo pequeño de materiales compartidos y comprobar primer uso frente a usos posteriores. Resolver el calentamiento al iniciar o cargar sectores anticipadamente, sin pantalla previa al combate. Un nodo oculto no debe considerarse una garantía de calentamiento. No prometer eliminar todos los tirones: su comportamiento depende también del driver.

## 3. Preparar imágenes según uso real

Lossless conserva calidad y es adecuado como punto de partida para sprites/UI. Lossy reduce archivos, pero no reduce VRAM frente a Lossless. La compresión de VRAM puede producir artefactos visibles en 2D. Los mipmaps añaden alrededor de un tercio de memoria y resultan útiles cuando las imágenes se reducen notablemente en pantalla. [Importación de imágenes](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html).

**Propuesta:** registrar dimensiones, escala visible, número de frames, canal alpha y memoria estimada por asset. Decidir tamaño, compresión, filtro y mipmaps por categoría; no activar una configuración global que degrade la dirección visual. Separar originales de trabajo y recursos de runtime. Dimensionar hojas de animación a su uso.

Ejemplo calculado: una textura RGBA8 sin compresión/mipmaps requiere aproximadamente ancho × alto × 4 bytes: 1024² = 4 MiB; 2048² = 16 MiB. Treinta y dos imágenes de 2048² sumarían unos 512 MiB solo de datos de textura, antes de otros recursos. Un PNG pequeño en disco puede ocupar mucho más una vez usado.

## 4. Sprites y efectos: reducir cambios y superposición

Compartir materiales y texturas favorece el batching. Los atlas pueden reducir cambios de textura. La transparencia superpuesta y los shaders con muchas lecturas aumentan el trabajo por píxel. [Optimización GPU](https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html).

**Propuesta:** atlas por familias que suelen verse juntas, con margen para filtrado; evitar un atlas gigante de todo el juego. Medir el resultado real del batching sin alterar orden de profundidad. Recortar espacio transparente innecesario conservando pivotes. Evitar varias capas de humo/brillo a pantalla completa; compartir shaders y preferir efectos localizados.

## 5. Partículas y reutilización acotada

En `GPUParticles2D`, reducir `amount_ratio` no reduce los recursos procesados de `amount`. Para disminuir coste, hay que dimensionar la cantidad real. También hay restricciones por renderer: `emit_particle` no está disponible en Compatibility. [GPUParticles2D](https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html).

**Propuesta:** comparar efectos de sprite animado, GPU y CPU con contenido representativo. No suponer que una opción es siempre más rápida. Usar una reserva limitada de instancias de efectos frecuentes para reducir creación/destrucción durante impactos; liberar reservas que ya no correspondan a la zona. Esta reserva consume memoria y exige reiniciar emisión, animación, señales y estado al reutilizar.

Definir cantidad de partículas, tamaño en pantalla, duración y efectos concurrentes por categoría. Reducir primero detalles cosméticos cuando haga falta; mantener indicaciones de objetivos, impacto y comandos comprensibles. Son parámetros técnicos pendientes de medición, no límites del diseño de habilidades.

## 6. Mundo grande: separar simulación y presentación

`VisibleOnScreenEnabler2D` puede activar/desactivar el procesamiento de un nodo según visibilidad. Eso afecta su lógica, no solo su dibujo. [Visibilidad y procesamiento](https://docs.godotengine.org/en/stable/classes/class_visibleonscreenenabler2d.html).

**Propuesta:** usar visibilidad para decoración y animaciones ambientales; mantener la simulación necesaria del encuentro aunque un actor salga de cámara. Dividir el mundo en sectores con vecinos precargados, sin cambiar a una escena de combate. Diseñar activación de colisiones y actores con el mapa real.

Para mucha decoración repetida, valorar `MultiMeshInstance2D` por sector. MultiMesh se descarta como conjunto, no por instancia; agrupar todo el mapa perjudicaría el descarte. No sustituir bestias con comportamiento individual por esta técnica por defecto. [MultiMesh](https://docs.godotengine.org/en/stable/classes/class_multimesh.html).

## 7. Medir margen antes de aumentar contenido

Godot expone monitores de memoria de texturas/video, nodos y draw calls. Son datos complementarios; no sustituyen tiempos de CPU/GPU y pueden tener limitaciones de disponibilidad o refresco. [Performance](https://docs.godotengine.org/en/stable/classes/class_performance.html).

**Propuesta inmediata:** ampliar el diagnóstico optativo con memoria, draw calls, p99 y picos, además de p95/media. Para una meta técnica de 60 FPS hay 16,67 ms por fotograma; es necesario observar margen con sprites y FX representativos. Presupuestos concretos se fijarán según hardware objetivo y mediciones, no como números inventados.

Posteriormente comparar primer uso/repetición de efectos y recorrido prolongado entre sectores; comprobar que la memoria se estabiliza al volver. Separar sesiones con editor/MCP de exportación. La revisión actual fue documental y de configuración; no ejecutó esas pruebas ni certificó estas futuras técnicas.

## Orden recomendado

1. Diagnóstico de memoria, dibujo y picos.
2. Catálogo de recursos y política de importación para los primeros assets reales.
3. Carga anticipada acotada y reserva de efectos frecuentes.
4. Integración de un conjunto representativo de sprites/FX, seguido de medición.
5. Sectores de mundo y decoración agrupada cuando exista el mapa mayor.

Mantener Compatibility como base por ahora: Godot lo considera adecuado para 2D y hardware modesto. Comparar otra opción solo si un efecto necesario o mediciones justifican el cambio. [Renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html).
