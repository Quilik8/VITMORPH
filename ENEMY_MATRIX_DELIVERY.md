# Defensa y matriz enemiga — entrega técnica

9 octubre 2026. Autorización: el usuario delegó los valores de ENEMY_MATRIX_PLAN.md y pidió programación. Valores experimentales, no balance definitivo.

## Resultado y acceso

En exploración, abrir **Pruebas/F3 → Defensa y matriz enemiga · ensayo**. El ensayo utiliza una partida temporal aislada; **Pruebas/F3 → Volver a la partida tras ensayo** restaura la sesión y la ventana originales. No empezar desde un combate normal activo. La prueba no sustituye encuentros del recorrido.

Seleccionar el enemigo y abrir **Matriz · prueba**. Ratón selecciona anillo; botones Girar o flechas izquierda/derecha lo rotan; arriba/abajo cambia de anillo. Resolver los tres destinos superiores rompe su defensa durante 12 segundos de combate. Cerrar conserva progreso, el combate continúa. Priorizar/Retener siguen disponibles. Al vencer aparece «ruptura utilizada»: una ruptura por enemigo y encuentro. Reiniciar anillos desde diagnóstico no concede otra ruptura.

El enemigo tiene defensa 20 %. Daño potencial → mitigación → Protección → PV. Ruptura elimina solo esa mitigación, nunca multiplica potencial ni elimina Protección. Básico 18 causa 14 normalmente y 18 durante ruptura; cercano 30 causa 24/30. Pulsos periódicos consultan defensa al ocurrir. Redondeo al entero próximo, mitades hacia arriba. Vencimiento usa la tolerancia de 1 microsegundo del motor para hacer equivalentes deltas particionados y grandes.

La señal de alineación envía una solicitud al motor; este comprueba encuentro, equipo, actor vivo, defensa habilitada y uso previo. No se reescriben impactos procesados. Datos de ruptura permanecen fuera del guardado y desaparecen por muerte, retirada o fin. Matriz propia y aviso Parry conservan diagnóstico sin efectos.

## Código y continuidad

- `systems/damage_resolution.gd`: resolución pura compartida por motor y IA; la estimación periódica respeta vencimiento conocido y cuenta solo beneficio adicional.
- `systems/combat_engine.gd`: ID de encuentro, solicitudes, expiración discreta, desglose de daño y limpieza.
- `ui/combat_screen.gd` y `ui/combat_matrix_view.gd`: ensayo aislado, defensa en objetivo, estado/countdown contextual, foco y señales.
- `ui/matrix_rings.gd`: una malla reutilizada para anillos, marcas y foco; reconstrucción solo al cambiar geometría/selección/progreso. No incorpora assets ni procesamiento continuo propio.
- `ui/arena_view.gd`: estado compacto y caché acotada de colocación de texto invalidada por eventos/encuadre.

Los encuentros normales conservan defensa 0 por defecto. No se migra el esquema de guardado ni se cambian builds, principal, PV o reutilizaciones de la partida real. El ensayo técnico de un enemigo usa 100 PV, velocidad 8 y ataque 8: se redujo el ataque de fixture 14 → 8 únicamente aquí porque desgaste podía quedar en un ciclo prolongado de Defensa. No se alteró el fixture histórico ni se añadió protección contra daño letal.

## Pruebas y resultados

`tests/evidence/enemy_matrix_regression.json`: diez suites, **247 comprobaciones aprobadas**, 198 anteriores y 49 nuevas. Incluyen tabla de daño, redondeo, Protección, solicitudes inválidas/repetidas, cadencia, expiración exacta y particionada, ruptura durante anticipación, ausencia de impacto retroactivo, consultas puras y catálogo inmutable. Suites previas de copia, builds, ATB y guardado pasan.

`tests/evidence/enemy_matrix_ui_checks.json`: **19 comprobaciones aprobadas** en runtime mediante el MCP configurado: solución activa ruptura, foco, comandos, cuatro tamaños, comandos marcados en mínimo, aviso Parry, reapertura, vencimiento y restauración. Probe de lectura confirmó Vitmorph antes de observar; consola final sin errores nuevos. Se mantuvo un editor y addon, sin desactivar MCP.

Entradas reales: `enemy_matrix_native_input.json`, `enemy_matrix_native_commands.json`. Click físico en Girar y flechas completan [0,0,0]; P/R coinciden sobre Cercano y Espacio confirma aviso Parry sin modificar progreso ni foco. Snapshot de impacto: `enemy_matrix_impact_state.json`.

Comparación determinista: misma build, enemigo, defensa y posiciones; resolver al segundo 18 frente a ignorar. Daño adicional real observado antes del segundo 30:

| Variante de diagnóstico | PV enemigo sin / con ruptura al segundo 30 | Resultado sin / con puzzle | Duración sin / con (s) |
|---|---|---|---|
| Presión directa | 53 / 49 | Victoria / Victoria | 68,70 / 68,70 |
| Desgaste | 69 / 63 | Victoria / Victoria | 101,30 / 101,30 |
| Control | 65 / 58 | Victoria / Victoria | 69,35 / 69,35 |

La mejora produce daño verificable, pero no reduce todavía el número de acciones necesarias para ganar en estos casos. No se presenta como mejora de duración demostrada ni balance final. Las variantes usan datos derivados equivalentes como fixtures; no equipan automáticamente builds al jugador ni desbloquean habilidades en su partida.

## Render observado

Capturas corregidas en `tests/evidence/enemy_matrix_*.png`: defensa, resolución, impacto y expiración. Región lateral/inferior; controles esenciales dentro de la ventana. La ampliación gráfica sigue pendiente de assets del usuario; el dibujo de anillos es técnico.

| Lógico solicitado | Captura física final | Archivo |
|---|---|---|
| 1200×820 | 1018×696 | enemy_matrix_solved_wide.png |
| 1018×696 | 1017×696 | enemy_matrix_solved_1018.png |
| 760×820 | 645×696 | enemy_matrix_solved_narrow.png |
| 640×640 | 696×696 | enemy_matrix_solved_minimum.png |

El editor integra y escala su ventana: dimensiones físicas no equivalen a tamaño lógico. Metadata: `enemy_matrix_capture_dimensions.json`. Se corrigió un tooltip de objetivo que podía conservar PV antiguos y se acortó la respuesta del aviso Parry para evitar recorte. La inspección visual fue del render real; no es aceptación humana de comodidad o comprensión.

## Rendimiento

Tres pares de cuatro segundos con calentamiento de 0,5 s, mismo encuentro de dos actores enemigos, fase de anticipación/impacto y presentación; cerrada con defensa activa / abierta y alineada con ruptura. Veinte ciclos adicionales sobre matriz enemiga con ruptura activa y simulación congelada para aislar apertura/cierre. Fuente completa: `enemy_matrix_performance.json`.

| Repetición | Intervalo real p95 cerrada / abierta (ms) | CPU motor p95 (µs) | Tirones >33,33 ms | Tirones >50 ms |
|---|---|---|---|---|
| 1 | 28,543 / 20,809 | 733 / 511 | 5 / 4 | 2 / 2 |
| 2 | 22,503 / 31,033 | 778 / 727 | 8 / 5 | 2 / 3 |
| 3 | 28,750 / 29,019 | 635 / 1518 | 5 / 7 | 2 / 2 |

Mediana del p95 de intervalos: 28,543 → 29,019 ms (+1,67 %), bajo el umbral de regresión del 10 % entre estos pares. Mediana CPU motor: 0,733 → 0,727 ms; una captura abierta alcanza 1,518 ms y no se afirma que todos los casos estén bajo 1 ms. Máximos de intervalos: 87,111 ms cerrada y 109,756 ms abierta. Persisten tirones y variación entre capturas; no se certifican 60 FPS estables.

La primera medición superó el umbral: `enemy_matrix_performance_initial.json`. Después se sustituyeron llamadas de dibujo de anillos por una malla y se cachearon posiciones/medidas de texto. Llamadas de renderer con matriz abierta: pico 143 inicial → 110 final. No sumar scopes anidados ni interpretar esta métrica como tiempo GPU.

Veinte ciclos calentados: 168 nodos, 76 recursos, 2368 objetos y cero huérfanos constantes. Texturas 8.138.249 bytes, buffers 8.609.110 y memoria gráfica 16.747.359 sin crecimiento. Apertura CPU p95 2,753 ms. Asignación interna aumenta 31.840 bytes mientras se acumulan muestras del informe; no demuestra una fuga ni representa RAM total del proceso. Monitores cada 0,25 s pueden omitir picos reales; hay una malla persistente adicional y no se crea una por frame.

## Límites y próximo paso

El ensayo aislado usa fixture sin colección copiable: Copiar se muestra explícitamente deshabilitado; regresiones de copia se verifican en su suite existente. La incorporación de defensa a perfiles reales y su evaluación junto con una captura jugada sigue pendiente antes de extender el recorrido. No se afirma copia funcional de este enemigo de diagnóstico.

Una solicitud con deuda extrema de simulación se rechaza para no aplicar ruptura retroactivamente; el ensayo permite reiniciar anillos mediante diagnóstico para repetir tras recuperar el reloj. No se implementaron combos, matriz propia funcional, Parry funcional, mapa/refugio nuevos, recuperación de PV, sustitución, assets o exportación. No se generaron imágenes. La siguiente evaluación es jugar el ensayo y decidir si la ventana y magnitud hacen útil la intervención.
