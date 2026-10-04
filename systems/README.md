# Sistemas

Contiene el motor de combate y la IA determinista de la primera prueba. Los comandos, iniciativa, reutilización y resolución no dependen del HUD. El alcance se documenta en `COMBAT_PROTOTYPE.md`.

`world_route.gd` coordina la navegación del jugador, persecución provisional y encuentros por proximidad. Comparte los estados de actores con el motor y conserva vida y comandos entre zonas; no cambia la escena. Alcance y límites en `WORLD_CONTINUITY.md`.
`world_geometry.gd` comparte colisión por radio, visibilidad y rutas alrededor de obstáculos para principal y perseguidores.

La iteración 06 usa carga ATB y actores listos por llegada, conservando reutilización por elecciones propias. La suite anterior y sus resultados son históricos; no certifican el ATB. Reglas en ATB_PROTOTYPE.md.
