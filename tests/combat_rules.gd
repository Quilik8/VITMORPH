extends RefCounted
## Pruebas deterministas aisladas del combate visible; no requieren otro editor.
const Combat = preload("res://systems/combat_engine.gd")
const Fixture = preload("res://data/combat_fixture.gd")
const AI = preload("res://systems/combat_ai.gd")
var checks: Array[Dictionary] = []

func check(condition: bool, name: String) -> void:
	checks.append({"name": name, "passed": condition})

func run() -> Dictionary:
	checks.clear()
	var game := Combat.new()
	game.start(0)
	check(game.pending.skill.id == "close", "IA elige mayor daño válido")
	game.command("priority", "basic")
	game.command("retain", "close")
	check(game.pending.skill.id == "close", "Comando no altera acción ya elegida")
	game.resolve_pending()
	check(game.actor_by_id("near").hp == 70, "Acción en curso termina aun retenida después")
	game.choose_next()
	game.resolve_pending()
	game.choose_next()
	check(game.pending.skill.id == "basic", "Prioridad válida se elige")
	game.command("retain", "basic")
	var main: Dictionary = game.actor_by_id("main")
	var choice: Dictionary = AI.choose(main, game.actors, game.priority, game.retained)
	check(choice.skill.id != "basic" and game.priority == "basic", "Retención bloquea sin borrar prioridad")
	game.command("retain", "")
	check(AI.choose(main, game.actors, game.priority, game.retained).skill.id == "basic", "Liberar restaura prioridad")
	game.command("priority", "not_a_skill")
	check(game.priority == "basic", "ID desconocido no cambia comando")
	game.free()

	game = Combat.new()
	game.start(0)
	game.command("priority", "close")
	game.resolve_pending()
	main = game.actor_by_id("main")
	check(main.ready_at.close == 4, "Reutilización de dos elecciones: vuelve en la cuarta")
	for turn in [2, 3]:
		main.turns = turn
		check(AI.choose(main, game.actors, game.priority, "").skill.id != "close", "Reutilización bloquea elección %d" % turn)
	main.turns = 4
	check(AI.choose(main, game.actors, game.priority, "").skill.id == "close", "Prioridad conservada vuelve a usarse al estar disponible")
	check(game.priority == "close", "Uso no consume la prioridad")
	main.hp = 40
	game.command("priority", "")
	check(AI.choose(main, game.actors, "", "").skill.id == "guard", "Defensa automática al 40 por ciento")
	main.shield = 24
	check(not AI.blocked_reason(main, main.abilities[1], game.actors, "", 4).is_empty(), "Protección existente impide acumular defensa")
	game.pending = {"actor_id": "near", "skill": game.actor_by_id("near").abilities[0].duplicate(), "target_id": "main", "reason": "test"}
	game.resolved = false
	game.resolve_pending()
	check(main.hp == 40 and main.shield == 0, "Escudo absorbe impacto y se consume completo")
	game.resolved = false
	game.resolve_pending()
	check(main.hp == 26, "Siguiente impacto afecta vida sin escudo")
	game.free()

	game = Combat.new()
	game.start(1)
	game.command("priority", "close")
	main = game.actor_by_id("main")
	check(AI.choose(main, game.actors, game.priority, "").skill.id == "far", "Prioridad fuera de alcance usa alternativa válida")
	main.shield = 24
	var choice_wait: Dictionary = AI.choose(main, game.actors, "close", "far")
	check(choice_wait.skill.is_empty(), "Ninguna habilidad válida produce espera")
	game.pending = choice_wait
	game.resolved = false
	game.resolve_pending()
	check(game.running and game.history.size() == 1, "Espera se resuelve sin detener el flujo")
	game.free()

	game = Combat.new()
	game.start(2)
	main = game.actor_by_id("main")
	check(AI.target_for(main, main.abilities[3], game.actors).id == "near", "Empate de vida conserva orden de objetivos")
	game.actor_by_id("far").hp = 30
	check(AI.target_for(main, main.abilities[3], game.actors).id == "far", "IA selecciona menor vida entre objetivos válidos")
	game.actor_by_id("far").hp = 0
	check(AI.target_for(main, main.abilities[3], game.actors).id == "near", "Objetivo muerto queda excluido")
	game.free()

	game = Combat.new()
	game.start(2)
	var next_names: Array[String] = game.upcoming(12)
	check(next_names[0] == "Enemigo cercano" and next_names[1] == "Enemigo lejano", "Empates de iniciativa tienen orden estable")
	game.actor_by_id("main").speed = 100.0
	game.actor_by_id("main").next_at = 0.0
	game.actor_by_id("near").next_at = 20.0
	game.actor_by_id("far").next_at = 20.0
	check(game.upcoming(3) == ["Principal", "Principal", "Principal"], "Iniciativa admite acciones consecutivas")
	game.free()

	for scenario in 3:
		game = Combat.new()
		game.start(scenario)
		var iterations := 0
		while game.running and iterations < 200:
			game.resolve_pending()
			if game.running:
				game.choose_next()
			iterations += 1
		check(not game.running and not game.result.is_empty(), "Escenario %d termina sin atasco" % scenario)
		var count := game.history.size()
		game._process(10.0)
		check(game.history.size() == count, "Escenario %d no actúa después del final" % scenario)
		game.start(scenario)
		check(game.priority.is_empty() and game.retained.is_empty() and game.history.is_empty() and game.actor_by_id("main").hp == 100, "Escenario %d reinicia estado completo" % scenario)
		game.free()
	var failures: Array[String] = []
	for item in checks:
		if not item.passed:
			failures.append(item.name)
	return {"passed": failures.is_empty(), "count": checks.size(), "failures": failures, "checks": checks}
