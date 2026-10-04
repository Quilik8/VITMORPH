# Vitmorph · demo técnica 0.7.0

> Informe histórico del prototipo de sistemas. Tras la revisión del usuario, no se considera la demo final con assets ni una UX aceptada. Alcance posterior: DEMO_SCOPE.md; lista de producción: ASSET_REQUESTS.md. El refugio del prototipo no representa la zona amplia en otra instancia solicitada después.

## Entrega

La demo implementa el ciclo de construir, explorar, combatir, copiar una bestia viva, incorporar sus modulares, resolver el encuentro final y continuar desde disco. El mundo y los encuentros comparten escena. La edición es voluntaria y pausa la exploración; no hay preparación obligatoria antes de combatir.

Ejecutable local: `D:\Vitmorph\dist\Vitmorph.exe`. Instrucciones: [DEMO_GUIDE.md](DEMO_GUIDE.md). Contrato aprobado: [DEMO_IMPLEMENTATION.md](DEMO_IMPLEMENTATION.md). La exportación local se excluye de Git; el repositorio contiene fuentes, preset y evidencia para reproducirla.

## Sistemas entregados

- Catálogo de definiciones Resource separado de colección, builds y estado de ejecución. Identidades de definición, copia, actor y modificador independientes.
- Dos habilidades fijas, dos modulares sin duplicados, ocho ranuras normales y dos especiales representadas sin inventar efectos. Biblioteca compartida y modificador Alcance +30 %, con compatibilidad y contribuciones visibles.
- Editor y colección mediante B/C, aplicación conjunta, comparación contextual, foco de teclado y descarte al cerrar. Cambiar principal o build no cura ni borra reutilizaciones.
- ATB, cola con repeticiones, IA por equipo y orden estable, Priorizar y Retener, reloj compartido, protección, daño periódico y ralentización. Las acciones elegidas conservan su resolución.
- Copia como apoyo que consume la siguiente oportunidad; proceso de 18 segundos durante combate, retirada viva, identidades nuevas y desbloqueos deduplicados. Muerte coincidente impide copiar.
- Guardado seguro JSON versionado, trabajador único, temporal comprobado, respaldo, recuperación de corrupción y bloqueo de sobrescritura incompatible. Antes de cada encuentro se conserva el punto que recupera una batalla interrumpida.
- Refugio dentro del mundo, descanso, derrota con colección conservada, tres encuentros e hitos sin bloqueo artificial del encuentro final.

## Validación automatizada

Las seis suites actuales suman **112 comprobaciones aprobadas**, ejecutadas por MCP en el proyecto y nuevamente dentro del ejecutable exportado. Son pruebas nuevas; las 33 históricas no certifican estos sistemas.

| Suite | Comprobaciones |
|---|---:|
| Catálogo, builds y colección | 20 |
| Reloj, ATB, estados e IA | 24 |
| Copia y retirada | 17 |
| Guardado y recuperación | 25 |
| Recorrido completo | 10 |
| Casos adicionales de integración | 16 |

Resultados: `tests/evidence/demo_final_checks.json` y `export_validation.json`. El recorrido automático usa daño y elecciones reales de la simulación, incluyendo adquisición, uso de una modular nueva, victoria final y restauración; no equivale a una evaluación humana del ritmo.

## Ejecución y revisión visual

Conexión MCP comprobada mediante lectura del nombre del proyecto. Editor único y addon configurado conservados. Se observaron acciones completas, entradas, edición, colección y recuperación en el runtime. Las pruebas controladas de interrupción y derrota están en `demo_live_recovery.json`: recuperar el punto anterior revierte una copia de la batalla interrumpida; resolver una derrota conserva la copia y devuelve al refugio. Después de esa captura se corrigió la limpieza de mensajes/procesos al restaurar; las suites finales comprueban la limpieza de solicitudes pendientes.

Se aplicaron ui-design-core, godot-ui-design y ui-visual-qa, extendiendo el Theme existente. Se revisaron capturas reales del editor, colección, biblioteca vacía y refugio. Tab cambió el foco a Ataque distante y Escape cerró el editor. La biblioteca vacía se provocó únicamente en sesión diagnóstica y luego se restauró el snapshot original. La ventana embebida limitó el tamaño físico: la configuración lógica 1200×820 produjo una captura 1100×751; también se revisó 1018×696 y una composición estrecha 696×752. No se presenta una captura física 1200×820 como obtenida. No se generaron imágenes ni se introdujo arte de canon.

Veinte ciclos de abrir/cerrar los dos editores y cinco regresos al refugio aprobaron el control de estabilidad. Al comparar el mismo tipo de vista hubo 111 nodos en builds y 100 en colección, 58 recursos y cero huérfanos, sin crecimiento sostenido. La memoria gráfica permaneció en 16.963.387 bytes tras calentamiento durante los cinco recorridos. Evidencia: `demo_runtime_cycles.json`. El coste de apertura registrado incluye espera de un frame, no es una medición aislada de CPU.

## Rendimiento

Tres repeticiones por escenario, mismo fixture legado y captura equivalente, antes/después de integrar los sistemas. Se conservó una repetición lenta en lugar de descartarla.

| Escenario | p95 mediano anterior | p95 mediano integrado | Cambio |
|---|---:|---:|---:|
| Reposo | 18,891 ms | 18,819 ms | −0,38 % |
| Acciones | 19,664 ms | 19,177 ms | −2,48 % |

CPU p95 mediana del scope de combate: **0,516 ms** en acciones, incluyendo callbacks síncronos de UI. Una repetición integrada tuvo p95 de 33,055 ms, 27 intervalos mayores de 33,33 ms y uno mayor de 50 ms; las otras tuvieron cuatro y cinco intervalos mayores de 33,33 ms. El baseline también presenta una repetición lenta. No se observa regresión superior al 10 % en la mediana equivalente.

Tres capturas adicionales de 12 segundos del primer encuentro nuevo, con Defensa priorizada y el kit autónomo de Residuo/Freno enemigo, dieron CPU p95 de combate de **0,236 / 0,248 / 0,267 ms**. Los intervalos reales p95 fueron **18,571 / 18,643 / 19,046 ms**; hubo tres/cuatro/cuatro intervalos >33,33 ms y ninguno >50 ms. Se conserva separadamente una captura inicial exploratoria sin la misma prioridad: dos intervalos >50 ms. No hay baseline equivalente de esos kits nuevos; no se atribuye una mejora porcentual a esa serie. Evidencia: `demo_states_performance.json`.

Las llamadas de dibujo aumentaron aproximadamente de 74 a 91 con la nueva UI. Los scopes pueden anidarse y no se suman. Estas capturas son de editor/MCP; no perfilan por separado cada combinación posible de estados ni escenas finales con assets. La memoria del motor no representa RAM total del proceso. No hay medición de tiempo GPU ni garantía de 60 FPS constantes. Evidencia completa: `demo_baseline.json`, `demo_integrated_performance.json` y `performance_comparison.json`.

## Exportación Windows

Editor y plantillas coinciden exactamente en **4.7.2 stable**. Las plantillas anteriores 4.7.1 se conservaron; no se cambió silenciosamente de editor. El preset produce x86_64 con PCK integrado y excluye addon, evidencia y configuración personal.

- Tamaño: **109.733.808 bytes**.
- SHA-256: `05e8e57281d7fc5aa964a770b6dd9352944792c17e1f7ce5867c449e81515412`.
- Paquete: 70 archivos, sin archivos del addon MCP.
- `Vitmorph.exe --headless -- --validate-demo`: salida 0, 112 comprobaciones aprobadas, `mcp_present: false`.

La revisión visual se hizo en el runtime del proyecto. La exportación se validó funcionalmente en ejecución headless; no se afirma una revisión visual independiente de la ventana del ejecutable. Evidencia: `export_templates.json`, `export_pack.json`, `export_validation.json`.

## Recuperación y límites

Puntos del repositorio: `checkpoint-v0.2.0` catálogo/builds; `v0.3.0` editor; `v0.4.0` estados/IA; `v0.5.0` copia; `v0.6.0` guardado/recorrido; `checkpoint-v0.7.0` integración y exportación validada.

Se conserva geometría y contenido técnico provisional. No se implementaron aliados, reservas, Parry, movimiento táctico, economía, progresión extensa ni efectos especiales de las ranuras especiales. Los números son experimentales. La siguiente revisión contigo debe evaluar comprensión de la IA, utilidad de las intervenciones y ritmo del proceso de copia antes de ampliar contenido. Las pruebas técnicas no convierten el balance en canon.
