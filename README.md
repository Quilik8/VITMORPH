# Vitmorph


Primer prototipo de combate para el videojuego 2D **Vitmorph**, desarrollado con Godot y GDScript. El nombre del juego y del proyecto queda fijado como Vitmorph por la instrucción explícita del usuario.

Recorrido técnico continuo con un principal, cuatro habilidades, Priorizar/Retener y tres grupos de enemigos en distintas posiciones. Caminar y combatir comparten escenario y estado. También se conservan los escenarios de combate aislado. Sin aliados, reserva, Parry, captura, progresión ni modificadores. Figuras y valores provisionales, sin arte generado.

## Abrir el proyecto

Abre `project.godot` con Godot 4.7.2 y pulsa F5. En **Recorrido continuo**, el principal se controla con WASD o flechas desde el inicio. Rodea los obstáculos y acércate a un grupo para comenzar el combate; el segundo grupo se acerca al detectarte y regresa si te alejas antes de la batalla. El HUD de combate aparece solo durante la batalla y se oculta al terminar, recuperando el movimiento tras 2,8 s. No cambia de escena. Selecciona habilidad con 1–4 o clic y usa P para Priorizar / R para Retener durante combate. Detalles/F3 abre el diagnóstico sin pausar. Tab / Mayús+Tab navegan; Enter/Espacio activan. Al terminar puedes Reiniciar. Los encuentros aislados siguen en el selector. Exploración a 180 unidades/s. ATB independiente con franja superior; ejecución de 4,8 s e impacto a 2,2 s. Raíz `Control`, renderer `gl_compatibility`, base lógica 1200×820. No se ha certificado 60 FPS.

## Godot MCP

El proyecto incluye Godot MCP Toolkit 1.0.2 en `addons/godot_mcp_toolkit`, habilitado en `project.godot`, y una configuración local en `.mcp.json`. Codex apunta a este mismo proyecto con el puente `@npgamedev/godot-mcp-server` 1.0.2; Node 24.14.0 cumple su requisito. En la verificación del 2 de octubre de 2026, una sola instancia de Godot quedó abierta y el probe MCP de solo lectura confirmó `application/config/name = Vitmorph` por `127.0.0.1:6550`. Si se cierra el editor, vuelve a abrir este proyecto y reconecta el cliente; no abras otra instancia para duplicar el MCP.

## Documentos del proyecto

- `DESIGN_STATUS.md`: comprensión, decisiones aprobadas, temas abiertos y descartados.
- `ARCHITECTURE.md`: estructura técnica actual y límites de la base.
- `ASSET_REQUESTS.md`: necesidades de arte identificadas hasta ahora.
- `TECHNICAL_DECISIONS.md`: registro breve de decisiones de implementación.
- `COMBAT_PROTOTYPE.md`: guía de juego, valores provisionales y criterios de revisión.
- `VALIDATION.md`: evidencia de reglas, interacción y revisión visual.
- `UI_COMBAT_DIRECTION.md`: crítica recibida, investigación, rediseño de campo/HUD y evolución hacia ATB.
- `WORLD_CONTINUITY.md`: recorrido continuo, posiciones por lugar y límites de esta prueba.

## Fuentes de diseño

- `Sintesis_Modular_Documento_Conceptual_Maestro_v1.0.md`, proporcionado en `C:\Users\jp_va\Downloads`.
- `Biblia_Visual_Bestias_v1.0.docx`, proporcionada en `C:\Users\jp_va\Downloads`.

Las fuentes se consultaron sin modificarlas ni copiarlas al proyecto. El título “Síntesis Modular” que aparece en el documento conceptual es un título de fuente; el nombre vigente del juego/proyecto es **Vitmorph**.

Reglas de la carga activa: `ATB_PROTOTYPE.md`. La suite de 33 comprobaciones conserva evidencia histórica de iniciativa virtual; no certifica este ATB y necesita adaptación antes de volver a ejecutarse.

La pantalla de preparación añadida por el agente fue rechazada y eliminada. Las builds serán armadas por el jugador con un diseño aún pendiente; no se introduce una pantalla previa obligatoria al combate.

## Repositorio y recuperación

[VITMORPH en GitHub](https://github.com/Quilik8/VITMORPH). Historial en `CHANGELOG.md`, decisiones en `DESIGN_STATUS.md` y `TECHNICAL_DECISIONS.md`; recuperación en `VERSIONING.md`.

La pantalla de preparación fue rechazada y eliminada. El jugador construirá sus builds; no se impone un paso antes del encuentro. Navegación técnica en ambos ejes con cámara y terreno ampliado. Rendimiento aún pendiente de perfilado: las optimizaciones actuales reducen cálculos repetidos sin certificar una tasa de FPS.

## Rendimiento

Primera pasada medida: terreno retenido y mallas reutilizadas. Resultados, diagnóstico optativo y límites en [PERFORMANCE.md](PERFORMANCE.md). Punto recuperable de esta pasada: `checkpoint-v0.1.1`.

Investigación para contenido futuro: [ASSET_PERFORMANCE_PLAN.md](ASSET_PERFORMANCE_PLAN.md). Recomendaciones técnicas para recursos, sprites, efectos y sectores; aún no implementadas ni certificadas.
