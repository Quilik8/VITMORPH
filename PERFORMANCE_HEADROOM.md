# Optimización 0.1.2 — margen para contenido visual

## Resultado y alcance

Se redujo el trabajo CPU del dibujo y de exploración inmóvil; se acotaron registros y cachés. Se amplió el diagnóstico para observar fluidez, memoria gráfica, asignaciones del motor, recursos y nodos. Se conserva el diseño visual y las reglas actuales: navegación continua, ATB, Priorizar/Retener, velocidades, distancias y tiempos. Sin arte generado ni sistemas de juego nuevos.

No se conoce todavía cuántos sprites o efectos finales soportará el equipo. El margen ganado es CPU medido en este prototipo; no es una garantía de GPU, RAM o VRAM para contenido aún inexistente.

## Cambios implementados

- Huella de acción y anillo de protección construidos como mallas una sola vez. Se reutilizan sus buffers.
- Arco de anticipación en un CanvasItem independiente con geometría retenida. Un uniforme de shader revela el progreso sobre el trazo; actualizarlo no reconstruye todos los actores. El shader cubre una banda estrecha, no un rectángulo del tamaño de la pantalla.
- Dibujo de actores invalidado durante desplazamiento visual, impacto, cambios de estado/cámara y texto flotante. La anticipación sin desplazamiento actualiza su propio nodo.
- Pertenencia a grupos almacenada al construir el mundo; omisión de grupos vencidos. Detección espacial solo cuando el principal cambia de posición o hay grupos persiguiendo/regresando. Se conserva el procesamiento continuo de esos grupos, aunque el jugador se quede quieto. Movimiento cero evita cálculos de colisión.
- Reutilización de diccionarios de texto flotante: cuatro disponibles inicialmente, reserva libre limitada a ocho. Un pico puede crear elementos adicionales sin perder eventos; se devuelven al terminar. No es un límite artificial del daño visible.
- Caché de anchos de texto limitada a 256 entradas, invalidada al cambiar fuente o llenarse. La captura no demuestra una mejora individual de este helper; la mejora principal viene de reducir reconstrucciones.
- Historial de acciones limitado a las últimas 256; el contador de acciones del encuentro permanece independiente. Eventos espaciales: últimos 128. Registro de encuentros: últimos 64. El registro visible ya conservaba cinco mensajes.
- Diagnóstico desactivado fuera de capturas, duración máxima 30 s, muestras por scope/frame limitadas a 8192. Añade intervalos reales de fotograma, p50/p95/p99/máximo y conteos de tirones >16,67/>33,33/>50 ms. Monitores de memoria, nodos, recursos, objetos, primitivas y llamadas de dibujo cada 0,25 s. Snapshots exponen tamaños/límites de cachés.

Los límites de historial fueron revisados en código; no se simularon cientos de acciones para certificar sesiones largas. El mundo técnico sigue completo en memoria. Si futuros enemigos patrullan, se teletransportan o cambia la geometría sin mover al jugador, deberán invalidar también la detección espacial.

## Comparación medida

Mismo equipo, Godot 4.7.2 Compatibility, editor/MCP activo, ventana 1018×696. Baseline `64b1aaf` con el mismo diagnóstico ampliado. Reinicio entre capturas; exploración inmóvil/movimiento: 3 s. Combate: posición diagnóstica (530,150), prioridad Defensa, inicio de captura después de 8,5 s, duración 12 s. Flujo normal, sin acelerar ni pausar el combate. Son ventanas únicas, no una media de múltiples ejecuciones.

| Medición | Antes | Después |
|---|---:|---:|
| CPU de mundo, inmóvil, media por actualización | 0,231 ms | 0,059 ms |
| CPU de mundo, moviéndose, media por actualización | 0,269 ms | 0,183 ms |
| Dibujo de arena en acciones, media por llamada | 5,427 ms | 1,287 ms |
| Llamadas a `_draw` de arena en 12 s | 464 | 251 |
| CPU acumulada de ese dibujo en 12 s | 2,518 s | 0,323 s |
| Intervalo de fotograma real p95, acciones | 33,658 ms | 18,865 ms |
| Intervalo real p99, acciones | 35,476 ms | 33,042 ms |
| Intervalo real máximo, acciones | 42,792 ms | 50,034 ms |
| Intervalos >33,33 ms, acciones | 44 | 5 |
| Intervalos >50 ms, acciones | 0 | 1 |
| FPS medio de la ventana de acciones | 49,89 | 58,90 |

CPU acumulada calculada como llamadas × media. Reducción ~87 % para este componente; media por llamada ~76 %. No equivale a un 87 % menos de CPU total del juego. Los scopes están anidados y no deben sumarse.

El p95 mejoró y hubo menos intervalos largos, pero persiste un pico de 50 ms. Los máximos necesitan capturas repetidas para atribuir una causa. Estas ventanas tienen recursos ya usados; no certifican la primera compilación de shader, importación, carga de assets ni exportación.

## Memoria y coste de la reutilización

| Monitor | Antes | Después | Interpretación |
|---|---:|---:|---|
| Nodos, exploración | 50 | 51 | Nodo independiente de anticipación |
| Recursos, exploración | 37 | 40 | Coste fijo observado de geometría/material |
| Nodos huérfanos | 0 | 0 | Lectura observada, no auditoría completa de fugas |
| Texturas, exploración inicial | 6.101.231 B | 6.101.231 B | Sin ahorro atribuido |
| Buffers de dibujo, exploración inicial | 8.549.306 B | 8.554.682 B | +5.376 B (~5,25 KiB) de coste fijo |
| Texturas al terminar acciones | 6.800.281 B | 6.800.281 B | Caché de glifos calentada; mismo valor |
| Llamadas de dibujo del renderer, acciones, rango muestreado | 73–77 | 73–77 | No bajaron; distintas de llamadas CPU a `_draw` |

No se afirma reducción de memoria total: las asignaciones del motor al terminar combate fueron ~64,96 MB antes y ~65,02 MB después, incluyendo diagnóstico, cachés y editor/runtime. `MEMORY_STATIC` no mide la RAM total del proceso Windows. No hay tiempo directo de GPU; los contadores del renderer describen carga, no capacidad disponible de la tarjeta. Picos de memoria muestreados cada 0,25 s pueden omitir picos entre muestras; cero o un monitor retrasado no prueba ausencia de consumo.

Observación fuera de perfilado activo: tras calentamiento y cinco reinicios, nodos 51, recursos 40, objetos 1812, huérfanos 0 y memoria de texturas/buffers permanecieron iguales. Memoria gráfica reportada: 15.355.995 B (~14,64 MiB). Asignaciones del motor: 64.838.678 → 64.844.138 B (+5.460 B). No basta para certificar ausencia de fugas en una sesión larga.

## Corrección de etiqueta y persecución real

Las capturas históricas de rendimiento etiquetadas «persecución» usaron (1150,640): distancia aproximada 397 al enemigo más cercano, mayor que el radio 380. Medían reposicionamiento de cámara cerca del grupo, no persecución. Los datos originales quedan preservados; se corrige su interpretación en `PERFORMANCE.md` y aquí. Las capturas before/after de esta pasada con esa posición tienen la misma limitación.

La captura nueva en (1150,600) sí activó `zone_2: pursuing`, un grupo activo y 20 recálculos de ruta; se observó entrada en batalla. En 2 s: 59,99 FPS, CPU media de mundo 0,288 ms, p95 de intervalo real 18,831 ms y cero intervalos >33,33 ms. No hay una captura anterior equivalente para calcular mejora porcentual de persecución real.

## Evidencia y revisión visual

MCP de lectura confirmó el proyecto. Comprobación de scripts y consulta de consola registradas en `VALIDATION.md`. Capturas reales de anticipación parcial y Defensa con Protección 24 a 1018×696 muestran los trazos retenidos, campo, obstáculos, cola y controles compactos. No se añadieron paneles ni se cambió la composición. No se revisaron todas las resoluciones ni todos los escenarios. No se agregó ni ejecutó una suite automática.

- Datos: `tests/evidence/headroom_v0_1_2.json` (capturas originales, métodos, corrección y límites).
- Capturas: `tests/evidence/headroom_arc.png`, `headroom_guard.png`.
- Versión recuperable: `checkpoint-v0.1.2`.

## Siguiente cuello de botella que medir

Continuar con sesiones más largas y capturas repetidas de picos; después, medir los primeros sprites/efectos reales: memoria importada, compilación inicial, overdraw, llamadas del renderer, cargas y tiempo de GPU cuando esté disponible. La investigación para carga asíncrona, importación, partículas y sectores sigue en `ASSET_PERFORMANCE_PLAN.md`; no se implementó un streaming vacío ni se eligieron presupuestos definitivos sin assets.
