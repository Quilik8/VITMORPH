# Vitmorph — próximos sistemas de diseño

Fecha: 3 de octubre de 2026.
Estado: propuesta para revisión, no canon nuevo ni autorización automática de implementación.

## Base confirmada

El jugador navega por un mundo continuo; los encuentros ocurren allí y muestran el HUD contextual. Las bestias actúan automáticamente, con ATB e intervención mediante Priorizar y Retener. La prueba actual conserva un principal. Las builds las construye el jugador; se rechazó la pantalla obligatoria previa a cada combate.

La estructura aprobada incluye dos habilidades fijas, dos modulares, biblioteca global, ocho ranuras normales y dos especiales. Los modificadores normales afectan a todas las habilidades compatibles. Las ocho leyes y sus límites conceptuales constan en DESIGN_STATUS.md y el documento maestro externo. Las fórmulas, reglas de combinación y comportamiento profundo de IA siguen abiertos.

## Orden propuesto y dependencias

| Bloque | Decisión de diseño que necesitamos | Resultado para revisar |
|---|---|---|
| 1. Habilidades y builds | Qué describe una habilidad, compatibilidad, intercambio modular y combinación de modificadores | Una build comprensible y dos configuraciones con diferencias observables |
| 2. IA y espacio | Cómo compara efectos, elige objetivos y responde a la build; reglas de alcance/obstáculos y eventual reposicionamiento automático | Decisiones explicables con alcance y objetivos distintos |
| 3. Efectos y estados | Aplicación, duración, repetición, acumulación, expiración y reacciones | Una interacción pequeña que respete reglas comunes |
| 4. Copia de bestias | Condición de criatura viva debilitada, inicio del proceso, riesgo, resultado y desbloqueos | Obtener una copia y sus herramientas modulares |
| 5. Colección y persistencia | Identidad de copias, biblioteca, configuración equipada, guardado y restauración | Conservar una build y una copia al cerrar el juego |
| 6. Bucle de mundo | Distribución de encuentros, recorrido, recuperación, derrota y retorno; alcance de una demo | Un recorrido corto con decisiones y consecuencias |
| 7. Profundidad posterior | Combos, puzzles, rangos, recursos, equipo y reserva | Diseñar cada extensión sobre el bucle revisado |

Las necesidades de guardado se definen desde el primer bloque para evitar pérdidas de identidad; su implementación completa no necesita preceder al prototipo de build. IA y estados se diseñan junto con las habilidades que los requieren, aunque sus bloques de prueba sean pequeños. El movimiento automático de combate continúa como posibilidad pendiente: no se añade un coste/acción de movimiento. Aliados y reserva siguen para una etapa posterior.

## Primer bloque candidato: habilidades, propiedades y compatibilidad

Desarrollo concreto del candidato y brief de interfaz: [BUILD_DESIGN.md](BUILD_DESIGN.md). Contiene reglas alternativas pendientes, comparación de Alcance y estados; no es una interfaz ya implementada.

Objetivo: que el jugador pueda anticipar qué cambia al construir una build y reconocer ese cambio en las decisiones de su bestia.

Propuesta de descripción común de cada habilidad:

- **Efecto:** qué produce: daño, protección u otro efecto que aprobemos.
- **Objetivos:** a quién puede afectar y cómo selecciona entre objetivos válidos.
- **Condiciones:** alcance, reutilización y requisitos del efecto.
- **Propiedades modificables:** qué leyes tienen un efecto definido y sobre qué valor actúan.
- **Explicación:** resultado base, resultado modificado y motivo de incompatibilidad cuando corresponda.

No basta con etiquetar una habilidad como compatible: cada compatibilidad necesita especificar la propiedad que cambia. Duración no aparece como beneficio de un efecto instantáneo sin una duración real. Alcance no debe convertirse en más objetivos o mayor área si esa habilidad no tiene definida esa manifestación espacial.

### Primera prueba propuesta

Usar las habilidades técnicas actuales, intercambio de las dos modulares y una ley: **Alcance**. Un modificador normal se equipa a la bestia y afecta a todos sus ataques compatibles; la defensa propia permanece sin cambio espacial. Comparar el mismo encuentro con dos configuraciones. Observar si cambia la validez de objetivos y si Priorizar conserva sus reglas.

La elección de Alcance, sus valores y esta prueba son candidatos. No se equipa ni implementa nada mediante este documento. La interacción de construcción debe diseñarse después de concretar las reglas; no se prescribe una pantalla antes de encuentros.

### Decisiones que faltan antes de implementarlo

1. Representación del efecto de cada modificador: incremento, factor u otra transformación. Orden de combinación y límites cuando coinciden varios.
2. Compatibilidad de cada habilidad de prueba y explicación visible del resultado.
3. Intercambio modular: duplicados permitidos o no y requisitos de equipamiento, si existen. La biblioteca reutilizable aprobada no resuelve por sí sola estas preguntas.
4. Momento permitido para editar la build y persistencia de comandos/reutilización al sustituir una habilidad. No asumir edición durante combate.
5. IA de la prueba: distinguir mantener la selección provisional de mayor daño de diseñar evaluación real de defensa/control, evitando temperamentos rechazados o scripting del jugador.

## Criterio para ampliar

El jugador debe poder explicar qué cambió en su build, por qué una habilidad recibe o no un modificador y por qué la IA toma una decisión distinta. Ganar más rápido por sí solo no demuestra profundidad. Después se revisa el candidato y se aprueban sus reglas antes de implementar el siguiente bloque.

## Fuentes y autoridad

- Instrucciones directas del jugador en este chat: prevalecen sobre fuentes anteriores.
- Documento Conceptual Maestro v1.0, secciones 3–8, 12–24 y 30–34: identidad y sistemas de referencia; títulos originales no cambian el nombre Vitmorph.
- DESIGN_STATUS.md: decisiones vigentes, abiertas y descartadas.
- VALIDATION.md y PERFORMANCE_HEADROOM.md: evidencia técnica actual, no aprobación de nuevas reglas.
