extends Node
var profile: Node

signal state_changed
signal action_chosen(action: Dictionary)
signal action_executed(action: Dictionary)
signal damage_applied(target_id: String, damage: int, absorbed: int)
signal combat_finished(result: String)
signal message(text: String)

const Fixture = preload("res://data/combat_fixture.gd")
const AI = preload("res://systems/combat_ai.gd")
var actors: Array[Dictionary] = []
var priority := ""
var retained := ""
var running := false
var result := ""
var pending: Dictionary = {}
var elapsed := 0.0
var resolved := false
const HISTORY_LIMIT := 256
var action_count := 0
var history: Array[Dictionary] = []
var scenario := 0
var action_seconds := Fixture.ACTION_SECONDS
var resolve_seconds := Fixture.RESOLVE_SECONDS
var combat_clock := 0.0

func start(which: int) -> void:
	scenario = clampi(which, 0, 2)
	actors = Fixture.actors(scenario)
	priority = ""
	retained = ""
	result = ""
	pending = {}
	history.clear()
	action_count = 0
	elapsed = 0.0
	running = true
	resolved = false
	message.emit("Comienza %s. Flujo continuo; tus comandos afectan a la siguiente elección." % Fixture.SCENARIOS[scenario])
	initialize_atb()

func initialize_atb() -> void:
	combat_clock = 0.0
	resolved = true
	for actor in actors:
		actor["atb"] = 0.0
		actor["ready_time"] = -1.0
	state_changed.emit()

func _process(delta: float) -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	_process_body(delta)
	if stamp != 0:
		profile.record("systems/combat_engine.gd:_process", Time.get_ticks_usec() - stamp)

func _process_body(delta: float) -> void:
	if not running:
		return
	var previous_clock := combat_clock
	combat_clock += delta
	for actor in actors:
		if actor.hp <= 0 or actor.ready_time >= 0.0 or (not pending.is_empty() and pending.actor_id == actor.id):
			continue
		var before: float = actor.atb
		actor.atb = minf(100.0, before + actor.speed * delta)
		if actor.atb >= 100.0:
			actor.ready_time = previous_clock + (100.0 - before) / actor.speed
	if not pending.is_empty():
		elapsed += delta
		if not resolved and elapsed >= resolve_seconds:
			resolve_pending()
		if not running:
			return
		if elapsed >= action_seconds:
			var actor := actor_by_id(pending.actor_id)
			actor.atb = 0.0
			actor.ready_time = -1.0
			pending = {}
			elapsed = 0.0
			resolved = true
			state_changed.emit()
	if pending.is_empty():
		choose_next()

func begin_encounter(participants: Array[Dictionary]) -> void:
	# Copia solo la lista: cada Dictionary sigue siendo el actor del mundo.
	actors = participants.duplicate()
	scenario = -1
	result = ""
	pending = {}
	history.clear()
	action_count = 0
	elapsed = 0.0
	running = true
	resolved = false
	for actor in actors:
		actor.next_at = 0.0
	# Vida, escudo, elecciones, reutilización y comandos sobreviven entre encuentros.
	message.emit("Encuentro en el lugar actual · vida y comandos conservados")
	initialize_atb()

func actor_by_id(id: String) -> Dictionary:
	for actor in actors:
		if actor.id == id:
			return actor
	return {}

func command(kind: String, skill_id: String) -> void:
	if not running or kind not in ["priority", "retain"]:
		return
	if not skill_id.is_empty():
		var known := false
		for skill in actor_by_id("main").abilities:
			if skill.id == skill_id:
				known = true
		if not known:
			return
	if kind == "priority":
		priority = skill_id
	else:
		retained = skill_id
	var label := "Priorizar" if kind == "priority" else "Retener"
	message.emit("%s: %s · se aplica a la próxima elección" % [label, skill_name(skill_id) if not skill_id.is_empty() else "liberado"])
	state_changed.emit()

func skill_name(id: String) -> String:
	for skill in actor_by_id("main").abilities:
		if skill.id == id:
			return skill.name
	return id

func choose_next() -> void:
	if not running or not pending.is_empty():
		return
	var actor: Dictionary = {}
	for candidate in actors:
		if candidate.hp > 0 and candidate.get("ready_time", -1.0) >= 0.0 and (actor.is_empty() or candidate.ready_time < actor.ready_time):
			actor = candidate
	if actor.is_empty():
		return
	actor.turns += 1
	pending = AI.choose(actor, actors, priority, retained)
	actor.atb = 0.0
	actor.ready_time = -1.0
	elapsed = 0.0
	resolved = false
	action_chosen.emit(pending.duplicate(true))
	var skill_label: String = "Esperar" if pending.skill.is_empty() else pending.skill.name
	message.emit("%s → %s · %s" % [actor.name, skill_label, pending.reason])
	state_changed.emit()

func resolve_pending() -> void:
	if resolved or pending.is_empty():
		return
	resolved = true
	var actor := actor_by_id(pending.actor_id)
	var skill: Dictionary = pending.skill
	if not skill.is_empty():
		var target := actor_by_id(pending.target_id)
		if not target.is_empty() and target.hp > 0:
			if skill.shield > 0:
				target.shield = skill.shield
				message.emit("%s obtiene %d de protección para el siguiente impacto." % [target.name, skill.shield])
			else:
				var absorbed: int = mini(target.shield, skill.damage)
				var damage: int = skill.damage - absorbed
				target.shield = 0
				target.hp = maxi(0, target.hp - damage)
				if target.hp == 0:
					target.atb = 0.0
					target.ready_time = -1.0
				damage_applied.emit(target.id, damage, absorbed)
				message.emit("%s: −%d vida%s" % [target.name, damage, " · protección absorbió %d" % absorbed if absorbed > 0 else ""])
			actor.ready_at[skill.id] = actor.turns + skill.cooldown + 1
	action_count += 1
	if history.size() >= HISTORY_LIMIT:
		history.pop_front()
	history.append(pending.duplicate(true))
	action_executed.emit(pending.duplicate(true))
	if actor_by_id("main").hp <= 0:
		finish("Derrota")
	else:
		var enemies_alive := false
		for candidate in actors:
			if candidate.id != "main" and candidate.hp > 0:
				enemies_alive = true
		if not enemies_alive:
			finish("Victoria")
	state_changed.emit()

func finish(outcome: String) -> void:
	running = false
	pending = {}
	resolved = true
	elapsed = 0.0
	result = outcome
	message.emit("%s · prueba finalizada. Puedes repetir o elegir otro escenario." % outcome)
	combat_finished.emit(outcome)

func atb_snapshot() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for actor in actors:
		var status := "charging"
		var rank := 2
		var order: float = (100.0 - actor.get("atb", 0.0)) / actor.speed
		if actor.hp <= 0:
			status = "defeated"
			rank = 3
			order = 0.0
		elif not pending.is_empty() and pending.actor_id == actor.id:
			status = "acting"
			rank = 0
			order = 0.0
		elif actor.get("ready_time", -1.0) >= 0.0:
			status = "ready"
			rank = 1
			order = actor.ready_time
		rows.append({"id": actor.id, "name": actor.name, "charge": actor.get("atb", 0.0), "status": status, "rank": rank, "order": order})
	# Inserción estable: los empates mantienen el orden de los actores.
	for index in range(1, rows.size()):
		var cursor := index
		while cursor > 0 and (rows[cursor].rank < rows[cursor - 1].rank or (rows[cursor].rank == rows[cursor - 1].rank and rows[cursor].order < rows[cursor - 1].order)):
			var value: Dictionary = rows[cursor]
			rows[cursor] = rows[cursor - 1]
			rows[cursor - 1] = value
			cursor -= 1
	return rows

func upcoming(count: int = 5) -> Array[String]:
	var names: Array[String] = []
	for event in forecast(count):
		names.append(event.name)
	return names

func forecast(count: int = 7) -> Array[Dictionary]:
	var sequence: Array[Dictionary] = []
	if not running:
		return sequence
	var queue: Array[Dictionary] = []
	var available_at := 0.0
	for actor in actors:
		if actor.hp <= 0:
			continue
		var ready: float = actor.get("ready_time", -1.0) - combat_clock if actor.get("ready_time", -1.0) >= 0.0 else (100.0 - actor.get("atb", 0.0)) / actor.speed
		if not pending.is_empty() and pending.actor_id == actor.id:
			available_at = maxf(0.0, action_seconds - elapsed)
			ready = available_at + 100.0 / actor.speed
			sequence.append({"id": actor.id, "name": actor.name, "time": 0.0, "current": true})
		queue.append({"id": actor.id, "name": actor.name, "ready": ready, "speed": actor.speed})
	while sequence.size() < count and not queue.is_empty():
		var best := 0
		for index in range(1, queue.size()):
			if queue[index].ready < queue[best].ready:
				best = index
		var start_at: float = maxf(available_at, maxf(0.0, queue[best].ready))
		sequence.append({"id": queue[best].id, "name": queue[best].name, "time": start_at, "current": false})
		available_at = start_at + action_seconds
		queue[best].ready = available_at + 100.0 / queue[best].speed
	return sequence

func snapshot() -> Dictionary:
	return {"running": running, "result": result, "priority": priority, "retained": retained,
		"clock": combat_clock, "atb": atb_snapshot(), "elapsed": elapsed, "resolved": resolved, "pending": pending.duplicate(true), "actors": actors.duplicate(true), "actions": action_count, "history_retained": history.size(), "history_limit": HISTORY_LIMIT, "scenario": scenario}
