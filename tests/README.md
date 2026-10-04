# Pruebas

`combat_rules.gd` contiene 33 comprobaciones deterministas aisladas. Con el proyecto en ejecución, el MCP puede llamar a `run_rule_checks()` con `scope_path: /root/Main` mediante `execute_code`. Devuelve resultados y los imprime sin alterar la partida visible.

`evidence/combat_rules.json` conserva el resultado de la ejecución y los PNG conservan capturas reales del runtime. El resumen y los límites están en `VALIDATION.md`. Las capturas son evidencia, no assets del juego.
