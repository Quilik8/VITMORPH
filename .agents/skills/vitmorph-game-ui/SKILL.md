---
name: vitmorph-game-ui
description: Diseñar y revisar interfaces de Vitmorph en Godot, especialmente ensamblaje de bestias, colección, habilidades, mods y HUD de combate. Aplicar en cambios de UI/UX del proyecto Vitmorph; no activa trabajo de gameplay ajeno a la interfaz.
---

# Vitmorph · UI de videojuegos

## Vinculación con el proyecto

Esta es la capa de producto de Vitmorph. Su fuente versionada está en `.agents/skills/vitmorph-game-ui`; una instalación personal puede apuntar a esa carpeta. Resolver la raíz desde el workspace activo, sin deducirla de la ruta de instalación personal. Comprobar identidad con `project.godot` y `AGENTS.md` antes de editar. Fuera de Vitmorph, no aplicar sus reglas por analogía.

Antes de un trabajo sustancial, leer las secciones relevantes de `DEMO_SCOPE.md`, `BUILD_DESIGN.md`, `ASSET_REQUESTS.md` y `GAME_UI_RESEARCH.md` de esa raíz. Las instrucciones actuales del usuario prevalecen; los documentos distinguen decisiones, propuestas y rechazos. No inventar reglas para resolver contradicciones documentales.

Usar `ui-design-core` para objetivo y jerarquía, `godot-ui-design` para Controls/Theme/foco y `ui-visual-qa` para render cuando estén disponibles. Esta skill añade experiencia de juego.

## Diseñar antes de implementar

- Precisar qué hace y qué debe comprender el jugador, qué objeto domina la pantalla y qué cambia al actuar. Para ensamblaje: **esta copia → esta mejora → este destino → este resultado**.
- Distinguir editor pausado, biblioteca y HUD de combate. El editor permite inspección; el HUD permite observar batalla y sucesos sin presentar un formulario de construcción.
- Revisar captura vigente y rechazo del usuario. La composición de octubre de 2026 está rechazada; sus pruebas técnicas no son aprobación de UX.
- Explicar el cambio estructural: primera lectura, relación biblioteca/destino, comparación y feedback. Recolorear, cambiar cuadrados por círculos o trasladar las mismas filas no basta.
- Extender el Theme del proyecto. La dirección cálida es antecedente; no inventar un canon artístico. Dar identidad mediante bestias, mejoras, siluetas, materiales y relaciones.

Para editor, colección y equipamiento, leer [references/assembly.md](references/assembly.md). Para HUD, leer [references/combat.md](references/combat.md). Para referencias o evaluación de propuestas importantes, leer [references/review.md](references/review.md).

Los puzzles de Vitmorph son matrices manipulables **durante combate**, nunca interacciones de exploración. Reservar una región contextual que conviva con campo, comandos y aviso de defensa activa sin robar foco. La prueba autorizada en COMBAT_MATRIX_DESIGN.md no concede efectos de Vulnerabilidad, combos o Parry funcional; sus contratos mecánicos siguen pendientes.

Actualización posterior: ENEMY_MATRIX_PLAN.md autoriza el ensayo de matriz enemiga que rompe defensa. Consultar ese contrato y ENEMY_MATRIX_DELIVERY.md; distinguirlo de la matriz propia sin efecto y del aviso Parry de diagnóstico. No extender la defensa a todo el recorrido ni convertir parámetros experimentales en canon.

## Composición y objetos

La bestia debe ser protagonista perceptiva, además de estar centrada en coordenadas. Las piezas se reconocen antes de leer todos sus nombres. Integrar selección, destinos y cambios sin exigir comparar zonas fuera de vista. Usar imágenes con texto accesible; un icono mudo no debe exigir memorizar su efecto.

Elegir geometría por función: cuadrículas para comparar, contornos para seleccionar, espacio y separadores para agrupar. No convertir cada grupo en panel ni tratar círculos como cura universal. El ornamento puede dar identidad si deja claras decisiones y estados.

Mostrar identidad, configuración y consecuencia pertinente primero; descripciones extensas y fórmulas son detalle contextual. Compatibilidad, propietaria y efecto necesarios para decidir permanecen accesibles. Evitar comparaciones sin cambio y diagnósticos permanentes sin utilidad para el jugador.

## Assets y feedback

Todos los assets los proporciona el usuario; no generar imágenes. Preparar recursos por ID, variantes de editor/mundo y anclajes sin mezclar arte, reglas y builds mutables. Assets ausentes conservan nombre y representación técnica identificable; no excusan confusión.

Diseñar seleccionar/arrastrar → destino válido o rechazo → vista previa → montaje → aplicado. Efectos opcionales confirman eventos sin alterar daño, compatibilidad o tiempos mecánicos. Evitar animaciones que bloqueen repetidamente la edición; capas estáticas sin proceso continuo.

## Evidencia y cierre

Usar el MCP configurado para render, input y diagnóstico relevantes, con probe de lectura previo. No exigir runtime para cambios exclusivamente documentales ni presentar código como visual QA.

Comparar rediseños sustanciales con el render rechazado y recorrer tareas completas con ratón y teclado, incluyendo ventana estrecha. Corregir antes de ampliar. Registrar dimensiones físicas, estado de assets y límites; no inventar tiempos de aprendizaje o aceptación humana.

Separar **reglas verificadas**, **UX observada** y **aceptación del usuario pendiente o recibida**. Registrar resultados y CHANGELOG. La skill guía trabajo futuro; no aprueba el siguiente diseño ni autoriza nuevas mecánicas.
