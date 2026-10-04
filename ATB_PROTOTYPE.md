> Actualización de demo · 4 de octubre de 2026: contrato vigente en DEMO_IMPLEMENTATION.md, uso en DEMO_GUIDE.md y evidencia en DEMO_DELIVERY.md. Este documento conserva el antecedente; las restricciones superadas no describen la demo actual.

# Iteración 06 · ATB y orden visible

## Solicitud del jugador

Acelerar exploración, construir ATB y mostrar arriba del HUD una franja que permita entender el turno de cada bestia. Explorar la conveniencia de movimiento táctico después. El ATB está solicitado; los parámetros siguientes son hipótesis ajustables.

## Reglas implementadas

- Cada bestia inicia el encuentro con carga 0/100 y acumula velocidad puntos por segundo. Principal 10: 10 s; enemigo 8: 12,5 s; enemigo 12: 8,33 s.
- Las barras de las otras bestias cargan mientras se presenta una acción. No hay pausa al intervenir ni rondas fijas.
- A 100, queda lista. Orden de actuación por instante de llegada, empatando por orden estable de actores. No acumula otra oportunidad mientras está lista.
- Una sola acción se presenta a la vez durante 4,8 s; impacto a 2,2 s. Al terminar recuperación, su actor comienza a cargar desde cero. No carga durante su propia acción.
- La IA elige habilidad y objetivo al comenzar a actuar. Los cambios de Priorizar/Retener afectan esa elección aunque el actor ya esté listo; una acción elegida termina normalmente.
- Sin habilidad válida, consume su oportunidad de espera y vuelve a cargar al terminar la presentación. Ninguna barra ni comando ignora alcance, retención o reutilización.
- La reutilización sigue contando elecciones propias, no segundos ni ticks de ATB. Vida, protección, marcas y reutilización persisten entre encuentros; la carga ATB se reinicia al entrar a cada grupo.
- Muertos quedan fuera de la cola. El combate termina cuando cae el principal o todos los enemigos. Reiniciar reconstruye el estado.

## Cola superior de sucesos

Solo aparece en combate y muestra siete acciones previstas, con repeticiones de las mismas bestias y flechas entre ellas. Incluye actor actual y futuros inicios estimados; no una barra por bestia. Recalcula a 5 Hz y por cambios de estado. Usa cargas, llegada y recuperación actuales; no predice daño ni muertes futuras. Los arcos sobre actores siguen siendo anticipación visual.

## Exploración y terreno

Velocidad del principal de 85 a 180 unidades/s. Perseguidores mantienen 65 unidades/s. Los obstáculos permanecen visibles en combate, pero actualmente solo bloquean navegación, detección e inicio del encuentro; no bloquean ataques. El movimiento al atacar continúa siendo una animación, no desplazamiento táctico.

## Movimiento táctico futuro · aclaración de iteración 07

El jugador aclaró que el movimiento en combate continuará siendo automático y que no aprueba tratarlo como acción. La posibilidad requiere diseñar IA y planificación de rutas; no se implementa en esta fase. Aproximarse, mantener distancia y rodear obstáculos son posibles comportamientos a estudiar, sin fijar todavía costes ni reglas de movimiento.

Godot proporciona navegación y seguimiento; la documentación advierte que evitación de muchos agentes tiene coste y debe activarse donde haga falta. No necesitamos comenzar por búsqueda extensa o simulación de todas las posiciones. Referencia primaria: [NavigationAgent2D](https://docs.godotengine.org/en/4.5/classes/class_navigationagent2d.html). La viabilidad concreta en este equipo requiere medición, no una garantía de rendimiento.

## Evidencia y límites

Capturas y snapshots por Godot MCP en VALIDATION.md. Las 33 comprobaciones previas pertenecen a iniciativa virtual, no certifican el planificador ATB. run_rule_checks devuelve HISTORICAL_SUITE para evitar su ejecución accidental; adaptar y ejecutar pruebas automatizadas queda pendiente de una solicitud de validación específica. No se ha medido rendimiento, ni agotado casos extremos de carga/empates/pausas del proceso.
