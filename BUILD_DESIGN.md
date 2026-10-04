# Vitmorph — diseño de builds e interfaz, revisión 01

3 de octubre de 2026. **Propuesta de diseño, pendiente de revisión.** No cambia el juego ni convierte números de prueba en balance definitivo.

## 1. Qué debe conseguir el jugador

Elegir las dos habilidades modulares y los modificadores de su bestia, comprender su efecto y reconocer después el resultado en combate. Las dos habilidades fijas conservan la identidad de la bestia. La biblioteca reutilizable, ocho ranuras normales, dos especiales y compatibilidad de las ocho leyes ya están aprobadas; las políticas siguientes son candidatas.

La construcción se abre por decisión del jugador. Nunca aparece como paso para iniciar un encuentro. La transición de exploración a combate continúa en el mismo mundo.

## 2. Reglas candidatas de la primera versión

| ID | Candidato | Consecuencia que permite revisar |
|---|---|---|
| B-01 | Editar únicamente fuera de combate | Un encuentro usa una configuración estable; Priorizar/Retener intervienen sobre ella |
| B-02 | Cada habilidad modular puede ocupar una sola ranura de una misma bestia | Evita ambigüedad de reutilización y comandos sobre dos copias idénticas; sigue disponible para otras bestias |
| B-03 | Seleccionar produce una vista previa; Aplicar cambios actualiza la build de forma conjunta | Permite comparar sin modificar accidentalmente el estado real |
| B-04 | Primera prueba: un modificador normal de Alcance, +30 % | Comprueba compatibilidad global y cambios de objetivos válidos con una ley |
| B-05 | Si la habilidad marcada sigue equipada, la marca sigue su identidad aunque cambie de ranura; si sale de la build, se elimina su marca | Los comandos no se transfieren a una habilidad diferente por ocupar la misma posición |

B-01 está consultado al jugador; mientras no responda sigue pendiente. B-02 no se deduce automáticamente de la biblioteca global. B-04 es un valor técnico para comparación, no un mod de catálogo final. Las ocho ranuras aprobadas no implican que debamos inventar ocho modificadores en esta prueba.

### Combinación de modificadores

Propuesta para futuros incrementos porcentuales de una misma propiedad: sumar los porcentajes y aplicar una vez a la base. Ejemplo ilustrativo: +30 % y +20 % producirían +50 %, no +56 %. Ayuda a explicar cada contribución y evita que el orden de equipamiento cambie el resultado. La primera prueba usa solo un modificador.

Transformaciones especiales, valores negativos, topes y relaciones entre leyes siguen pendientes. No utilizar esta fórmula como regla universal de Duración, Afinidad o Propagación: cada propiedad necesita semántica propia. Tampoco crear un límite arbitrario para ocultar problemas de balance.

### Intercambio y estado persistente

Aplicar una build no debe curar, reiniciar el ATB del encuentro ni borrar reutilizaciones para obtener ventajas. Candidato: conservar reutilización pendiente por identidad de habilidad, incluso al desequiparla; reinsertarla no la convierte en recién disponible. El paso de oportunidades propias fuera de la build y el posible efecto sobre estadísticas máximas necesitan definición antes de programar intercambios. Los cambios de ranura no deben alterar el desempate de IA por accidente: se necesita un orden estable explícito.

## 3. Descripción común de habilidades

Separar definición de habilidad, configuración equipada y estado de combate. La biblioteca conserva definiciones; una build referencia identidades. Los valores derivados se calculan sin sobrescribir la definición compartida ni la configuración de otra bestia.

Una habilidad describe: identidad; efecto y magnitud; objetivos; geometría espacial; requisitos de validez; reutilización; propiedades que cada ley puede modificar. Para explicar la build se conserva valor base, contribución aplicada, resultado y motivo de incompatibilidad. La UI consulta estos datos, no calcula sus propias fórmulas.

### Ejemplo verificable de Alcance

| Habilidad técnica actual | Propiedad espacial | Base | Con candidato +30 % |
|---|---|---:|---:|
| Ataque básico | Distancia al objetivo | 400 | 520 |
| Defensa | Objetivo propio | — | Sin cambio; no tiene distancia a un objetivo externo |
| Ataque cercano | Distancia al objetivo | 240 | 312 |
| Ataque distante | Distancia al objetivo | 600 | 780 |

Se aplica una vez a cada habilidad compatible de la bestia. No se vincula el mod normal solo a Ataque cercano. No añade área, objetivos, daño ni velocidad. Otras leyes se incorporarán cuando exista un efecto definido que permita observarlas.

En el escenario aislado lejano la distancia actual es ~500,9. Sin el candidato, Básico no llega y Distante sí; con él, Básico llega y la IA provisional puede elegir sus 18 de daño frente a los 12 de Distante. Cercano continúa inválido: si está priorizado, la prioridad se conserva y se usa una alternativa válida. Este caso distingue una diferencia táctica de una mejora puramente numérica.

La IA actual de mayor daño es una referencia técnica, no la solución final para defensa/control. Su evaluación profunda se diseña con habilidades cuyos resultados no sean comparables solo por daño.

## 4. Brief de interfaz

**Propósito:** decidir un cambio y comprender su efecto. **Acción principal:** equipar y aplicar la configuración. Secundarias: comparar, retirar, cancelar y volver al mundo. Ratón y teclado completos; arrastrar puede añadirse como alternativa, nunca requisito.

Dirección: extender los tonos cálidos, tinta clara, oro de selección, verde de protección, tipografía contenida y subrayados del HUD existente. La bestia y su configuración dan identidad; no añadir vidrio, neón, ornamentos de fantasía genérica ni retratos inventados. El arte externo tendrá un lugar definido cuando llegue, sin generar imágenes ahora.

| Información | Tratamiento | Decisión que sostiene |
|---|---|---|
| Bestia seleccionada y equipo actual | Persistente mientras se edita | Saber a quién se está modificando |
| Dos fijas y dos modulares | Lista alineada, sin cuatro tarjetas descriptivas | Identificar identidad e intercambio posible |
| Ranuras ocupadas y disponibles | Resumen y lista de nombres, vacías discretas | Saber qué está equipado y dónde cabe el cambio |
| Biblioteca | Solo al elegir un reemplazo | Encontrar una habilidad/modificador |
| Compatibilidad y comparación | Una zona contextual compartida | Comprender qué cambiará antes de aplicar |
| Fórmula completa y diagnóstico de IA | Detalle optativo | Explicar una duda sin recargar la primera lectura |

### Composición propuesta

Una única superficie de lectura para proteger contraste sobre el mapa. Jerarquía: encabezado de bestia → configuración equipada → elección contextual → comparación → Aplicar cambios. La superficie protege lectura; sus agrupaciones internas usan espacio, tipografía y separadores, no más fondos.

Zona principal: lista compacta de habilidades/modificadores. Zona contextual: biblioteca **o** detalle/comparación, según la acción; no tres catálogos abiertos a la vez. Dos secciones, Habilidades y Modificadores, permiten ver ocho ranuras normales y dos especiales sin diez cajas vacías permanentes. Las ranuras especiales se identifican, pero sus efectos no se inventan.

Al seleccionar Alcance, la comparación muestra solo lo relevante: «Básico 400 → 520», «Cercano 240 → 312», «Distante 600 → 780» y «Defensa: objetivo propio, sin cambio». Una nota explica aplicación global; no se duplica la descripción completa de las cuatro habilidades.

La composición conserva contexto del mundo en los márgenes. La interfaz no cambia de escena, no carga otra arena y no se abre automáticamente. La vista estrecha usa una zona a la vez con navegación de regreso; no reduce toda la tipografía para encajar dos columnas.

## 5. Estados e interacción

- **Sin cambios:** Aplicar deshabilitado, motivo «Sin cambios»; volver sigue disponible.
- **Vista previa:** resultado etiquetado «Vista previa», cambios localizados y acción Aplicar visible. No reemplazar el resultado real hasta aplicar.
- **Fijas:** identidad visible con texto «Fija»; no parecen intercambiables ni reciben el mismo tratamiento de interacción que las modulares.
- **Biblioteca vacía:** explicar cómo se obtienen modulares mediante copias; no ofrecer un botón que prometa contenido inexistente.
- **Reemplazo:** seleccionar ranura y candidato, comparar; cancelar vuelve a la configuración sin perder foco.
- **Duplicado o requisito inválido:** si se acepta esa regla, explicar junto a la elección; no limitarse a gris o tooltip.
- **Mod sin efecto en ninguna habilidad:** mostrar «No afecta a esta build» y el motivo. No decidir todavía si equiparlo se prohíbe o se permite.
- **Entrada en combate con editor abierto:** candidato compatible con B-01: cerrar la edición, conservar borrador sin aplicar y mostrar HUD de combate; el encuentro usa la build aplicada. El mundo continúa mientras se edita. Esta política y el control del movimiento con el editor abierto requieren aceptación y revisión en ejecución.
- **Foco:** marca clara además de color; Tab/Mayús+Tab, flechas en listas, Enter para seleccionar y Escape para regresar/cerrar. No reutilizar P/R como funciones distintas dentro del editor.

Los cambios derivados se anuncian con texto. No usar verde para toda cifra mayor: más valor no significa siempre mejor decisión. Transiciones discretas comunican selección/aplicación, sin animación ornamental continua.

## 6. Implementación y revisión posterior

Godot actual: raíz Control, Containers, Theme local, base 1200×820, canvas_items, Compatibility. Candidato técnico: componente de build separado del HUD de combate; servicio de valores derivados y borrador independiente; Theme compartido extraído de los valores actuales antes de añadir otro sistema visual.

Containers organizan; no exigen PanelContainers. Actualizar listas/comparación por selección o cambio de build, no por frame. Reutilizar filas visibles, limitar instanciación y posponer virtualización hasta tener un catálogo real que la justifique. Abrir/cerrar debe liberar o reutilizar recursos sin crecimiento de nodos; medir coste de layout, memoria y respuestas de entrada además de FPS.

Antes de integrar reglas: prototipo de interfaz aislado con datos técnicos y estado etiquetado, sin alterar partidas. Inspeccionar render real a base lógica, tamaño observado 1018×696 y ventana estrecha; teclado/foco, biblioteca vacía, compatibilidad parcial y entrada inesperada en combate. Corregir los mayores problemas antes de conectar equipamiento real.

## 7. Estado de revisión y próximas decisiones

Skills leídas y aplicadas al brief: ui-design-core y godot-ui-design. Probe MCP confirmó Vitmorph. ui-visual-qa se usó para observar la composición existente en una captura real 1018×696 de exploración tras encuentros; no se modificó ese estado. La nueva interfaz **no está implementada ni renderizada: STATIC REVIEW ONLY**. La captura actual no certifica la calidad de este diseño futuro.

Para revisar primero: B-01 (momento de edición), B-02 (duplicados), B-04 (prueba de Alcance) y la combinación de modificadores. Después, construir un prototipo visual con los estados anteriores. Propuestas registradas aquí; decisiones aprobadas permanecen en DESIGN_STATUS.md. No se convierte ningún candidato automáticamente en canon.
