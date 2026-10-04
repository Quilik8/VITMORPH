# Vitmorph · campo e intervenciones, iteración 02

## Corrección recibida

El jugador valida Priorizar y Retener como prueba funcional. Rechaza el exceso de tarjetas, información permanente, paneles anidados y rapidez. Chrono Trigger pasa a ser una referencia explícita para la experiencia de batalla. Esto no aprueba automáticamente todas sus mecánicas ni altera el límite de un principal.

Revisión posterior del jugador: la iteración 02 fue aprobada como mejora visual sobresaliente de la prueba. Se confirma la meta de mundo compartido por recorrido y combate, posiciones propias de cada lugar y futuras imágenes externas para habilidades. La iteración 03 se describe en `WORLD_CONTINUITY.md`; conserva este HUD compacto.

## Brief aplicado

- Objetivo: seguir la acción y poder intervenir sin apartar continuamente la vista del campo.
- Acción principal: seleccionar una habilidad y priorizar o retener. La IA sigue decidiendo y el flujo no se pausa.
- Jerarquía: combatiente, objetivo, impacto; después estado de comandos; después detalle de la habilidad seleccionada. El registro es diagnóstico.
- Área protegida: el campo ocupa aproximadamente el 73 % de la altura lógica observada. La franja inferior compacta no tiene tarjetas ni descripciones repetidas.
- Estados: selección por subrayado y texto; prioridad/retención visibles incluso en habilidades no seleccionadas; comandos deshabilitados fuera del combate; foco por borde inferior claro; inicio y fin explícitos.
- Entrada: clic en habilidad y comandos; 1–4, P y R como atajos; Tab, Mayús+Tab, Enter y Espacio. F3 abre/cierra detalles sin detener el combate.
- Dirección visual: campo abstracto en tonos de suelo, feedback sobre actores y presentación 2D. Las siluetas geométricas y el suelo son placeholders vectoriales técnicos; no ilustraciones ni arte final.

## Investigación y adaptación

[Square Enix: Chrono Trigger](https://gb.store.square-enix-games.com/chrono-trigger---digital) describe ATB con barras por personaje y posiciones enemigas que cambian con el tiempo. La referencia aporta tiempo activo y relaciones espaciales; no basta con dibujar una barra sobre una cola serial para tener ATB.

[Diseño de HUD para visión periférica, por Robert Tilford](https://www.gamedeveloper.com/design/perceiving-without-looking-designing-huds-for-peripheral-vision) analiza claridad y reconocimiento con menor carga visual. La decisión aplicada aquí es separar feedback de batalla, intervención y diagnóstico. Es una adaptación al proyecto, no una reproducción de un HUD ajeno.

## Implementado en esta iteración

- Campo 2D amplio; formación sin una fila horizontal única. Posiciones lógicas fijas: principal (120,260), cercano (320,150), lejano (620,290). Distancias aproximadas 228,3 y 500,9; permanecen compatibles con los alcances técnicos.
- Selección de habilidad compacta con una pareja de comandos compartida. Efecto y motivo solo de la seleccionada; alcance/reutilización completos en tooltip. Sin rótulos de slots permanentes.
- Registro y próximos actores ocultos en Detalles/F3. Abrirlos no reduce el campo ni pausa.
- Una acción cada 4,8 s: preparación, desplazamiento visual de ejecución, impacto a los 2,2 s, regreso y recuperación. El desplazamiento no modifica posición ni alcance lógicos.
- Flecha sobre objetivo durante la preparación; daño/protección sobre el actor; resultado legible durante dos segundos.
- Priorizar y Retener conservan sus reglas aprobadas. No se añadieron aliados, movimiento táctico, Parry, captura ni modificadores.

## Iteración 06: ATB solicitado e implementado

El jugador pidió construir ATB y una franja superior de orden inspirada en su referencia a Baldur’s Gate. No se copiaron rondas fijas: cada bestia carga de forma independiente, y la franja muestra orden estimado de llegada, carga y estados Cargando/Listo/Actuando/Derrotado. Las barras cargan mientras otra acción se presenta. La franja aparece solo durante combate y no cambia las dimensiones del campo. Los arcos sobre actores continúan siendo preparación visual. Reglas provisionales en ATB_PROTOTYPE.md.

La UI conserva habilidades compactas y comandos compartidos; no se añadieron tarjetas ni imágenes generadas. El jugador evalúa ritmo y claridad antes de añadir movimiento táctico.

## Dirección vigente tras corrección del jugador

La franja superior es una secuencia de siete sucesos con actores repetidos, no una fila de barras por actor. Se conserva campo protagonista, intervención compacta y diagnóstico optativo. La pantalla de preparación fue rechazada y eliminada: explorar y encontrar enemigos no exige abrir un menú previo.
