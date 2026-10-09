extends Node
var profile: Node

signal state_changed
signal action_chosen(action: Dictionary)
signal action_executed(action: Dictionary)
signal damage_applied(target_id: String, damage: int, absorbed: int)
signal combat_finished(result: String)
signal message(text: String)
signal intentions_changed
signal rupture_changed(actor_id: String)
signal damage_resolved(target_id: String, breakdown: Dictionary)
const Damage = preload("res://systems/damage_resolution.gd")
var encounter_serial := 0
var last_damage: Dictionary = {}
var intentions: Dictionary = {}
var intentions_dirty := true
var intention_buckets: Dictionary = {}
var intention_updates := 0

const Fixture = preload("res://data/combat_fixture.gd")
const Status = preload("res://systems/status_system.gd")
const EPS := 0.000001
var time_debt := 0.0
var copy_service := preload("res://systems/copy_service.gd").new()

func request_copy(target_id: String) -> Dictionary:
	if not running: return {"ok":false,"error":"Solo durante combate"}
	var request := copy_service.request(actor_by_id(target_id),principal_actor())
	state_changed.emit()
	return request

func cancel_copy_request() -> void:
	copy_service.cancel()
	state_changed.emit()
signal states_changed
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
	encounter_serial+=1
	last_damage.clear()
	copy_service.reset()
	combat_clock = 0.0
	time_debt = 0.0
	resolved = true
	for actor in actors:
		assert(Damage.valid_defense(float(actor.get("defense",0.0))),"Defensa fuera de contrato")
		actor["vulnerability_until"]=-1.0
		actor["rupture_used"]=false
		actor["states"] = {}
		actor["atb"] = 0.0
		actor["ready_time"] = -1.0
	intentions_dirty=true
	intention_buckets.clear()
	refresh_intentions()
	state_changed.emit()

func query_intention(actor_id: String) -> Dictionary:
	# A detached actor prevents consuming opportunities/cooldowns during preview.
	var actor := actor_by_id(actor_id)
	if not running or actor.is_empty() or not Status.active(actor) or actor.get("is_principal",false): return {}
	if not pending.is_empty() and pending.actor_id==actor_id: return {}
	# AI only reads nested data; detach the top-level turn counter, not the whole kit.
	var future := actor.duplicate()
	future.turns+=1
	var choice := AI.choose(future,actors,"","",combat_clock)
	choice["provisional"]=true
	return choice

func refresh_intentions() -> void:
	var buckets := {}
	for actor in actors:
		if Status.active(actor): buckets[actor.id]=int(float(actor.get("atb",0.0))/50.0)
	if buckets!=intention_buckets:
		intention_buckets=buckets; intentions_dirty=true
	if not intentions_dirty: return
	intentions_dirty=false
	intention_updates+=1
	var next := {}
	if running:
		for actor in actors:
			var value := query_intention(actor.id)
			if not value.is_empty(): next[actor.id]=value
	if next!=intentions:
		intentions=next
		intentions_changed.emit()

func _process(delta: float) -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	_process_body(delta)
	if stamp != 0:
		profile.record("systems/combat_engine.gd:_process", Time.get_ticks_usec() - stamp)

func _process_body(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if not running or delta<0 or not is_finite(delta): return
	var left := delta+time_debt
	time_debt=0.0
	var iterations := 0
	while running and left>EPS and iterations<2048:
		iterations+=1
		choose_next()
		var step := left
		for actor in actors:
			if not Status.active(actor): continue
			var rupture_end: float=float(actor.get("vulnerability_until",-1.0))
			if rupture_end>combat_clock: step=minf(step,rupture_end-combat_clock)
			if actor.ready_time<0 and (pending.is_empty() or pending.actor_id!=actor.id):
				step=minf(step,maxf(0.0,(100.0-actor.atb)/Status.speed(actor,combat_clock)))
				if actor.atb<50.0-EPS: step=minf(step,maxf(0.0,(50.0-actor.atb)/Status.speed(actor,combat_clock)))
			for state in actor.states.values():
				step=minf(step,maxf(0.0,state.expires-combat_clock))
				if state.next<=state.expires+EPS: step=minf(step,maxf(0.0,state.next-combat_clock))
		if not pending.is_empty():
			step=minf(step,maxf(0.0,action_seconds-elapsed))
			if not resolved: step=minf(step,maxf(0.0,resolve_seconds-elapsed))
		if not copy_service.process.is_empty(): step=minf(step,maxf(0.0,copy_service.process.finish-combat_clock))
		for actor in actors:
			if not Status.active(actor) or actor.ready_time>=0 or (not pending.is_empty() and pending.actor_id==actor.id): continue
			actor.atb=minf(100.0,actor.atb+Status.speed(actor,combat_clock)*step)
			if actor.atb>=100.0-EPS: actor.atb=100.0; actor.ready_time=combat_clock+step
		combat_clock+=step
		left-=step
		if not pending.is_empty(): elapsed+=step
		# Pulsos debidos antes de impactos y de resultados de copia.
		for actor in actors:
			if not running or not Status.active(actor): continue
			var dot: Dictionary = actor.states.get("dot",{})
			if not dot.is_empty() and dot.next<=combat_clock+EPS and dot.next<=dot.expires+EPS:
				dot.next+=4.0
				apply_damage(actor,int(dot.intensity))
				intentions_dirty=true
		if not running: break
		if not pending.is_empty() and not resolved and elapsed>=resolve_seconds-EPS: resolve_pending()
		if not running: break
		if not copy_service.process.is_empty():
			copy_service.update(actor_by_id(copy_service.process.target_id),principal_actor(),combat_clock)
			check_finish()
		if not running: break
		for actor in actors:
			if not Status.active(actor):
				actor.vulnerability_until=-1.0;actor.rupture_used=false
			if float(actor.get("vulnerability_until",-1.0))>=0 and actor.vulnerability_until<=combat_clock+EPS:
				actor.vulnerability_until=-1.0;intentions_dirty=true
				rupture_changed.emit(actor.id);state_changed.emit()
			for kind in actor.states.keys():
				if actor.states[kind].expires<=combat_clock+EPS:
					actor.states.erase(kind); states_changed.emit(); state_changed.emit()
					intentions_dirty=true
		if not pending.is_empty() and elapsed>=action_seconds-EPS:
			var actor := actor_by_id(pending.actor_id)
			actor.atb=0.0; actor.ready_time=-1.0
			pending={}; elapsed=0.0; resolved=true
			intentions_dirty=true
			state_changed.emit()
		choose_next()
		refresh_intentions()
	# Preserve unconsumed simulation time rather than skip events on extreme deltas.
	if running: time_debt=left

func principal_actor() -> Dictionary:
	for actor in actors:
		if actor.get("is_principal",false): return actor
	return {}

func apply_damage(target: Dictionary, amount: int) -> void:
	if not running or not Status.active(target): return
	var breakdown:=Damage.preview(target,amount,combat_clock)
	var absorbed: int=breakdown.absorbed
	var damage: int=breakdown.damage
	last_damage={"target_id":target.id,"clock":combat_clock,"breakdown":breakdown.duplicate(true)}
	target.shield=0
	intentions_dirty=true
	target.hp=maxi(0,int(target.hp)-damage)
	if target.hp==0:
		target.atb=0.0; target.ready_time=-1.0; target.states.clear();target.vulnerability_until=-1.0;target.rupture_used=false
	if target.hp==0 and not copy_service.process.is_empty():
		if target.id==copy_service.process.target_id: copy_service.fail("Objetivo derrotado")
		elif target.get("is_principal",false): copy_service.fail("Principal derrotado")
	damage_applied.emit(target.id,damage,absorbed)
	damage_resolved.emit(target.id,breakdown)
	message.emit("%s: −%d vida%s"%[target.name,damage," · protección %d"%absorbed if absorbed>0 else ""])
	check_finish()
	state_changed.emit()

func request_rupture(target_id: String, token: int) -> Dictionary:
	var target:=actor_by_id(target_id)
	if not running or token!=encounter_serial: return {"ok":false,"error":"Encuentro no vigente"}
	if target.is_empty() or not Status.active(target): return {"ok":false,"error":"Objetivo no activo"}
	if target.team==principal_actor().team: return {"ok":false,"error":"La matriz propia no rompe defensa"}
	if not target.get("matrix_enabled",false) or float(target.get("defense",0.0))<=0.0:
		return {"ok":false,"error":"Matriz de diagnóstico sin efecto"}
	if target.get("rupture_used",false): return {"ok":false,"error":"Ruptura utilizada"}
	if time_debt>EPS: return {"ok":false,"error":"Simulación pendiente; vuelve a intentar"}
	target.rupture_used=true;target.vulnerability_until=combat_clock+Damage.BREAK_SECONDS
	intentions_dirty=true;refresh_intentions()
	message.emit("%s · defensa rota durante 12 s"%target.name)
	rupture_changed.emit(target.id);state_changed.emit()
	return {"ok":true,"until":target.vulnerability_until}

func defense_status(target_id: String) -> String:
	var actor:=actor_by_id(target_id)
	if actor.is_empty() or not Status.active(actor) or float(actor.get("defense",0.0))<=0: return ""
	if Damage.vulnerable(actor,combat_clock): return "Defensa rota · %d s"%ceili(actor.vulnerability_until-combat_clock)
	return "Defensa %d %% · %s"%[roundi(float(actor.defense)*100),"ruptura utilizada" if actor.get("rupture_used",false) else "matriz disponible"]

func check_finish() -> void:
	if not running: return
	var main := principal_actor()
	if main.is_empty() or not Status.active(main): finish("Derrota"); return
	for actor in actors:
		if actor.team!=main.team and Status.active(actor): return
	finish("Victoria")

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
		for skill in principal_actor().abilities:
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
	for skill in principal_actor().abilities:
		if skill.id == id:
			return skill.name
	return id

func choose_next() -> void:
	if not running or not pending.is_empty():
		return
	var actor: Dictionary = {}
	for candidate in actors:
		if Status.active(candidate) and candidate.get("ready_time", -1.0) >= 0.0 and (actor.is_empty() or candidate.ready_time < actor.ready_time):
			actor = candidate
	if actor.is_empty():
		return
	actor.turns += 1
	pending = {}
	if actor.get("is_principal",false) and copy_service.pending_id!="":
		pending=copy_service.dispatch(actor_by_id(copy_service.pending_id),actor)
	if pending.is_empty(): pending = AI.choose(actor, actors, priority, retained,combat_clock)
	actor.atb = 0.0
	actor.ready_time = -1.0
	elapsed = 0.0
	resolved = false
	intentions_dirty=true
	action_chosen.emit(pending.duplicate(true))
	var skill_label: String = "Esperar" if pending.skill.is_empty() else pending.skill.name
	message.emit("%s → %s · %s" % [actor.name, skill_label, pending.reason])
	state_changed.emit()

func resolve_pending() -> void:
	if resolved or pending.is_empty(): return
	resolved=true
	var completed: Dictionary = pending.duplicate(true)
	var actor := actor_by_id(completed.actor_id)
	var skill: Dictionary = completed.skill
	if completed.get("kind","")=="copy":
		copy_service.begin(actor_by_id(completed.target_id),principal_actor(),combat_clock)
	elif not skill.is_empty() and Status.active(actor):
		var target := actor_by_id(completed.target_id)
		if not target.is_empty() and Status.active(target):
			if skill.shield>0: target.shield=skill.shield; message.emit("%s obtiene %d de protección"%[target.name,skill.shield])
			else:
				apply_damage(target,int(skill.damage))
				if running and Status.active(target) and skill.get("status","")!="":
					Status.apply(target,skill.status,combat_clock,-1.0,float(skill.get("status_duration",-1.0))); states_changed.emit()
		actor.ready_at[skill.id]=actor.turns+skill.cooldown+1
	intentions_dirty=true
	action_count+=1
	if history.size()>=HISTORY_LIMIT: history.pop_front()
	history.append(completed)
	action_executed.emit(completed)
	check_finish()
	state_changed.emit()

func finish(outcome: String) -> void:
	running = false
	if copy_service.pending_id!="" or not copy_service.process.is_empty(): copy_service.fail("Encuentro terminado")
	for actor in actors:
		actor.states.clear();actor.vulnerability_until=-1.0;actor.rupture_used=false
	pending = {}
	resolved = true
	elapsed = 0.0
	result = outcome
	intentions_dirty=true
	refresh_intentions()
	message.emit("%s · prueba finalizada. Puedes repetir o elegir otro escenario." % outcome)
	combat_finished.emit(outcome)

func atb_snapshot() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for actor in actors:
		var status := "charging"
		var rank := 2
		var order: float = Status.time_to_charge(actor,100.0-float(actor.get("atb",0.0)),combat_clock)
		if not Status.active(actor):
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
		if not Status.active(actor):
			continue
		var ready: float = actor.get("ready_time", -1.0) - combat_clock if actor.get("ready_time", -1.0) >= 0.0 else Status.time_to_charge(actor,100.0-float(actor.get("atb",0.0)),combat_clock)
		if not pending.is_empty() and pending.actor_id == actor.id:
			available_at = maxf(0.0, action_seconds - elapsed)
			ready = available_at + Status.time_to_charge(actor,100.0,combat_clock+available_at)
			sequence.append({"id": actor.id, "name": actor.name, "time": 0.0, "current": true})
		queue.append({"id": actor.id, "name": actor.name, "ready": ready, "speed": actor.speed, "actor": actor})
	while sequence.size() < count and not queue.is_empty():
		var best := 0
		for index in range(1, queue.size()):
			if queue[index].ready < queue[best].ready:
				best = index
		var start_at: float = maxf(available_at, maxf(0.0, queue[best].ready))
		sequence.append({"id": queue[best].id, "name": queue[best].name, "time": start_at, "current": false})
		available_at = start_at + action_seconds
		queue[best].ready = available_at + Status.time_to_charge(queue[best].actor,100.0,combat_clock+available_at)
	return sequence

func snapshot() -> Dictionary:
	return {"intentions":intentions.duplicate(true),"intention_updates":intention_updates,"copy":copy_service.snapshot(combat_clock),"running": running, "result": result, "priority": priority, "retained": retained,
		"clock": combat_clock, "atb": atb_snapshot(), "elapsed": elapsed, "resolved": resolved, "pending": pending.duplicate(true), "actors": actors.duplicate(true), "actions": action_count, "history_retained": history.size(), "history_limit": HISTORY_LIMIT, "scenario": scenario}
