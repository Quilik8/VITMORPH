# Primera prueba de combate de Vitmorph

## Para jugar

La iteración 03 añade **Recorrido continuo**, seleccionado inicialmente. Muévete con WASD o flechas para encontrar los tres grupos. El segundo grupo puede salir a confrontarte. La franja de habilidades aparece solo en estado de combate. No cambia de escena al combatir. Vida y comandos se conservan entre encuentros; las formaciones son propias del lugar. Ver `WORLD_CONTINUITY.md`. Los escenarios aislados descritos abajo siguen en el selector.

Abre `project.godot` en Godot 4.7.2 y ejecuta la escena principal con F5. Selecciona el escenario y pulsa **Comenzar**. Selecciona una habilidad en la franja inferior y usa los dos comandos compartidos. No hay pausa ni confirmación de ataques; la IA actúa automáticamente. Al finalizar puedes repetir o cambiar de escenario.

1–4 seleccionan habilidad; P prioriza/quita prioridad y R retiene/libera la seleccionada. Tab / Mayús+Tab recorren los controles; Enter o Espacio activan el enfocado. Detalles/F3 abre el diagnóstico sin pausar. Las marcas permanecen visibles en las cuatro habilidades; efecto y disponibilidad se muestran solo para la seleccionada.

## Reglas aprobadas para esta fase

Un principal frente a uno o dos enemigos. Una prioridad y una retención como máximo. La habilidad priorizada se elige si es válida. Ambas marcas persisten hasta cambiarlas o quitarlas; si coinciden, Retener bloquea y liberar conserva la prioridad. Los comandos cambian la siguiente elección, nunca una acción iniciada.

Una habilidad debe cumplir alcance, reutilización, objetivo vivo y condiciones propias. Sin habilidades válidas se pierde la oportunidad, sin detener el combate.

## Valores técnicos provisionales

Los escenarios aislados tienen 100 PV. Velocidades: principal 10, cercano 8, lejano 12. Desde la iteración 06 cada bestia carga ATB independiente de 0 a 100 a velocidad puntos/s: tarda 10, 12,5 u 8,33 s respectivamente. Las demás cargan durante la ejecución; al llegar al 100 esperan en orden de llegada, con empates estables. La elección de IA ocurre al iniciar la acción, no al quedar listo. Presentación de cada acción de 4,8 s e impacto a 2,2 s; la bestia que actúa vuelve a cargar al terminar la recuperación. Sin listos, continúa cargando sin pausa. Ver ATB_PROTOTYPE.md. Son parámetros provisionales.

| Habilidad técnica | Slot | Efecto | Alcance | Reutilización |
|---|---|---|---|---|
| Ataque básico | Fija 1 | 18 daño | 400 | 0 elecciones |
| Defensa | Fija 2 | Absorbe hasta 24 daño del siguiente impacto | Propio | 0 elecciones |
| Ataque cercano | Modular 1 | 30 daño | 240 | 2 elecciones |
| Ataque distante | Modular 2 | 12 daño | 600 | 1 elección |
| Ataque enemigo | Técnico | 14 daño | 600 | 0 elecciones |

Reutilización 2: usada en la elección propia 1, queda bloqueada en 2 y 3, vuelve en 4. No se mide en segundos. La defensa solo es válida sin protección existente; el siguiente impacto consume toda la protección, incluso si sobra.

Formación 2D: principal (120,260), cercano (320,150), lejano (620,290). Distancias aproximadas 228,3 y 500,9 unidades. Las posiciones lógicas permanecen fijas; el acercamiento al atacar es animación técnica y no cambia alcance. Sin prioridad válida, la IA defiende al 40 % de vida o menos si no tiene protección; en los demás casos usa el ataque válido de mayor daño. Si solo queda defensa válida, la utiliza. Elige al objetivo válido con menos vida; empates por orden estable.

Estos valores se ajustan en `data/combat_fixture.gd`. Son hipótesis; las figuras, habilidades y colores no definen criaturas ni arte final. No se han creado imágenes. Los slots modulares aún no permiten equipar habilidades.

## Revisión con el jugador

1. Comparar cercano y lejano: priorizar Ataque cercano frente al lejano conserva la marca y usa una alternativa válida.
2. Priorizar y retener una misma habilidad: la marca doble debe ser visible y liberar devuelve su preferencia.
3. Cambiar comandos durante una acción: termina la acción iniciada; la siguiente elección recibe el cambio.
4. Comparar uno contra uno y uno contra dos: ¿se entiende la cola y se percibe el efecto de intervenir?
5. Revisar claridad y ritmo antes de sumar builds. Ganar por sí solo no demuestra que el combate sea interesante.

## Etapas posteriores, aún sin implementar

Antes de ampliar sistemas: revisar el campo, el ritmo lento y las intervenciones de la iteración 02; concretar qué reglas de tiempo y posición se adoptarán de la referencia Chrono Trigger. Ver `UI_COMBAT_DIRECTION.md`.

Combate e intervenciones → habilidades modulares y una ley compatible → captura manteniendo vivo al enemigo → preparación/combate/captura/modificación → posicionamiento, estados, variedad y arte externo → aliados y reserva.

Cada etapa requiere revisar la anterior y concretar decisiones abiertas. Los resultados no se convierten automáticamente en canon.
