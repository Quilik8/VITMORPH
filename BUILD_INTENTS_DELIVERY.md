# Vitmorph · cierre de builds e intenciones

Fecha de cierre: 9 octubre 2026. Contrato aprobado: BUILD_INTENTS_IMPLEMENTATION.md. Entregas A y B publicadas en `dc485aa` y `bc47bd9`; esta entrega completa C. Valores técnicos provisionales, pendientes de valoración jugando.

## Resultado implementado

- Todas las acciones duran 3,8 s, con efecto a los 2,2 s. ATB, oportunidades de reutilización y proceso de copia de 18 s conservan sus reglas.
- Alcance, Potencia y Duración tienen compatibilidad y contribuciones independientes. Vista previa y combate utilizan el mismo cálculo; catálogo inmutable. Básico 18→22, cercano 30→36, alcance básico 400→520, estados 12→18 y 8→12 s. Duración no cambia cadencia ni intensidad.
- Cada copia conserva su build. Migración versionada entrega los mods nuevos una sola vez, conserva colección/principal/builds y rechaza versiones futuras incompatibles.
- IA valora daño aprovechable y únicamente los pulsos adicionales de una extensión. Kits de desgaste, control y presión distribuidos entre los tres encuentros técnicos.
- Enemigos anuncian intención provisional al cargar o esperar en cola. Consulta sin mutaciones; actualización por condiciones y umbral ATB. Al despachar se decide de nuevo. `Prevé` y `Ejecuta` se distinguen; foco/selección muestra objetivo y motivo en el detalle existente.
- Comparaciones contextuales del editor para Potencia/Duración, compatibilidad resaltada y controles conservados. Reutilización acotada de etiquetas evita reconstruir el detalle continuamente.
- Correcciones de presentación: reserva del HUD estrecho, nombres dentro de límites, separación de intención y aviso de acción, abreviación legible de la cola. No cambian posiciones de actores ni reglas de alcance.
- Addon MCP conserva su configuración: se protege la lectura de una preferencia todavía nula durante arranque, evitando convertir `null` a entero. No se deshabilitó el addon ni se versionaron preferencias personales.

## Validación mecánica

Godot 4.7.2, ocho suites, **176 comprobaciones aprobadas**, sin fallos. Resultado completo: `tests/evidence/build_intents_regression.json`. Reproducción: ejecutar Godot con `--headless --path D:/Vitmorph --script res://tests/run_technical_suite.gd`.

Incluye propiedades/exclusiones, catálogo inmutable, redondeo, estados y reaplicación, migración, builds independientes, tres variantes, consulta repetida de intenciones sin mutaciones, cruce de umbral, cola y despacho, muerte/retirada, copia, guardado, recorrido y ensamblaje. Fixtures históricos mantienen sus kits; se actualizó su ritmo común. La prueba del recorrido usa descanso ya existente antes del final, sin alterar daño ocultamente.

## Observación MCP

Probe de lectura, arranque real, consultas, capturas y consola del editor realizados el 9 de octubre. Consola sin errores durante la revisión final. Una sola instancia de editor, addon habilitado. Perfil diagnóstico separado; al terminar se restaura partida, ruta, ventana y procesado original.

El avance controlado desde MCP confirmó: Freno en curso conserva su elección mientras se marca Defensa como priorizada y retenida; a tiempo de acción 2,2 s el principal queda con 94 PV; liberar Retener conserva Priorizar; tras 1,6 s adicionales termina esa acción de 3,8 s y se elige Defensa. Es observación con deltas controlados, no una prueba manual de reflejos. También se observaron tres capturas continuas de cuatro segundos.

Aplicar Potencia y Duración desde las operaciones reales del editor dio `[power_1, duration_1, ...]` en la copia editada, conservando 100 PV. Las revisiones anteriores del 4 de octubre incluyen selección por click_node y teclado; las operaciones equivalentes de arrastre están cubiertas por suite. **No se certifica aquí un arrastre físico completo ni aceptación de UX por el usuario.**

Capturas guardadas en `tests/evidence/`: `build_power.png`, `build_duration.png` (4 octubre), `intents_final_wide.png`, `intents_final_1018.png`, `intents_final_narrow.png` (9 octubre). Se pidió área lógica 1200×820, 1018×696 y 760×820. El editor embebido produjo tamaños físicos distintos según el acople: amplia 1018×696, intermedia 1017×696 y estrecha 645×696 en las últimas capturas (la primera amplia fue 1100×751). No se declara haber capturado exactamente 1200×820 físicos.

## Rendimiento y límites

Evidencias JSON en `tests/evidence/`. Capturas comparativas de CPU del 4 octubre, tres repeticiones equivalentes:

| Medición | Referencia | Resultado | Interpretación |
|---|---:|---:|---|
| Mediana de p95 de apertura editor | 24,536 ms | 19,482 ms | −20,6 % |
| Mediana de p95 de actualización editor | 84,770 ms | 65,531 ms | −22,7 %; todavía existe coste perceptible |
| Mediana de p95 simulación headless | 0,149 ms | 0,217 ms | +45,6 %, +0,068 ms |
| Simulación con estados, p95 mediano | — | 0,236 ms | Caso adicional; sin referencia histórica equivalente |

La regresión porcentual de simulación se **justifica explícitamente** por consulta de intenciones y seguimiento de condiciones/umbrales. Se redujeron copias innecesarias y se evita recalcular elecciones cada fotograma. El coste absoluto observado cumple el objetivo p95 inferior a 1 ms para estos encuentros; no garantiza ese coste en encuentros mayores. La comparación usa motor de `dc485aa` con dependencias actuales y aísla la extensión de intenciones: no equivale a dos binarios históricos completos.

Tres repeticiones de veinte aperturas/cierres: nodos y recursos estabilizados tras calentamiento (140/69; referencia 138/68), cero huérfanos; texturas/buffers sin crecimiento sostenido. El pool incorpora dos nodos acotados. Se conserva el JSON inicial que evidenciaba regresión antes de corregir el detalle. Las pequeñas asignaciones del informe de diagnóstico no son RAM total del proceso.

Capturas continuas MCP del 9 octubre (`build_intents_runtime_performance.json`): p95 real de intervalos 18,730/18,955/18,843 ms; p99 20,360/22,192/19,984 ms; máximos 36,455/36,693/38,225 ms. Tirones >33,33 ms: 1/2/1; >50 ms: 0/0/0. CPU p95 del motor 0,630/0,635/0,686 ms. Nodos/recursos/texturas/buffers permanecieron estables en cada captura. No hay referencia de intervalos renderizados equivalente para calcular regresión de FPS; estos datos no certifican 60 FPS constantes. No se suman scopes anidados ni se presenta memoria del motor como RAM total. Cambios posteriores de ubicación de textos no alteran cálculo de intenciones.

## Alcance pendiente

Se completa el bloque técnico autorizado. La claridad y utilidad definitiva requieren jugarlo contigo. Arte, sonido, demo artística, Parry y otros bloques siguen fuera de esta entrega. No se reexportó el ejecutable 0.7.0: ejecutar el proyecto actual en Godot. No se añadieron nuevas reglas definitivas ni assets generados.
