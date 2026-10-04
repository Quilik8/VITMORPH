# Optimización 0.1.1 — primera pasada medida

## Qué se encontró

La caída principal estaba en reconstruir el dibujo del campo, no en elegir habilidades ni actualizar la navegación. En el estado inicial observado, `_draw` costaba 45–52 ms de CPU por llamada; la actualización del mundo rondaba 0,25 ms. El desglose midió unos 38 ms reconstruyendo el terreno durante el combate. No se atribuyen estos tiempos al coste de GPU.

## Cambios

- Terreno en un CanvasItem separado con comandos de dibujo retenidos. La cámara lo desplaza con su transformación; reconstrucción solo al cambiar mapa, modo o tamaño. El terreno de escenarios aislados también se conserva.
- Siluetas y sombras como mallas trianguladas una sola vez, reutilizadas al dibujar. Contorno de acción precalculado. Se conserva la forma y el color existentes.
- Redibujo del campo solo cuando cambian posiciones/cámara, estado o hay animación/feedback activo. Cargar ATB no reconstruye el campo cada fotograma.
- La previsión adicional del diagnóstico oculto no se calcula; abrirlo actualiza su contenido. La cola visible mantiene su caché y los eventos de combate.
- Medidor optativo de CPU por componente: `systems/performance_probe.gd`, desactivado fuera de una captura. No añade una pantalla ni exige intervención del jugador.

Se mantuvieron velocidad, tiempos, alcance, IA, geometría lógica, comandos y planificador ATB. Se aplaza ampliar la optimización del grafo de rutas: las mediciones actuales no lo señalan como coste dominante.

## Resultados de capturas cortas

Mismo equipo, Godot con editor/MCP, ventana 1018×696. Baseline `8950783`, con instrumentación equivalente. FPS medio = fotogramas / segundos de pared, no el valor puntual del monitor. Reinicio entre estados. Capturas de 4 s, persecución de 2 s.

| Estado | FPS medio antes | FPS medio después de mallas | Dibujo medio antes | Dibujo medio después |
|---|---:|---:|---:|---:|
| Explorar moviéndose | 20,3 | 60,0 | 45,61 ms | 0,153 ms |
| Persecución | 16,7 | 60,0 | 52,45 ms | 0,215 ms |
| Combate, carga inicial ATB | 17,1 | 58,5 | 49,49 ms | 0,709 ms |

La última revisión evitó también redibujar durante carga sin animación. Captura posterior de 8 s durante acciones y comandos P/R: 57,9 FPS medios, p95 de delta 18,06 ms, máximo 58,33 ms; dibujo medio 4,84 ms, máximo 37,16 ms. No existe baseline equivalente de esa ventana de acciones para calcular una mejora porcentual.

Los picos aislados persisten. La media no garantiza ausencia de tirones ni 60 FPS constantes. Las capturas son pequeñas y no representan un mundo final poblado, otras GPU/resoluciones o una exportación. `Performance.TIME_PROCESS` es el monitor global de fotograma y no equivale a CPU exclusiva de nuestros scripts. Los scopes se solapan (p. ej. un texto está dentro del dibujo) y no deben sumarse como tiempos independientes.

## Repetir una observación

Con el MCP conectado y el juego en el estado deseado, llamar `begin(4, "etiqueta")` en `/root/Main/PerformanceProbe`; esperar el intervalo y leer `report()` del mismo nodo. El medidor se detiene solo, limita duración a 30 s y conserva el último informe. No cambia las reglas. Capturas de persecución/combate de esta sesión usaron una posición diagnóstica fijada por MCP para llegar al estado.

Evidencias: `tests/evidence/optimization_v0_1_1.json` y `optimization_combat.png`. Consola sin advertencias/errores en la consulta posterior. Scripts comprobados por MCP. No se ejecutó ni modificó la suite histórica de iniciativa.

## Observación visual

Captura real MCP 1018×696, recuperación del ataque cercano: campo y obstáculos visibles, principal y enemigos con vida, enemigo derrotado atenuado, cola repetida, marca conjunta Prioridad/Retenida y botones Quitar prioridad/Liberar legibles. La cámara ya estaba asentada: la diferencia de encuadre con la captura inicial no es un cambio de posiciones lógicas. Se conserva el diseño aprobado; revisión limitada a esta resolución y a los estados observados, no una certificación responsive completa.

## Siguiente trabajo de rendimiento

Perfilar picos durante arcos de anticipación/protección, impacto, texto y eventos; observar sesiones más largas y mapas con más contenido antes de decidir partición espacial o streaming. Mantener estas decisiones técnicas separadas del diseño de juego.

## Referencia de implementación

Se usaron los mecanismos documentados de [CanvasItem: dibujo retenido, transformaciones y draw_mesh](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) y [ArrayMesh](https://docs.godotengine.org/en/stable/classes/class_arraymesh.html). Las cifras de este informe proceden de nuestras capturas, no de esas referencias.
