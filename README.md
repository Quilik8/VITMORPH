# Vitmorph

## Estado y documentos para continuar

Estamos construyendo los sistemas de una demo que incorporará assets aportados por el usuario. 0.7.0 es el prototipo técnico recuperable. La UI de builds/colección y el primer mapa requieren replanteamiento. El refugio será grande, con personajes y acceso a otra instancia; historia única sin ramificaciones.

Leer primero [DEMO_SCOPE.md](DEMO_SCOPE.md) y [ASSET_REQUESTS.md](ASSET_REQUESTS.md). El primero registra las correcciones vigentes y los pendientes; el segundo contiene inventario de assets, fichas de entrega, estados y registro de recepción. Los apartados siguientes describen la base técnica existente.


Primer prototipo de combate para el videojuego 2D **Vitmorph**, desarrollado con Godot y GDScript. El nombre del juego y del proyecto queda fijado como Vitmorph por la instrucción explícita del usuario.

Demo técnica jugable con el ciclo **build → explorar → combatir → copiar → incorporar modulares → encuentro final → guardar y continuar**. Un solo principal, mundo continuo multidireccional, ATB y Priorizar/Retener. Figuras y valores provisionales; sin imágenes generadas.

## Jugar

Ejecuta `dist/Vitmorph.exe` o abre `project.godot` con Godot **4.7.2** y pulsa F5. La exportación local usa plantillas oficiales de esa misma versión.
WASD/flechas: explorar. B: builds. C: colección. E: descansar en refugio. En batalla: 1–4, P, R y X para solicitar copia del objetivo seleccionado. Tab/Mayús+Tab/flechas/Enter/Escape: interfaz.
El editor es voluntario y pausa únicamente exploración; no hay pantalla de preparación ni cambio de escena al combatir.

Guía completa: [DEMO_GUIDE.md](DEMO_GUIDE.md). Contrato aprobado: [DEMO_IMPLEMENTATION.md](DEMO_IMPLEMENTATION.md). Evidencia y límites: [DEMO_DELIVERY.md](DEMO_DELIVERY.md).

## Godot MCP

El proyecto incluye Godot MCP Toolkit 1.0.2 en `addons/godot_mcp_toolkit`, habilitado en `project.godot`, y una configuración local en `.mcp.json`. Codex apunta a este mismo proyecto con el puente `@npgamedev/godot-mcp-server` 1.0.2; Node 24.14.0 cumple su requisito. En la verificación del 2 de octubre de 2026, una sola instancia de Godot quedó abierta y el probe MCP de solo lectura confirmó `application/config/name = Vitmorph` por `127.0.0.1:6550`. Si se cierra el editor, vuelve a abrir este proyecto y reconecta el cliente; no abras otra instancia para duplicar el MCP.

## Documentos del proyecto

- `DESIGN_STATUS.md`: comprensión, decisiones aprobadas, temas abiertos y descartados.
- `SYSTEMS_DESIGN.md`: antecedente de sistemas; las decisiones de demo vigentes están en DEMO_IMPLEMENTATION.md.
- `BUILD_DESIGN.md`: antecedente del editor; implementado y revisado en esta demo conforme al contrato aprobado.
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

La pantalla de preparación añadida por el agente fue rechazada y eliminada. Las builds se editan voluntariamente fuera de combate y están implementadas; no se introduce una pantalla previa obligatoria al combate.

## Repositorio y recuperación

[VITMORPH en GitHub](https://github.com/Quilik8/VITMORPH). Historial en `CHANGELOG.md`, decisiones en `DESIGN_STATUS.md` y `TECHNICAL_DECISIONS.md`; recuperación en `VERSIONING.md`.

La pantalla de preparación fue rechazada y eliminada. El jugador construye sus builds con B; no se impone un paso antes del encuentro. Navegación técnica en ambos ejes con cámara y terreno ampliado. La comparación con tres repeticiones por escenario está en tests/evidence/performance_comparison.json; no constituye garantía para contenido futuro.

## Rendimiento

Primera pasada medida: terreno retenido y mallas reutilizadas. Resultados, diagnóstico optativo y límites en [PERFORMANCE.md](PERFORMANCE.md). Punto recuperable de esta pasada: `checkpoint-v0.1.1`.

Investigación para contenido futuro: [ASSET_PERFORMANCE_PLAN.md](ASSET_PERFORMANCE_PLAN.md). Recomendaciones técnicas para recursos, sprites, efectos y sectores; aún no implementadas ni certificadas.

Segunda pasada: [PERFORMANCE_HEADROOM.md](PERFORMANCE_HEADROOM.md). Incluye CPU, p95/p99, tirones, memoria gráfica, nodos/recursos y costes de cachés. Punto recuperable `checkpoint-v0.1.2`. La etiqueta histórica de persecución en la primera comparación fue corregida: medía reposicionamiento de cámara.
