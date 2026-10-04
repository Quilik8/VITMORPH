# Validación de la primera prueba de combate

## Iteración 06 · exploración rápida y ATB · 3 de octubre de 2026

Probe MCP de solo lectura confirmó Vitmorph. combat_engine, atb_strip y combat_screen pasaron script_check sin diagnósticos. Consola MCP sin errores/advertencias observados. Se mantuvo la instancia de editor configurada. No se añadió ni ejecutó una nueva suite automática; las 33 comprobaciones anteriores son evidencia histórica de iniciativa virtual. El método run_rule_checks devuelve HISTORICAL_SUITE en esta versión para evitar ejecutar accidentalmente esa suite incompatible.

Exploración a 180 unidades/s: D durante 750 ms llevó al principal desde (150,260) a (275,27,260). El tiempo de entrada/ejecución del MCP no representa un benchmark exacto de velocidad.

Se situó al principal en (610,340) mediante MCP para aislar el encuentro cercano. A tiempo de combate 2,83 s se observaron cargas 33,98 para velocidad 12, 28,32 para velocidad 10 y 22,65 para velocidad 8, sin acción pendiente. A 11,52 s el enemigo de velocidad 12 actuaba, el principal estaba listo al 100 % con llegada t=10 y el otro enemigo seguía cargando al 92,17 %. Esto muestra carga independiente durante una ejecución, distinta del arco de preparación.

Mediante 3/P/R se priorizó y retuvo cercano antes de actuar; el principal eligió básico. Tras liberar, una elección posterior usó cercano con motivo Prioridad válida. El historial posterior mostró reutilización coherente por elecciones propias, exclusión del enemigo muerto y Victoria seguida de exploración. Se mantuvo ritmo normal, sin aceleración diagnóstica.

Capturas reales a 1100×751 mostraron franja superior sin paneles con nombres, cargas y estados Cargando/Listo/Actuando; las marcas de comandos convivieron con esta franja. Campo y controles completos. Al observar el estado final se detectó una acción pendiente residual marcada Actuando aunque el combate había terminado; se corrigió limpiando pending al finalizar y se revisó la compilación. No se volvió a observar un final completo después de esa corrección. Capturas: tests/evidence/atb_charging.png y atb_queue.png. Snapshots: atb_runtime.json.

Límites: no se agotaron empates, velocidades extremas, ausencia de habilidades válidas ni deltas grandes con el nuevo planificador. No se certificó rendimiento. Movimiento táctico y bloqueo de ataques por obstáculos no se implementan todavía. El reinicio final restaura exploración, vida y marcas iniciales.

## Iteración 05 · posiciones, obstáculos y persecución limitada · 3 de octubre de 2026

Probe de solo lectura por el MCP confirmó Vitmorph. world_geometry, world_route, world_fixture y arena_view pasaron script_check sin diagnósticos; consola sin errores/advertencias durante la observación. Se revisaron capturas reales a 1100×751. No se agregó ni ejecutó una suite nueva de pruebas.

Con D el principal se detuvo en x=357,79 ante el obstáculo que comienza en x=380, respetando radio corporal de 22 unidades. S/D permitió rodearlo por debajo y W activó el grupo cercano desde (612,84,344,65). El encuentro incluyó dos enemigos, HUD contextual y la misma escena. Tras vencer, quedaron 88 PV y volvió exploración.

Para aislar persecución se colocó el principal mediante MCP en (1100,360), conservando la derrota del primer grupo, y se retiró con A durante 10 s. El grupo pasó a returning, no entró en combate y finalmente recuperó exactamente sus posiciones (1450,380) y (1780,180), con estado idle. Otro posicionamiento diagnóstico en (1140,370), seguido de W, mostró al perseguidor rodeando la parte inferior del obstáculo; la batalla comenzó con posiciones (1211,27,328,99) y (1541,40,192,44). Estas colocaciones son preparación diagnóstica, no una función del jugador.

En un runtime nuevo se aisló el grupo separado situando al principal en (2140,100). Con 3/P y 4/R se priorizó cercano y retuvo distante: el cercano murió y el lejano quedó con 30 PV, con prioridad cercana conservada y distante bloqueado. Tras liberar con R, la siguiente elección del principal fue Ataque distante y la prioridad cercana permaneció. Se mantuvieron 4,8 s por acción y 2,2 s de impacto; no se aceleró el combate.

Capturas: tests/evidence/spatial_obstacles.png y spatial_battle.png. Snapshots: spatial_encounters.json en la misma carpeta. Se reinició la demostración al finalizar para eliminar las colocaciones diagnósticas y dejar exploración desde el inicio.

Límites: rectángulos técnicos, grafo pequeño de esquinas, sin benchmark de rendimiento ni streaming. Los obstáculos bloquean navegación/detección/inicio de encuentro; todavía no bloquean ataques. No se probó toda combinación de rutas, ni se certifican navegación o colisiones definitivas. ATB queda pendiente; se conserva iniciativa discreta. La utilidad y balance de las posiciones requieren evaluación del jugador.

## Iteración 04 · navegación del jugador y HUD contextual · 3 de octubre de 2026

Probe MCP de solo lectura confirmó Vitmorph. Se sustituyó movimiento automático por WASD/flechas y se ocultó el HUD fuera del combate. Los scripts modificados pasaron script_check; la consola MCP no devolvió errores ni advertencias. No se añadió ni ejecutó una nueva suite de tests en esta iteración.

Con input_simulate se observó: principal inmóvil en (150,260) antes de pulsar; D durante 1,5 s lo llevó a (274,85,260); al volver a pulsar alcanzó (511,50,260), activó el primer encuentro y mostró el HUD. A durante combate no movió al principal. 3/P estableció Priorizar cercano. Después de victoria y recuperación regresó al mismo punto con HUD oculto y prioridad conservada.

Al avanzar y soltar D en (1121,51,260), el segundo grupo quedó alertado y siguió acercándose. Sin otra entrada del jugador inició combate con enemigos en (1317,52,331,86) y (1640,07,196,94), frente a sus posiciones originales (1450,380) y (1780,180). Se conservó la misma escena y el motor durante estos estados. Todas estas observaciones usaron el ritmo normal; no se aceleró el diagnóstico.

La revisión visual real a 1100×751 confirmó exploración sin habilidades, comandos, nombres ni barras; combate con controles y feedback. Se reservó espacio vertical en la proyección del campo para evitar que actores en el borde inferior se solapen con los controles, sin cambiar el tamaño del campo al entrar en batalla. Se recapturó después de corregirlo. Evidencia: tests/evidence/player_navigation.json, player_exploration.png y player_combat.png.

Límites: terreno técnico sin obstáculos, persecución sin retirada definitiva, navegación con teclado y cámara horizontal. No se verificaron mando, exportación, streaming ni rendimiento. El comportamiento tras superar los tres grupos conserva exploración en código, pero no se volvió a recorrer toda la ruta en esta iteración. Las etapas de builds/captura/aliados no se implementan todavía.

## Iteración 03 · continuidad de mundo · 3 de octubre de 2026

El jugador aprobó la mejora visual y confirmó la meta de recorrido y combate en el mismo lugar, sin pantalla de carga. Se implementó un recorrido técnico automático de tres zonas en la misma escena, con formaciones distintas y activación por proximidad.

La observación mediante el MCP de Godot siguió un recorrido completo a velocidad normal: 4,8 s por acción, impacto a 2,2 s y desplazamiento a 85 unidades/s. Terminó con tres encuentros superados y 56 PV. Los encuentros comenzaron con 100, 100 y 72 PV respectivamente; no hubo curación entre ellos. La escena y el motor conservaron sus IDs durante ese recorrido (42513466840 y 43285218871). El mundo conservó seis actores, incluidos los enemigos derrotados. Los snapshots registran posiciones diferentes por zona.

En otro recorrido se marcó Ataque cercano como Priorizar y Defensa como Retener mediante 3/P y 2/R. Ambas marcas persistieron hasta completar las tres zonas. Para esta comprobación específica se aceleró temporalmente el runtime a 0,18 s por acción y 1000 unidades/s; no se usa como evidencia del ritmo normal. Después se detuvo y reinició el runtime y se comprobó la restauración de 4,8/2,2/85, vida 100, comandos vacíos y cero encuentros registrados. La demostración quedó funcionando con los valores normales.

Las 33 comprobaciones existentes de combate volvieron a pasar sin fallos. Los scripts revisados no presentaron diagnósticos y la consola del proyecto quedó sin errores después de corregir una asignación de Array sin tipo a la propiedad tipada actors. Se mantiene una única instancia de editor y el MCP configurado.

La revisión de capturas reales a 1100×751 detectó un rótulo de zona superpuesto al nombre enemigo; se retiró del campo, conservando el lugar en la cabecera. La captura posterior muestra recorrido, actores y franja compacta sin ese solapamiento. Evidencia: tests/evidence/world_walk.png, tests/evidence/world_encounter.png y tests/evidence/world_continuity.json. Las imágenes son capturas de ejecución, no arte generado.

Límites: desplazamiento automático provisional, una escena pequeña precargada, iniciativa discreta y posiciones de combate fijas. No se demuestra streaming de un mundo grande ni 60 FPS. La derrota del recorrido no recibió una prueba específica en esta iteración. Las imágenes de habilidades y sus efectos siguen pendientes del arte externo. Detalle de alcance: WORLD_CONTINUITY.md.

## Iteración 02 · 3 de octubre de 2026

El jugador consideró exitosa la prueba de los comandos, pero rechazó la composición, la cantidad de información y la rapidez. La validación técnica anterior no equivalía a aprobación de UI ni de experiencia de combate.

Se rediseñó el campo con formación 2D, feedback sobre actores y franja de habilidades sin tarjetas. Priorizar/Retener usan dos botones compartidos; 1–4/P/R permiten intervenir por teclado. El registro y la cola se ocultan en Detalles/F3. El ritmo pasa a 4,8 s por acción e impacto a 2,2 s, con preparación, ejecución y recuperación.

MCP: una instancia de Godot, probe de solo lectura confirmó Vitmorph, scripts de UI compilados sin diagnósticos y consola sin errores. La suite existente volvió a devolver 33/33, sin fallos, después del cambio de posiciones. En ejecución se comprobaron 3/P/R, marcas simultáneas, F3 y botón Detalles, con `tree_paused: false`. La alternancia preparación/ejecución y el resultado de impacto se observaron en capturas reales a 1100×751.

Las skills personales ui-design-core y godot-ui-design se actualizaron y pasaron `quick_validate.py` con Python 3.14. El primer intento con el runtime de Python incluido falló por ausencia de PyYAML; se usó el Python local que ya lo tenía, sin instalar dependencias.

La superficie de diagnóstico se desplazó debajo del feedback de acción tras observar que al abrirla lo tapaba parcialmente. La selección conserva subrayado y texto sin fondo rectangular persistente. Se observó también la composición completa y el diagnóstico a 1018×696. El campo mide 599 unidades de altura frente a un viewport lógico de 820 (aproximadamente 73 %). Se ajustó la marca del actor para separarla de su barra de vida y el daño flotante para separarlo del nombre. No se ha aprobado el diseño final ni medido 60 FPS.

La referencia y las decisiones pendientes se documentan en `UI_COMBAT_DIRECTION.md`: sigue pendiente concretar ATB real y movimiento enemigo con consecuencias tácticas. El arco de preparación no es una barra de carga independiente. Capturas de esta iteración: `tests/evidence/ui_v2_battle.png` y `tests/evidence/ui_v2_diagnostics.png`; resultado completo de reglas en `tests/evidence/combat_rules_v2.json`.

## Evidencia histórica · 2 de octubre de 2026

Fecha: 2 de octubre de 2026. Proyecto: D:/Vitmorph. Godot 4.7.2, renderer de compatibilidad. Esta validación demuestra comportamiento técnico; la calidad del combate y el balance siguen pendientes de jugarlo contigo.

## Conexión y compilación

El primer probe MCP devolvió ECONNREFUSED porque el editor estaba cerrado. Se abrió una única instancia del proyecto; `project_get_settings` confirmó Vitmorph por el MCP configurado. El runtime tardó en arrancar; tras consultar los logs y volver a comprobar, quedó conectado en el puerto 6570. No se abrió un segundo editor ni se sustituyó el addon.

Los seis scripts del prototipo y sus pruebas pasaron `script_check`, sin diagnósticos de compilación. `scene_get_tree` confirmó la escena principal Main de clase Control.

## Reglas: 33 comprobaciones aprobadas

La suite se ejecutó en el runtime mediante MCP: `execute_code`, scope `/root/Main`, expresión `run_rule_checks()`. Devuelve `passed: true`, `count: 33`, `failures: []`. El resultado completo está en `tests/evidence/combat_rules.json`.

Cobertura: mayor daño válido; prioridad; comandos sin modificar acción elegida; retención con prioridad conservada; liberación; ID desconocido; reutilización y regreso de prioridad; defensa al 40 %; protección no acumulable y consumida por un impacto; alcance; espera sin detener combate; menor vida y desempates; exclusión de muertos; iniciativa estable y acciones consecutivas; terminación, ausencia de acciones posteriores y reinicio completo en los tres escenarios.

## Interacción real y flujo continuo

- Uno contra dos: se activaron Comenzar, Priorizar y Retener por `input_simulate` sobre los botones. La habilidad cercana mostró ambas marcas. Un snapshot confirmó la acción inicial ya resuelta y la siguiente en curso, con ambas marcas conservadas. `tree_paused: false`.
- Se liberó la habilidad mediante el botón mientras el combate seguía; el snapshot confirmó retención vacía y prioridad conservada.
- Uno contra uno lejano: Tab llevó el foco desde Priorizar a Retener y Espacio activó la retención. Otra pulsación de Espacio liberó. Mayús+Tab volvió al botón de prioridad y Enter quitó la prioridad. Snapshots confirmaron los cambios y el avance automático.
- El escenario lejano llegó a Derrota con `running: false`, sin errores. Después se seleccionó el cercano y se pulsó Repetir: vida 100, comandos vacíos, historial vacío y primera elección en curso.
- La consola MCP no devolvió errores ni advertencias del proyecto; el log del juego no devolvió líneas ERROR. Godot sí informó al arrancar de su cambio automático a ANGLE por el soporte OpenGL del controlador gráfico.

## Revisión visual y correcciones

Capturas reales mediante `runtime_screenshot`, ratón/teclado, estados de inicio, combate y final. Se observó inicialmente un recorte del registro y de la ayuda. Se redujeron márgenes, altura de arena y espaciado, se acotó el registro con ScrollContainer y se corrigió la superposición del rótulo técnico con el nombre del principal.

La revisión posterior a 1100×751 confirmó arena, cuatro tarjetas, marcas, motivos, cola, registro y ayuda completos. También se observó una captura de 948×648 con la composición compacta; el ajuste posterior separó el rótulo de arena del nombre del principal. El borde de foco y las marcas textuales se comprobaron en ejecución. Los botones no dependen solo del color.

Capturas conservadas: `tests/evidence/combat_keyboard.png` y `tests/evidence/combat_dual_command.png`. Son screenshots del prototipo, no arte generado.

## Límites

No se certificó 60 FPS ni se realizó un benchmark. No se probaron exportación, mando, dispositivos móviles ni resoluciones extremas. Los escenarios y números son provisionales; no se implementaron las etapas futuras. La revisión de interés táctico, comprensión y ritmo debe hacerse contigo antes de ampliar a builds y captura.

## Iteración 08 — corrección de alcance y punto recuperable (3 octubre 2026)

- Eliminados pantalla/botón de preparación, variantes, Potencia y estado que detenía el recorrido. `has_node("Preparation")` devuelve false por MCP. Las cuatro habilidades técnicas originales permanecen.
- Probe de lectura del MCP confirmó Vitmorph; una sola instancia de editor/addon. Comprobación de sintaxis de arena, pantalla, ruta y franja: válida, sin diagnósticos.
- Entrada S durante 2,2 s llevó al principal a y=648,44 y cámara y=388,44; superó el antiguo límite vertical. Límites técnicos nuevos: x=80..4000, y=80..2000. No es un mapa final poblado.
- Capturas reales de 1018×696 revisadas: exploración sin menú previo ni HUD de combate; encuentro en el mismo campo con cola de siete sucesos y controles compactos.
- Observación de persecución usando posición diagnóstica fijada mediante MCP: contador de rutas de 2 a 16 durante el acercamiento; encuentro iniciado y victoria regresó a travelling con 84 PV. No demuestra todos los casos geométricos.
- Caché de previsión a 0,2 s más invalidación por eventos; rutas a 0,25 s más invalidación por destino/estado/esquina. Campo inmóvil conserva el dibujo. Movimiento y resolución siguen por delta.
- Métricas puntuales antes de la última mejora de dibujo: 16–19 FPS y aproximadamente 57–69 ms de proceso en sesión de editor/runtime con MCP. No hay baseline controlado, no se atribuye una ganancia de FPS ni se garantiza 60 FPS. Perfilado de costes CPU/GPU pendiente.
- Evidencia: `tests/evidence/cleanup_optimization.json`, `world_2d_no_preparation.png`, `event_sequence.png`. No se ejecutó ni amplió la suite automática histórica de iniciativa; sigue sin certificar ATB.
- Punto de recuperación: `checkpoint-v0.1.0`. Alcance: prototipo compilable y observado, con rendimiento aún pendiente de resolver; no versión de lanzamiento.
- Tras reiniciar con la última mejora de dibujo, lectura puntual en exploración inmóvil: 60 FPS / 19,984 ms de proceso. No es una comparación controlada con persecución o combate, ni demuestra la causa de la diferencia. Estado inicial final observado: travelling, 100 PV, comandos vacíos y sin nodo Preparation. Consola MCP sin advertencias/errores en la consulta.

## Iteración 09 — rendimiento medido (3 octubre 2026)

MCP confirmado por lectura de nombre del proyecto. Instrumentación optativa por componente, comparación de capturas antes/después y revisión del render. Detalle autocontenido, método, tiempos y límites en `PERFORMANCE.md`; datos en `tests/evidence/optimization_v0_1_1.json`. No se ejecutó la suite antigua ni se añadieron pruebas automáticas. Cola, P/R y feedback de combate observados con entrada real vía MCP. Punto recuperable: `checkpoint-v0.1.1`.
