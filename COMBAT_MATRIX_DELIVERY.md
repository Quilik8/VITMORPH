# HUD y matrices de combate — entrega técnica

9 octubre 2026. Contrato: COMBAT_MATRIX_DESIGN.md. Esta entrega permite probar composición e interacción; la claridad final se revisará jugando con el usuario.

## Qué cambia

El HUD distribuye cola, campo, intervención y matriz mediante regiones. La matriz ocupa 320 px a la derecha desde 1000 px lógicos; en ventanas menores ocupa 220 px debajo del campo. Bajo 640×640 se cierra conservando progreso y muestra el aviso de tamaño. Los comandos permanecen accesibles. El encuadre cambia la presentación, nunca posiciones del mundo, alcance, detección o ATB.

Los actores del encuentro se presentan en posiciones superiores, inferiores y diagonales. Vida, nombres e intenciones buscan espacio disponible; en el mínimo se abrevia la lectura. La acción actual aparece arriba; el actor muestra «Actuando». Detalles secundarios se consultan por foco/selección. Las herramientas técnicas son optativas, mediante Pruebas/F3.

## Cómo probar

1. Durante combate, elegir objetivo y pulsar **Matriz · prueba**. Para la propia: Pruebas/F3 → matriz del principal.
2. Seleccionar un anillo con ratón o arriba/abajo; girarlo con los botones **Girar** o izquierda/derecha. Las marcas superiores son el destino. Tab recorre controles.
3. Alinear los tres anillos. El mensaje confirma explícitamente que la prueba no tiene efecto de combate.
4. Escape/Cerrar conserva progreso. Cambiar objetivo abre su matriz independiente. Una muerte o retirada elimina la matriz del actor; finalizar elimina todas.
5. Activar el aviso de Parry desde diagnóstico y pulsar Espacio. Solo registra una respuesta visual; conserva foco y progreso. No se producen avisos falsos en partida normal.

Priorizar/Retener mantienen identidad de habilidad, validez y ejecución ya iniciada. La matriz no escribe en el guardado, no cura y no altera daño, defensa, ATB, copia o reutilización.

## Evidencia y pruebas

- `tests/evidence/combat_matrix_regression.json`: nueve suites, **198 comprobaciones aprobadas** (176 anteriores y 22 nuevas). Compilación final limpia con Godot 4.7.2.
- `tests/evidence/combat_matrix_ui_checks.json`: **28 comprobaciones aprobadas** de distribución, progreso, foco, tamaño mínimo y posiciones sin cambios.
- `matrix_mouse_result.json` y `matrix_keyboard_equivalent.json`: giro real con ratón y teclado produce [0,3,5]. Los restantes resultados de entrada registran flechas, Tab, P/R coexistentes, Espacio y Escape con foco devuelto al selector.
- Capturas finales en `tests/evidence/matrix_*.png`: matriz cerrada/abierta, acción enemiga, impacto y aviso. La formación de diagnóstico prueba arriba/abajo/diagonal; no rediseña el mapa.

| Tamaño lógico solicitado | Captura física real | Distribución abierta |
|---|---|---|
| 1200×820 | 1100×751 | Derecha, 320 px lógicos |
| 1018×696 | 1099×752 | Derecha, 320 px lógicos |
| 760×820 | 696×752 | Debajo, 220 px lógicos |
| 640×640 | 752×752 | Debajo, 220 px lógicos |

Las diferencias físicas corresponden a la ventana de juego integrada/escalada por el editor. No se presentan como capturas físicas de 1200×820. Se inspeccionaron píxeles reales y se corrigieron recortes inferiores, orientación de Containers, agrupaciones y colisiones de textos. El mínimo prioriza lectura compacta; no certifica futuras formaciones mayores.

Se comprobó el MCP mediante lectura. El cliente inicial quedó con un puerto -1 obsoleto tras una comprobación del editor; se reconectó con un cliente temporal del mismo Godot MCP Toolkit y protocolo MCP, al mismo editor/addon en 6550. No se desactivó el addon ni se cambió configuración personal. La sesión temporal se cierra al entregar; el cliente habitual puede requerir refrescar la conversación.

## Rendimiento

Fuente íntegra: `tests/evidence/combat_matrix_runtime_performance.json`. Tres pares de capturas continuas de cuatro segundos, calentamiento de 0,5 s, mismo encuentro y fase (incluyen acción, impacto y despacho). Veinte ciclos adicionales de apertura/giro/cierre tras calentamiento. Los scopes anidados se informan individualmente, sin sumarlos.

La medición del motor es asignación interna, no RAM total del proceso. Memoria gráfica son monitores del renderer, no tiempo GPU. Los picos muestreados cada 0,25 s pueden omitir máximos reales. El reporte conserva todos los intervalos y tirones; un promedio de FPS no constituye aceptación.

| Repetición | Intervalo real p95, cerrada / abierta (ms) | CPU motor p95, cerrada / abierta (µs) | Tirones >33,33 ms | Tirones >50 ms |
|---|---|---|---|---|
| 1 | 18,965 / 18,888 | 349 / 373 | 3 / 3 | 2 / 1 |
| 2 | 19,402 / 19,117 | 407 / 334 | 3 / 4 | 1 / 2 |
| 3 | 19,239 / 18,703 | 349 / 370 | 3 / 3 | 2 / 2 |

Mediana del p95: 19,239 → 18,888 ms (−1,82 %); CPU motor 0,349 → 0,370 ms (+6,02 %, inferior a 1 ms). No se detecta regresión >10 % entre estos pares equivalentes. Esta comparación mide el coste de abrir la matriz sobre el HUD actual; no certifica una comparación histórica de HUDs con fases distintas. Los máximos reales alcanzan 64,126 ms cerrada y 58,031 ms abierta: persisten tirones puntuales y no se declara estabilidad absoluta de 60 FPS.

En veinte ciclos: 166 nodos, 74 recursos y cero huérfanos, sin crecimiento; objetos y memoria gráfica permanecen constantes. Apertura CPU p95 0,927 ms. Asignación interna aumenta 33.712 bytes mientras el propio informe acumula muestras; no equivale a una fuga demostrada ni a RAM del proceso. Las métricas de texturas, buffers y renderer completas constan en el JSON.

## Límites y pendientes

La disponibilidad de matrices para todos los actores es diagnóstico. No hay Vulnerabilidad, combos, Parry funcional ni reglas de recompensas/penalización. Antes del puzzle funcional falta cerrar la defensa que rompe y su relación con daño; para la matriz propia falta contrato de combos. Mapa, recuperación de PV, sustitución, assets y exportación pertenecen a otros bloques. No se generaron imágenes; los PNG de evidencia son capturas del juego y los anillos son dibujo técnico.

Las pruebas de entrada/control y geometría no sustituyen la aceptación de claridad del usuario. La partida visible se restaura al terminar diagnóstico; las mediciones usan un perfil aislado.
