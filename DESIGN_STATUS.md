# Estado del diseño

## Actualización de la demo · 4 octubre 2026

El contrato vigente de esta entrega está en DEMO_IMPLEMENTATION.md: builds fuera de combate con exploración pausada, selección de un principal, copia como apoyo, biblioteca reutilizable, estados, guardado y refugio. Estos sistemas ya están implementados y técnicamente validados; los pendientes históricos de las secciones posteriores deben leerse junto al contrato. La evaluación humana del ritmo y balance continúa pendiente. Parámetros y geometría siguen siendo provisionales. Entrega y límites: DEMO_DELIVERY.md.

Este resumen separa las decisiones de diseño contenidas en los dos documentos v1.0 de las propuestas técnicas de esta base. No convierte los temas abiertos en canon.

## Nombre del juego y del proyecto

**Vitmorph** es el nombre definitivo del juego y del proyecto por instrucción explícita del usuario del 1 de octubre de 2026. El encargo inicial decía “SYNTHERA” y el documento conceptual se titula “Síntesis Modular”; esos nombres quedan reemplazados como nombre del producto. La biblia visual no propone otro nombre.

## Comprensión del proyecto

Vitmorph es un juego 2D de combate táctico por turnos tipo auto-battler. Las criaturas deciden sus acciones mediante IA; el jugador construye sistemas combinando sus habilidades, modificadores, propiedades, posicionamiento y equipo. La profundidad debe surgir de reglas visibles que se combinan, no de excepciones secretas. La creación de copias de criaturas debilitadas pero vivas y el armado de builds son partes centrales del juego.

La dirección visual actual, descrita en la Biblia Visual como **Fábula Moderna Simplificada**, busca ilustración 2D pictórica y cálida, siluetas legibles, expresión y variedad anatómica y material. Las tres imágenes piloto de Control, Ataque y Defensa sirven como referencias de acabado; no son moldes para las demás criaturas.

## CANON / APROBADO

- Para obtener una copia hay que debilitar y mantener viva a la criatura. Eliminarla impide copiarla, aunque pueda dar otras recompensas.
- Cada criatura tiene 2 habilidades fijas y 2 modulares. Las modulares obtenidas pasan a la biblioteca global sin quitárselas a la criatura original.
- Cada criatura tiene 8 espacios de modificadores normales y 2 especiales. Los normales actúan globalmente sobre habilidades compatibles; un especial puede vincularse a una habilidad o funcionar de manera universal.
- Las ocho leyes aceptadas son Potencia, Alcance, Duración, Dureza, Afinidad, Estabilidad, Persistencia y Propagación. Solo afectan habilidades compatibles. No deben convertirse automáticamente en excepciones o efectos universales.
- Los roles estratégicos son Ataque, Defensa y Control; no forman una tabla rígida de ventajas ni determinan la anatomía de una criatura.
- El núcleo es un auto-battler táctico por turnos. Las acciones se resuelven de forma discreta. El jugador pidió construir ATB independiente en la iteración 06; puede permitir acciones consecutivas. La arena es 2D, las posiciones importan y no se exige una cuadrícula visible ni movimiento manual continuo.
- La primera fase de pruebas de combate tendrá únicamente una bestia principal controlada por el jugador; no incluirá aliados.
- Para un diseño posterior, el jugador podrá tener hasta 5 bestias capturadas: una principal elegida por el jugador, hasta 3 aliadas activas con IA propia y una en reserva. El máximo futuro es de 4 bestias activas en total.
- Los comandos del jugador son **Priorizar** y **Retener**. Curar, cambiar de bestia y usar objetos son acciones de apoyo separadas; no son comandos.
- **Priorizar** selecciona la habilidad priorizada siempre que sea válida, según la elección explícita del usuario para esta prueba. No permite usar una habilidad inválida. Como máximo puede haber una habilidad priorizada y permanece hasta cambiarla o quitarla.
- **Retener** impide usar la habilidad seleccionada hasta que el jugador la libere. Como máximo puede haber una habilidad retenida.
- El combate de la primera prueba avanza automáticamente sin pausas. Los cambios de comandos afectan a la siguiente elección y no interrumpen una acción iniciada. Si una habilidad está priorizada y retenida, Retener bloquea el uso; al liberarla conserva la prioridad.
- Meta confirmada: recorrido y combate comparten el mundo visible, sin una instancia de batalla separada ni pantallas de carga durante la transición. Las posiciones enemigas deben depender del lugar.
- El jugador aprobó la mejora visual de la iteración 02 y prevé reemplazar las etiquetas de habilidades por imágenes diseñadas y efectos aportados externamente. Esta aprobación no fija el arte definitivo; ATB fue solicitado después en la iteración 06.
- Parry queda fuera de la primera fase de pruebas porque requiere trabajo específico por enemigo. Esto no lo descarta automáticamente del diseño futuro.
- Lo habitual es encontrar 1–4 enemigos activos; 5–6 son casos especiales.
- Los puzzles arcanos son opcionales, pueden durar varios turnos y el combate continúa mientras se resuelven. Las familias aceptadas son Rotación de Anillos, Reconstrucción Geométrica, Fusión de Runas y Colapso de Sello.
- La progresión debe evitar el grind RPG tradicional y premiar desafíos demostrados contra bestias de mayor rango.
- La dirección visual actual es Fábula Moderna Simplificada: acabado pictórico artesanal, luz cálida, lectura clara, personalidad y diversidad de anatomías, materiales, patrones y paletas.
- La base técnica prevista es Godot 2D/GDScript, ligera y mantenible en hardware modesto, con una meta de 60 FPS cuando sea razonable.

## ABIERTO / PENDIENTE

- Cantidad definitiva de rangos, valores de estadísticas y condiciones exactas de ascenso.
- Fórmulas de iniciativa, mods y compatibilidad de propiedades; empates, límites y casos extremos.
- Balance definitivo de la IA, ritmo e iniciativa. La aplicación y coexistencia de comandos ya están resueltas para la primera prueba.
- Movimiento, reposicionamiento, cambios de bestia y efectos precisos de las reservas.
- Matemática de combos de continuidad y variedad, y qué corta cada cadena.
- Comportamiento detallado de la IA y cómo la build cambia sus decisiones.
- Fórmulas de vulnerabilidad y puzzles, duración, matrices, progreso y recompensas.
- Catálogo final de elementos y estados, sus reglas e interacciones. Los nombres listados en el concepto son candidatos, no una tabla de tipos aprobada.
- Balance de aliados secundarios, sustitución de la reserva, economía, recursos y progresión fuera del combate.
- Si Parry se retomará después de la fase inicial y qué reglas específicas tendría por enemigo.
- Mapa, regiones, historia, misiones, base/hub, derrota y alcance de la primera demo.
- Integración de ilustraciones, sprites, animación, tamaños de textura, efectos y presentación en Godot.
- Validación de la nueva interfaz y ritmo con el jugador. Evaluar los parámetros del ATB implementado por petición del jugador; no confundir los arcos de preparación con barras ATB.

## Alcance confirmado de la primera fase de combate

- Un único principal; sin aliados ni bestias en reserva.
- Probar las intervenciones **Priorizar** y **Retener** como los dos comandos.
- Comprobar que Priorizar dé preferencia únicamente a una habilidad válida y que Retener impida su uso hasta la liberación.
- No implementar Parry en esta fase.
- Escenarios aprobados: uno contra uno cercano, uno contra uno lejano y uno contra dos, con un único principal.
- Usar cuatro habilidades y combatientes técnicos provisionales autorizados por el usuario. Las posiciones son fijas y los valores de vida, daño, alcance, protección, reutilización y velocidad son hipótesis ajustables, no contenido definitivo.

## TECHNICAL PROPOSAL / HIPÓTESIS IMPLEMENTADAS

- Iteración 06: carga ATB de 0 a 100 a velocidad puntos/s; demás bestias cargan mientras una actúa, cada una conserva solo una oportunidad lista y espera según llegada/orden estable. La IA decide al despachar. Ejecución de 4,8 s e impacto a 2,2 s. Exploración a 180 unidades/s. Ajustes técnicos, no balance definitivo.
- IA sin prioridad válida: defensa si vida ≤40 % y sin escudo; de otro modo ataque válido de mayor daño. Si solo queda defensa válida, la usa como alternativa; sin habilidades válidas pierde la oportunidad.
- Objetivo válido con menor vida, empatando por orden estable. El escudo técnico protege un solo impacto y no se acumula.
- Valores en `data/combat_fixture.gd` y definición en `COMBAT_PROTOTYPE.md`. No son especies, habilidades finales ni balance aprobado.
- Iteración 02: campo 2D protagonista, formación dispersa y animación de ejecución sin movimiento táctico; habilidades compactas, datos contextuales y diagnóstico oculto. El jugador aprobó la mejora visual de la prueba.
- Referencia explícita del jugador: batallas de Chrono Trigger. Aplicar sus relaciones de tiempo, espacio y puesta en escena requiere concretar qué mecánicas se adoptan; no copiar control manual de ataques ni añadir aliados.
- Iteración 03: recorrido automático técnico de tres zonas en una sola escena, encuentro por proximidad, cámara continua y actores persistentes. Vida/comandos/reutilización se conservan entre grupos; los valores de enemigos del recorrido son provisionales. El recorrido automático fue sustituido por navegación del jugador en la iteración 04; streaming de mundo grande sigue abierto.

## DESCARTADO

- Acción en tiempo real como núcleo, control manual de ataques, movimiento libre durante el combate, QTE ofensivos y programación textual de la IA.
- Sobrecarga de habilidades, redistribución de potencia de mods durante combate, manipulación del estado operativo del chasis, recurso de “Mando”, habilidades del operador y la formulación anterior de temperamentos simples.
- Tabla rígida de tipos; Tierra, Luz u Oscuridad como elementos por defecto.
- Trenzado Arcano.
- Como leyes independientes: Entropía, Resonancia, Permeabilidad, Cohesión, Frecuencia, Fuerza, Área y Extensión. Persistencia absorbe la antigua propuesta de Cohesión; Potencia incluye Fuerza y Alcance incluye Área.
- Anatomías obligatorias por rol y reglas visuales como “ojos pequeños = intimidante”.
- Repetir por inercia moteado, materiales, cuellos largos, colas protagonistas, vegetación, árboles, cristales u ornamentos genéricos entre especies.

## Diferencias entre fuentes

No encontré contradicciones de diseño entre la Síntesis Conceptual y la Biblia Visual: ambas coinciden en la dirección artística actual y en que los roles no deben imponer anatomías. La única diferencia nominal relevante es que las fuentes retienen sus títulos y el encargo inicial decía SYNTHERA; la instrucción directa más reciente fija Vitmorph.

La palabra “provisional” del rótulo de estilo en la biblia permite evolución futura. Se registra Fábula Moderna Simplificada como dirección vigente de v1.0, no como un catálogo visual cerrado.

## Confirmación del jugador · iteración 04

La navegación fuera del combate corresponde al jugador. Al encontrar enemigos o salir estos a confrontarlo comienza el estado de combate; solo entonces aparece el HUD de combate. WASD/flechas, límites rectangulares del terreno, radio de detección y velocidad de persecución son implementaciones provisionales. No se añaden builds, captura ni aliados en este paso.

## Iteración 05 · hipótesis espaciales implementadas

Tres distribuciones de enemigos, obstáculos con colisión y deslizamiento, detección visible, persecución limitada y retorno al origen. Se mantiene la iniciativa actual y los alcances de combate. El terreno no bloquea ataques en esta prueba. Radios, rutas y colisión son ajustes técnicos a revisar con el jugador; no canon definitivo.

## Iteración 06 · solicitud del jugador

Acelerar exploración, mostrar una franja superior para entender orden y carga y construir ATB. La aclaración posterior mantiene movimiento automático como posibilidad futura, sin aprobar movimiento como acción ni coste ATB. No se implementó movimiento táctico ni bloqueo de ataques por terreno en esta entrega.

## Corrección explícita del jugador · 3 de octubre de 2026

Se rechaza y elimina el menú de preparación, variantes y Potencia introducido por el agente. Las builds las arma el jugador; eso no autoriza pantallas previas a encuentros ni cargas. El mundo será amplio y se podrá navegar en múltiples direcciones. El movimiento futuro de bestias durante combate será automático, sin aprobar movimiento como acción. La cola de sucesos con repeticiones se conserva. Optimización y versionado en Quilik8/VITMORPH fueron solicitados.
