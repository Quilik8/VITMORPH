# Iteración 05 · navegación y combate en el mismo mundo

## Decisiones del jugador

La navegación corresponde al jugador. Encontrar enemigos o que salgan a confrontarlo activa el estado de combate; solo entonces aparece su HUD. Recorrido y combate comparten escenario, sin pantalla de carga. Las posiciones dependen del lugar. Las imágenes de habilidades se incorporarán después con arte externo.

## Para jugar

Recorrido continuo es el modo inicial y comienza directamente en exploración. Usa WASD o flechas; al soltar las teclas te detienes. Las diagonales conservan la velocidad. Acércate a un grupo para iniciar el combate. El grupo de la segunda zona se acerca al detectarte. Durante el combate se bloquea el desplazamiento y la IA actúa automáticamente; 1–4 seleccionan habilidad, P prioriza y R retiene. Detalles/F3 abre el diagnóstico sin pausar.

Al terminar se ocultan habilidades, comandos, diagnóstico, nombres y barras de vida. Tras 2,8 segundos se devuelve el movimiento. Las marcas permanecen guardadas para el siguiente encuentro. Tras superar los tres grupos se puede seguir caminando. Reiniciar reconstruye la prueba y restablece vida y comandos. La derrota detiene el recorrido; no fija una regla de campaña. Los encuentros aislados siguen en el selector.

## Diseño de interfaz

Exploración: campo visible y ayuda breve de movimiento; aviso contextual si un grupo se acerca. Combate: feedback sobre actores y franja compacta de intervención, con diagnóstico optativo. El campo conserva sus dimensiones durante la aparición/desaparición del HUD; los controles se superponen en el margen inferior reservado. No se añaden tarjetas ni arte generado. La selección, foco y marcas accesibles deberán mantenerse al incorporar imágenes.

## Hipótesis técnicas

Una escena, un motor y siete actores: un principal y seis enemigos repartidos en tres grupos. Se conservan vida, protección, comandos, elecciones propias y reutilización entre encuentros, sin curación automática. La carga ATB comienza en cero para cada grupo; vida, marcas y reutilización se conservan. No se cambia ni carga la escena al encontrar enemigos.

| Grupo | Posiciones iniciales | Comportamiento provisional |
|---|---|---|
| 1 | (690,150), (770,210) | Espera en su lugar |
| 2 | (1450,380), (1780,180) | Detecta y persigue |
| 3 | (2320,130), (2610,360) | Espera en su lugar |

Movimiento del principal: 180 unidades/s; límites técnicos x=80…4000, y=80…2000; seguimiento de cámara en ambos ejes. Encuentro a 210 unidades. El grupo 2 detecta a 380 unidades y se acerca a 65 unidades/s; abandona la persecución si todos quedan a más de 500 unidades del principal o alguno supera 620 unidades desde su origen. Regresa rodeando obstáculos y no inicia combate durante ese regreso; al llegar puede detectar de nuevo. Sus posiciones finales dependen del recorrido del jugador y se fijan al comenzar el combate. Valores, persecución y límites son provisionales. Tres obstáculos técnicos bloquean el movimiento con margen corporal de 22 unidades y deslizamiento lateral. La detección y el inicio del encuentro exigen un segmento visible entre principal y enemigo. Los perseguidores calculan una ruta por las esquinas expandidas de los obstáculos. No se usa navegación por malla; la geometría de escenario es provisional.

Enemigos del recorrido: 30 PV y 4 de daño. Los escenarios aislados mantienen sus valores anteriores. Combate a 4,8 s por acción con impacto a 2,2 s. El desplazamiento de ataque sigue siendo presentación y no cambia alcance. Sin ataque válido la IA no ignora Retener.

## Alcance y siguiente paso

Esta escena pequeña prueba movimiento → encuentro → combate → regreso al movimiento, con estado persistente. No demuestra streaming de un mundo grande ni 60 FPS. ATB se implementó a petición del jugador en la iteración 06. Siguen pendientes las reglas espaciales del combate, incluidos bloqueo de ataques y movimiento táctico. Los obstáculos de esta fase no bloquean ataques: sus alcances actuales se mantienen. No se agregaron aliados, Parry, captura, builds, modificadores ni progresión. Revisaremos el control y las confrontaciones antes de ampliar esas etapas.

## Comparación táctica de esta fase

El primer grupo está cercano entre sí; el segundo se mueve al confrontar; el tercero conserva un enemigo cercano y otro separado. La posición desde la que te acercas determina qué habilidades tienen objetivos en alcance. Priorizar conserva la marca si no hay objetivo válido. Retener distante puede dejar un enemigo vivo fuera del alcance de otros ataques; liberar permite volver a atacarlo. No se fuerza la elección ni se cambia el alcance para evitar esa situación.

Los obstáculos están en Rect2(380,175,120,150), Rect2(1220,200,100,100) y Rect2(2120,140,120,150). Son volúmenes técnicos visibles; no definen roca, especie, región ni arte final. Objetivo de evaluación: observar si el acercamiento y la distribución hacen comprensibles y útiles las intervenciones.

La iteración 06 sustituye la iniciativa virtual por carga ATB independiente. La cola superior muestra una secuencia temporal con repeticiones; sus reglas provisionales se detallan en ATB_PROTOTYPE.md.

El mundo definitivo será mucho mayor y multidireccional. Este rectángulo amplio sigue siendo terreno técnico, no un mapa final ni una pantalla de preparación. La construcción de builds corresponde al jugador y su interfaz queda pendiente de diseño.
