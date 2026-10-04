# Registro de decisiones técnicas

Este registro cubre la base de implementación. No aprueba mecánicas de juego.

- T-028: sustituir fila de barras por previsión temporal de siete sucesos con actores repetidos; considera carga, cola y recuperación, pero no daño ni muertes futuras.
- T-029: aclaración del jugador: movimiento futuro automático, sin aprobar movimiento como acción ni coste ATB. Se retira esa propuesta del documento vigente.
- T-030 RECHAZADA Y REVERTIDA: se había añadido una pantalla de preparación y variantes/Potencia sin que el jugador pidiera ese paso. Se elimina su implementación. Construir las builds corresponde al jugador; no se impone una pantalla previa al encuentro.
- T-031: arranque con carpeta temporal local tras fallo de Temp de Windows; launcher evita duplicar editor. No se deshabilita MCP ni se cambia TEMP global.
- T-032: terreno técnico multidireccional ampliado, cámara en ambos ejes y velocidad de 180 unidades/s; no representa todavía un mapa final.
- T-033: previsión visual cacheada a intervalos de 0,2 s y ante cambios; rutas de perseguidores cacheadas a 0,25 s, con invalidación por desplazamiento y cambio de estado. Campo inmóvil conserva su dibujo. No se certifica una mejora de FPS sin comparación controlada.
- T-034: repositorio Git autorizado por el jugador en Quilik8/VITMORPH, commits descriptivos, CHANGELOG y etiquetas de puntos recuperables; excluir cachés y configuración personal.

| ID | Decisión | Motivo y alcance |
|---|---|---|
| T-001 | La carpeta del proyecto y el nombre del juego son Vitmorph. | Instrucción explícita del usuario; reemplaza los nombres anteriores SYNTHERA y Síntesis Modular como nombre del producto. |
| T-002 | Usar una escena de entrada vacía con raíz `Node2D`. | Proporciona un punto de entrada mínimo sin elegir arena, HUD, cámara o reglas de combate. |
| T-003 | Configurar `gl_compatibility` como renderer. | Busca compatibilidad con el hardware de referencia modesto; no representa una medición ni garantiza 60 FPS. |
| T-004 | Reservar subcarpetas de datos por dominio y mantenerlas vacías. | Conserva la estructura solicitada sin inventar criaturas, habilidades, modificadores o estados. |
| T-005 | Incluir Godot MCP Toolkit 1.0.2 como addon de editor, habilitado en el proyecto. | Petición explícita del usuario para conectar Vitmorph con Godot; el addon no forma parte del juego exportado ni de su lógica. |
| T-006 | Crear `.mcp.json` en la raíz y una única entrada de servidor Godot MCP de Codex dirigida a `D:\Vitmorph`; mantener un solo addon Toolkit en este proyecto. | `.mcp.json` es la receta local del cliente; el addon habilitado en Godot es la instancia del proyecto. No se debe iniciar un segundo editor/servidor para probarlo. |
| T-007 | Limitar la primera fase de pruebas a una bestia principal, sin aliados; probar los comandos Priorizar y Retener, sin Parry. | Alcance confirmado directamente por el usuario el 2 de octubre de 2026. Parry requiere trabajo específico por enemigo y queda fuera de esta fase, no descartado globalmente. |
| T-008 | Reservar para una etapa posterior un equipo de hasta 5 bestias capturadas: 1 principal, hasta 3 aliadas activas y 1 reserva. | El máximo futuro es 4 bestias activas totales. No implementar este sistema de equipo en la primera fase de combate. |
| T-009 | Respetar la semántica aprobada de los comandos: Priorizar prefiere una habilidad cuando sea válida; Retener impide usarla hasta que el jugador la libere. | Definición directa del usuario del 2 de octubre de 2026. La prueba deberá observar estos dos comportamientos. |

## Estado de ejecución

Las decisiones T-002 y T-004 describían la base vacía y quedan superadas por el plan aprobado de la primera prueba. La escena principal ahora usa `Control`; hay motor, IA, datos técnicos, HUD y pruebas aisladas.

- T-010: flujo sin pausa; comandos en la siguiente elección; prioridad persistente y retención con precedencia si coinciden. Decisiones directas del usuario.
- T-011: Priorizar elige la opción priorizada válida, según elección explícita del usuario durante la planificación. No omite comprobaciones.
- T-012: reglas experimentales en `COMBAT_PROTOTYPE.md`, separadas del canon. Defensa como única alternativa válida evita perder la oportunidad cuando aún existe una habilidad legal.
- T-013: motor independiente de presentación, datos e IA; señales para HUD. Theme común, Containers, figuras técnicas y teclado.
- T-014: validación por el MCP existente, sin añadir otro editor ni addon. La ruta posterior no se implementa en esta fase.
- T-015 (3 octubre): tras revisión del jugador, sustituir tarjetas por franja compacta, dos comandos compartidos y detalle de la seleccionada; diagnóstico oculto por defecto. Campo protagonista y feedback sobre los actores.
- T-016 (3 octubre): ampliar la presentación de 1,2 a 4,8 s e impacto de 0,72 a 2,2 s; formación 2D dispersa y animación de ejecución sin cambiar posición lógica. Son valores técnicos ajustables, no balance definitivo.
- T-017 (3 octubre): investigar Chrono Trigger como referencia indicada por el jugador. Mantener iniciativa discreta mientras se concreta la adopción de ATB independiente; no representar feedback de preparación como ATB real.
- T-018 (3 octubre): incorporar la meta explícita de un mundo visible compartido por recorrido y combate, sin pantalla de carga entre ambos, con posiciones enemigas propias del lugar.
- T-019 (3 octubre): prueba de continuidad con tres grupos preexistentes, una escena y un motor; recorrido automático y disparo por proximidad. Sustituido en la iteración 04 por navegación del jugador.
- T-020 (3 octubre): compartir estado del principal entre encuentros y conservar vida/comandos/reutilización, sin curación automática. Reiniciar reconstruye el recorrido. Enemigos de 30 PV/4 daño solo para esta prueba; los escenarios aislados mantienen 100 PV/14 daño.
- T-021 (3 octubre): futuras imágenes de habilidad y efectos se aportarán externamente. Las marcas de comandos y el acceso por teclado deben conservarse al sustituir etiquetas. No generar arte ni solicitar assets todavía.

Se instaló el addon Toolkit v1.0.2 y se alineó el puente `@npgamedev/godot-mcp-server` a v1.0.2. La entrada del plugin está habilitada en `project.godot`; `.mcp.json` y la única entrada global de Codex apuntan a `D:\Vitmorph`. Node 24.14.0 cumple el requisito del puente. El proyecto conserva un solo addon Godot MCP.

Godot 4.7.2 está instalado en `C:\Users\jp_va\AppData\Local\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe`. En la primera comprobación del 2 de octubre de 2026 no había editor abierto ni listener en `127.0.0.1:6550`; el probe devolvió `ECONNREFUSED`. Después se abrió una sola instancia de `D:\Vitmorph\project.godot`; el editor quedó respondiendo, escuchando en `127.0.0.1:6550`, y `project_get_settings` confirmó `application/config/name = Vitmorph`. No se inició un segundo editor ni un segundo addon MCP.

- T-022 (3 octubre): la instrucción del jugador sustituye el recorrido automático por navegación manual y HUD exclusivo del estado de combate. WASD/flechas, persecución del segundo grupo y sus radios son hipótesis técnicas. El campo mantiene tamaño estable al mostrar/ocultar controles.

- T-023: geometría compartida de obstáculos para colisión, detección e inicio de encuentro; movimiento por subpasos de 4 unidades y deslizamiento por eje. Perseguidores rodean volúmenes mediante grafo de visibilidad sobre esquinas expandidas.
- T-024: persecución abandona a más de 500 unidades del grupo o 620 desde origen; retorno sin iniciar encuentros y nueva detección al llegar. Grupo cercano de dos enemigos, perseguidor y grupo separado. Alcances y tiempos de combate se conservan; bloqueo de ataques por terreno y ATB siguen abiertos.

- T-025: exploración de 85 a 180 unidades/s tras crítica de lentitud; persecución enemiga permanece a 65 unidades/s.
- T-026: ATB solicitado por el jugador. Carga 0–100 a velocidad puntos/s, demás bestias cargan durante acciones, FIFO por llegada con desempate estable, una oportunidad acumulada máximo y elección de IA al despachar. Reset de carga al terminar recuperación y al iniciar encuentro. Cooldown por elecciones propias se conserva.
- T-027: franja superior contextual de orden y carga ATB, feedback textual además de color, sin retratos generados. La suite histórica no se reutiliza como certificación del nuevo planificador. Movimiento táctico y bloqueo de ataques siguen pendientes.

- T-035: priorizar rendimiento según CPU medida: reconstrucción del dibujo era dominante (45–52 ms), mundo ~0,25 ms. Separar terreno retenido, reutilizar mallas y redibujar durante animación/cambio. No cambiar reglas ni radios.
- T-036: medidor de CPU optativo y acotado; capturas cortas por estado con baseline 8950783. Documentar medias, p95, picos y limitaciones; no confundir monitor global de fotograma con CPU exclusiva de scripts.

- T-037: precalcular huella y protección; aislar arco de anticipación retenido con uniforme de progreso. Intercambiar ~5,25 KiB de buffers y un nodo por menor CPU de reconstrucción, sin alterar diseño visual.
- T-038: cachear pertenencia a grupos y omitir detección espacial inmóvil solo sin grupos activos; perseguidores/regreso siguen por delta. Los futuros emisores de movimiento/geometría requerirán invalidación.
- T-039: limitar historial reciente y cachés, reciclar feedback sin perder eventos; contador total de acciones independiente. Límites técnicos, no reglas de juego ni certificación de memoria a largo plazo.
- T-040: observar p99/tirones, asignaciones del motor y carga del renderer además de FPS. Corregir etiqueta histórica de cámara mal descrita como persecución; conservar originales y medir persecución real separadamente. No atribuir ahorro GPU o RAM total sin evidencia.
