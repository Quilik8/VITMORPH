> Actualización de demo · 4 de octubre de 2026: contrato vigente en DEMO_IMPLEMENTATION.md, uso en DEMO_GUIDE.md y evidencia en DEMO_DELIVERY.md. Este documento conserva el antecedente; las restricciones superadas no describen la demo actual.

# Arquitectura del prototipo de combate

## Ensamblaje actual

El editor usa systems/build_draft.gd para estado de borrador y operaciones validadas. ui/assembly_item.gd adapta selección/arrastre nativo; ui/build_editor.gd compone selector, cuerpo, biblioteca y decisiones. data/visual_asset.gd y visual_library.tres definen presentación sin estado de colección; systems/visual_catalog.gd verifica referencias y ui/beast_visual.gd presenta borrador o build aplicada en editor/arena. Eventos de combate disparan efectos opcionales. Detalle y contratos de ingesta en ASSEMBLY_DELIVERY.md.

## Flujo

scenes/main.tscn contiene un Control raíz con ui/combat_screen.gd. La pantalla crea el HUD mediante Containers, un Theme común y un único nodo Combat. El motor no conoce los botones ni la presentación.

- data/combat_fixture.gd: escenarios y valores técnicos provisionales. Dos habilidades fijas y dos modulares.
- data/world_fixture.gd: tres lugares técnicos, posiciones por lugar y valores de enemigos exclusivos del recorrido.
- systems/combat_ai.gd: validez, objetivo y selección determinista; no modifica estado.
- systems/combat_engine.gd: vida, protección, reutilización, iniciativa, comandos, acción pendiente y finalización.
- systems/world_route.gd: aproximación, encuentros por proximidad y continuación sobre un único mundo persistente. Mantiene el mismo Dictionary del principal y todos los grupos existentes.
- ui/combat_screen.gd: escenario, selección compacta de habilidad y dos comandos compartidos; cola y registro en diagnóstico opcional. No hay tarjetas ni paneles anidados en el HUD persistente.
- ui/arena_view.gd: campo 2D vectorial técnico, formación dispersa, preparación, objetivo, acercamiento visual e impacto. No utiliza imágenes generadas.
- tests/combat_rules.gd: suite aislada de reglas ejecutable dentro del runtime por MCP.

## Interfaces

start(scenario) reinicia el combate. command(kind, skill_id) admite priority o retain; ID vacío quita la marca. IDs desconocidos no alteran comandos. snapshot() devuelve una copia del estado. No hay API de pausa.

begin_encounter(participants) recibe referencias a actores existentes; no crea otro principal. Conserva vida, protección, elecciones/reutilización y comandos; reinicia la carga ATB de los participantes. WorldRoute crea los actores una vez por recorrido, mueve al principal fuera de encuentros y llama al motor al entrar en el radio del grupo. Tras victoria vuelve a moverlo; tras derrota detiene el recorrido.

ArenaView proyecta coordenadas del mundo con camera_x y el mismo HUD. No se cambia escena, cámara ni campo al comenzar un encuentro. Los snapshots de la pantalla incluyen la identidad de escena/motor y el estado del recorrido para comprobar continuidad. El suelo y los actores ajenos al grupo no desaparecen al combatir.

El motor emite state_changed, action_chosen, action_executed, damage_applied, combat_finished y message. La elección copia la habilidad y fija el objetivo antes del efecto. Cambios posteriores se usan en la próxima elección.

Una oportunidad aumenta el contador propio. Una habilidad usada en N con reutilización C vuelve en N+C+1; la reutilización avanza con oportunidades propias, incluida una espera. La programación usa carga ATB independiente y cola de actores listos, distinta de los 4,8 segundos de presentación y del impacto a 2,2 s. El ATB se carga en tiempo real; la reutilización sigue avanzando por oportunidades propias. Los arcos de preparación son feedback de ejecución, no ATB.

Las marcas y disponibilidad se actualizan por señales; la animación breve y la fase de acción requieren trabajo por frame. El Theme conserva foco y estados textuales. El desplazamiento de ejecución no modifica posiciones lógicas ni alcance.

## Límites

Un principal, sin aliados, reserva, Parry, captura, progresión ni movimiento táctico. La exploración usa WASD/flechas; world_route controla movimiento, detección, persecución provisional y regreso desde combate. El HUD se muestra únicamente durante la batalla. No hay menú previo de preparación. El sistema para que el jugador arme builds está pendiente de diseño. Renderer gl_compatibility y stretch canvas_items, base lógica 1200×820. El mundo completo de esta prueba está en memoria; no hay streaming de áreas grandes.

El único addon MCP se conserva. El editor y su runtime se usan para evidencia; el juego no llama al MCP para resolver el combate. La configuración de herramientas sigue en .mcp.json.

`systems/world_geometry.gd` concentra segmentos visibles, colisión por radio y rutas por esquinas. `world_route.gd` aplica la geometría tanto al principal como a perseguidores y controla sus estados idle/pursuing/returning. Los obstáculos se declaran en world_fixture y arena_view dibuja el mismo volumen utilizado en la lógica. No modifica combat_ai ni la validez de ataques.

`ui/atb_strip.gd` dibuja siete sucesos desde forecast, con actores repetidos. La simulación temporal no altera actores y no predice daño ni muertes. Los tiempos de llegada resuelven cola y empates; cada bestia acumula solo una oportunidad pendiente. La IA decide al despachar esa oportunidad.

## Cachés y terreno técnico ampliado

La franja cachea la previsión temporal durante 0,2 s, con invalidación por cambios de combate. Cada perseguidor conserva waypoint, destino, modo y edad durante un máximo de 0,25 s; invalida antes si cambia el modo/destino o llega a una esquina. Esto no añade decisiones de movimiento en combate.

La cámara sigue x/y; actores fuera del campo se omiten del dibujo. En exploración inmóvil, el dibujo se conserva hasta cambio de posiciones/cámara, feedback o tamaño. No existe estado ni nodo de preparación. Los mapas grandes definitivos, streaming y planificación de movimiento automático en combate requieren una fase posterior.

## Dibujo retenido y perfilado

`ui/world_ground.gd` dibuja el terreno detrás de los actores y conserva comandos hasta cambiar mapa/modo/tamaño. Movimiento de cámara mediante posición del nodo. `arena_view.gd` reutiliza mallas de siluetas/sombras y redibuja actores con feedback o animación. `WorldRoute.world_rebuilt` invalida el terreno al reconstruir el recorrido.

`systems/performance_probe.gd` es diagnóstico optativo compartido por nodos; inactivo normalmente. Captura CPU por scope y deltas de frame, sin sumar scopes anidados ni atribuirles GPU. Ver `PERFORMANCE.md`.

## Reutilización y límites 0.1.2

`stroke_mesh.gd` construye trazos una vez. Huella/protección son buffers retenidos; `anticipation_arc.gd` usa un CanvasItem independiente y shader sobre geometría estrecha. La fracción cambia sin reconstruir la arena. El pool recicla diccionarios de feedback; reserva libre máxima ocho, sin descartar impactos. Caché de anchos de texto: 256 entradas.

WorldRoute almacena referencias de grupos al reconstruir el mundo y omite detección si el jugador no cambió de posición y no hay persecución/regreso activo. Futuras patrullas, teletransportes o cambios geométricos deberán invalidar ese criterio. Registros de acciones/eventos/encuentros limitados a 256/128/64, respectivamente; `action_count` conserva el total del encuentro.

PerformanceProbe añade intervalos reales, p99, conteos de tirones y monitores cada 0,25 s. Los scopes se solapan; memoria del motor no es RAM del proceso ni los monitores representan tiempo GPU. Método y evidencia en PERFORMANCE_HEADROOM.md.
