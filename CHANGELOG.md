# Registro de cambios

## Editor de ensamblaje · 4 octubre 2026

- Sustituida la UI de builds/colección por una superficie centrada en la copia editada: selector integrado, diez anclajes corporales, habilidades debajo, biblioteca y comparación contextual. Conservado Theme cálido; reflow vertical con desplazamiento y foco en ventana estrecha.
- Controlador de borrador común para selección y arrastre nativo: reemplazo, movimiento/intercambio, retiro explícito, cancelación, bloqueo de instancias ocupadas y rechazo de modulares duplicadas. Aplicar/Descartar/Seguir editando al cambiar copia, cerrar o elegir principal.
- Resources de presentación por ID y componente compartido editor/mundo/combate para imágenes, capas y efectos opcionales. Catálogo visual vacío hasta recibir assets; guardado permanece basado en IDs. Referencias inválidas diagnosticadas; efectos temporales limitados y liberados.
- 112 comprobaciones mecánicas vigentes, 22 de ensamblaje, nueve de flujo de editor y once de presentación aprobadas; arrastre y teclado observados mediante MCP. Las 33 comprobaciones históricas no se cuentan.
- Reutilización de controles sin cambios para evitar reconstrucciones completas. Tres pares de apertura/actualización, tres capturas de intervalos, veinte reaperturas y tres pruebas de infraestructura de efectos registrados en tests/evidence. Informe y límites en ASSEMBLY_DELIVERY.md.
- Conservado checkpoint-v0.7.0; este bloque modifica el proyecto, no reexporta el ejecutable anterior. Integración artística real y evaluación del usuario pendientes. Sin imágenes generadas ni ampliación de mapa/refugio/historia.

## Diseño posterior a 0.7.0 · 4 octubre 2026

- Registrada corrección del usuario: refugio grande con personajes, cercano a una ciudad y entrada a otra instancia; historia única sin ramificaciones.
- DEMO_SCOPE.md distingue alcance aprobado, implementación técnica y decisiones pendientes. 0.7.0 se conserva como prototipo de sistemas; la demo con assets y rediseño UI/mapa sigue pendiente.
- ASSET_REQUESTS.md ampliado con inventario por familias, dependencias, fichas de entrega, estados y registro de recepción. Todo el material lo aporta el usuario; cantidades no definidas no se inventan.
- AGENTS.md y documentos de entrada/históricos enlazan las correcciones para continuidad entre sesiones. Cambios documentales; sin modificación de gameplay ni nuevas pruebas.

## 0.7.0 · 4 octubre 2026 · demo técnica integrada

- Cierre de etapas: 0.3.0 editor de builds/colección; 0.4.0 reloj determinista, estados e IA; 0.5.0 copia y retirada viva; 0.6.0 guardado seguro, refugio y recorrido. Cada alcance tiene su etiqueta recuperable en Git.
- Integración: validación de campos de builds, comandos durante acciones, protección frente a daño fuera de batalla, limpieza de procesos al recuperar y avisos de copia/derrota conservados tras ocultar el HUD.
- 112 comprobaciones nuevas aprobadas en proyecto y ejecutable; veinte reaperturas y cinco regresos al refugio sin crecimiento sostenido de nodos/recursos/memoria gráfica tras calentamiento.
- Perfilado equivalente de tres repeticiones por escenario, sin regresión >10 % de la mediana p95; se conserva y documenta una repetición lenta.
- Exportación Windows local con editor/plantillas 4.7.2 exactos, PCK integrado, sin addon ni runtime MCP. Prueba headless de la exportación: salida 0.
- Guía, informe autocontenido, evidencias JSON y capturas en DEMO_GUIDE.md, DEMO_DELIVERY.md y tests/evidence. Revisión visual del runtime del proyecto; ritmo/balance pendientes de evaluación humana. Sin imágenes generadas ni nuevas mecánicas fuera del contrato.

## Diseño posterior a 0.1.2 · 3 de octubre de 2026

- Desarrollo del bloque en BUILD_DESIGN.md: candidatos de intercambio, combinación, comandos e interfaz; skills de diseño aplicadas. Brief sin implementación ni nuevas reglas aprobadas.

- Propuesta de sistemas y dependencias en SYSTEMS_DESIGN.md, con primer bloque candidato de habilidades, builds y compatibilidad.
- Separadas reglas aprobadas de fórmulas, intercambio y política de edición pendientes. Sin cambios de gameplay ni UI.

## Investigación posterior a 0.1.1 · 3 de octubre de 2026

- Documentación oficial consultada sobre carga asíncrona, importación, batching, partículas, visibilidad y Compatibility.
- Propuestas y orden de avance en `ASSET_PERFORMANCE_PLAN.md`; sin cambiar código de juego ni afirmar nuevas mejoras de FPS.

## 0.1.0 · 3 de octubre de 2026 · punto recuperable del prototipo

- Combate automático, Priorizar/Retener, ATB y cola prevista con actores repetidos.
- Exploración del jugador y encuentros en el mismo mundo, sin pantalla de transición.
- Eliminación explícita del menú de preparación, variantes y Potencia añadidos por el agente y rechazados por el jugador.
- Terreno técnico ampliado a x=80…4000, y=80…2000 y cámara en ambos ejes. Movimiento con WASD/flechas y diagonales normalizadas.
- Previsión de cola almacenada y refrescada a 5 Hz o al cambiar el estado.
- Reutilización de rutas perseguidoras por 0,25 s; recalcular ante cambio de modo, destino desplazado o llegada al waypoint.
- Culling vertical además del horizontal para actores del campo.
- Integración Git con Quilik8/VITMORPH; código, decisiones y evidencia versionados.

Este punto no certifica un juego completo ni 60 FPS. Las pruebas antiguas de iniciativa virtual son históricas; el ATB conserva validación de ejecución documentada y casos pendientes. Movimiento de combate y bloqueo de ataques por terreno siguen pendientes.

## 0.1.1 · 3 de octubre de 2026 · optimización de dibujo

- Terreno retenido en capa independiente; seguimiento de cámara por transformación.
- Mallas de figuras/sombras trianguladas una vez y contorno precalculado.
- Invalidación por estado/animación; carga ATB no obliga a reconstruir el campo.
- Perfilado optativo de CPU y capturas comparadas en `PERFORMANCE.md`.
- Capturas cortas: navegación/reposicionamiento de cámara ~60 FPS medios; carga de combate ~59; acciones ~58 con picos aislados pendientes. No garantía para mapas finales.

## 0.1.2 · 3 de octubre de 2026 · CPU, fluidez y memoria acotada

- Mallas retenidas para huella/protección y arco de anticipación independiente; actualizar progreso no reconstruye toda la arena.
- Grupos cacheados; detección espacial omitida solo cuando jugador y grupos están inmóviles. Perseguidores/regreso conservan actualización continua. Colisión de desplazamiento cero evita trabajo.
- Pool de textos flotantes, caché de anchos y registros limitados; contador total de acciones separado de historial reciente.
- Diagnóstico optativo: p95/p99, intervalos reales, tirones, memoria de texturas/buffers/motor, nodos, recursos, objetos y llamadas de dibujo.
- Captura de acciones de 12 s: CPU acumulada del dibujo de arena 2,518 → 0,323 s; p95 real 33,658 → 18,865 ms. Persiste un pico aislado de 50 ms. Coste fijo observado +1 nodo/+3 recursos/+5.376 B de buffers.
- Cinco reinicios sin crecimiento observado en nodos/recursos/objetos/memoria gráfica; no certifica sesiones largas ni ausencia de fugas.
- Corregida etiqueta histórica de persecución: era cámara junto a grupo. Nueva persecución real confirmada separadamente por MCP; sin baseline equivalente.
- Método, evidencia y límites en PERFORMANCE_HEADROOM.md. Diseño y reglas conservados; sin assets nuevos, streaming, movimiento táctico ni pruebas automáticas.

## 0.2.0 · catálogo y builds

Resource de definiciones, biblioteca/colección, identidades y servicio de builds con vista previa, Alcance global y ranuras validadas. Contrato aprobado en DEMO_IMPLEMENTATION.md; baseline tres repeticiones. Suite nueva de 20 casos aislados por MCP.
