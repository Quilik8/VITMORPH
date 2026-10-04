extends Node
var profile: Node
## Recorrido, encuentro y retorno al recorrido comparten actores y escena.
signal before_encounter
signal settled
signal route_changed
signal world_rebuilt
signal travelling_started
const Geometry = preload("res://systems/world_geometry.gd")
const World = preload("res://data/world_fixture.gd")
var session: RefCounted
var menu_paused := false
var combat: Node
var visible_world := false
var state := "ready"
var actors: Array[Dictionary] = []
var zones: Array[Dictionary] = []
var obstacles: Array[Rect2] = []
var group_members: Dictionary = {}
var cleared_groups: Dictionary = {}
var active_groups := 0
var last_scanned_position := Vector2(INF, INF)
var spatial_scans := 0
const SPATIAL_EVENT_LIMIT := 128
const ENCOUNTER_LOG_LIMIT := 64
var zone_index := 0
var cleared := 0
var camera_x := 0.0
var camera_y := 0.0
var route_recalculations := 0
var aftermath := 0.0
var travel_speed := World.TRAVEL_SPEED
var encounter_record: Array[Dictionary] = []
var held_keys: Dictionary = {}
var alerted_groups: Dictionary = {}
var confrontation := ""
var spatial_events: Array[Dictionary] = []

func _ready() -> void:
	preview()
	combat.combat_finished.connect(on_combat_finished)

func preview() -> void:
	zones = World.locations()
	obstacles = World.obstacles()
	actors = World.populate()
	if session != null: actors[0] = session.actor_at(World.START_POSITION)
	group_members.clear()
	cleared_groups.clear()
	active_groups = 0
	last_scanned_position = Vector2(INF, INF)
	spatial_scans = 0
	for zone in zones:
		var members: Array[Dictionary] = []
		group_members[zone.id] = members
	for actor in actors:
		var id: String = actor.get("zone_id", "")
		if group_members.has(id):
			group_members[id].append(actor)
	state = "ready"
	zone_index = 0
	cleared = 0
	camera_x = 0.0
	camera_y = 0.0
	route_recalculations = 0
	aftermath = 0.0
	encounter_record.clear()
	held_keys.clear()
	alerted_groups.clear()
	confrontation = ""
	spatial_events.clear()
	world_rebuilt.emit()

func start() -> void:
	preview()
	combat.actors.clear()
	combat.actors.append(actors[0])
	combat.running = false
	combat.priority = session.principal().priority if session!=null else ""
	combat.retained = session.principal().retained if session!=null else ""
	combat.result = ""
	combat.pending = {}
	combat.resolved = true
	combat.combat_clock = 0.0
	combat.copy_service.reset()
	combat.history.clear()
	combat.action_count = 0
	combat.elapsed = 0.0
	visible_world = true
	state = "travelling"
	travelling_started.emit()
	route_changed.emit()

func is_active() -> bool:
	return visible_world and state in ["travelling", "battle", "aftermath"]

func _process(delta: float) -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	_process_body(delta)
	if stamp != 0:
		profile.record("systems/world_route.gd:_process", Time.get_ticks_usec() - stamp)

func _process_body(delta: float) -> void:
	if not visible_world or menu_paused:
		return
	if state == "travelling":
		var main: Dictionary = actors[0]
		var direction := Vector2(float(pressed(KEY_D, KEY_RIGHT)) - float(pressed(KEY_A, KEY_LEFT)), float(pressed(KEY_S, KEY_DOWN)) - float(pressed(KEY_W, KEY_UP)))
		main.position = Geometry.move_sliding(main.position, direction.normalized() * travel_speed * delta, obstacles)
		main.position.x = clampf(main.position.x, World.MOVEMENT_BOUNDS.position.x, World.MOVEMENT_BOUNDS.end.x)
		main.position.y = clampf(main.position.y, World.MOVEMENT_BOUNDS.position.y, World.MOVEMENT_BOUNDS.end.y)
		confrontation = ""
		if main.position != last_scanned_position or active_groups > 0:
			last_scanned_position = main.position
			spatial_scans += 1
			for index in zones.size():
				if cleared_groups.has(zones[index].id):
					continue
				var enemies: Array[Dictionary] = group_members[zones[index].id]
				if enemies.is_empty():
					continue
				if zones[index].get("confronts", false):
					update_pursuit(zones[index], enemies, main, delta)
				for enemy in enemies:
					if enemy.hp <= 0 or enemy.get("retired",false):
						continue
					if alerted_groups.get(zones[index].id, "idle") != "returning" and main.position.distance_to(enemy.position) <= World.ENCOUNTER_RADIUS and Geometry.segment_clear(main.position, enemy.position, obstacles):
						zone_index = index
						begin_encounter(group_for(zones[index].id))
						break
				if state == "battle":
					break
	elif state == "aftermath":
		aftermath += delta
		if aftermath >= World.AFTERMATH_SECONDS:
			state = "travelling"
			travelling_started.emit()
			route_changed.emit()
	if not actors.is_empty():
		var desired: float = maxf(0.0, actors[0].position.x - 200.0)
		camera_x = move_toward(camera_x, desired, delta * travel_speed * 1.3)
		var desired_y: float = maxf(0.0, actors[0].position.y - 260.0)
		camera_y = move_toward(camera_y, desired_y, delta * travel_speed * 1.3)

func update_pursuit(zone: Dictionary, enemies: Array[Dictionary], main: Dictionary, delta: float) -> void:
	var mode: String = alerted_groups.get(zone.id, "idle")
	if mode == "idle":
		for enemy in enemies:
			if enemy.position.distance_to(main.position) <= World.DETECTION_RADIUS and Geometry.segment_clear(enemy.position, main.position, obstacles):
				mode = "pursuing"
				break
	elif mode == "pursuing":
		var nearest := INF
		var outside_leash := false
		for enemy in enemies:
			nearest = minf(nearest, enemy.position.distance_to(main.position))
			outside_leash = outside_leash or enemy.position.distance_to(enemy.home) >= World.LEASH_RADIUS
		if nearest > World.LOSE_RADIUS or outside_leash:
			mode = "returning"
	if mode in ["pursuing", "returning"]:
		confrontation = "Un grupo se acerca" if mode == "pursuing" else "El grupo abandona la persecución"
		var all_home := true
		for enemy in enemies:
			var destination: Vector2 = main.position if mode == "pursuing" else enemy.home
			var age: float = enemy.get("nav_age", 1.0) + delta
			var previous_target: Vector2 = enemy.get("nav_target", destination)
			var next: Vector2 = enemy.get("nav_waypoint", enemy.position)
			var reached_waypoint: bool = enemy.position.distance_squared_to(next) < 4.0 and next.distance_squared_to(destination) > 4.0 and next != enemy.position
			if age >= 0.25 or previous_target.distance_squared_to(destination) > 2304.0 or enemy.get("nav_mode", "") != mode or reached_waypoint:
				next = Geometry.waypoint(enemy.position, destination, obstacles)
				enemy["nav_target"] = destination
				enemy["nav_waypoint"] = next
				enemy["nav_mode"] = mode
				age = 0.0
				route_recalculations += 1
			enemy["nav_age"] = age
			var motion: Vector2 = enemy.position.direction_to(next) * minf(World.PURSUIT_SPEED * delta, enemy.position.distance_to(next))
			enemy.position = Geometry.move_sliding(enemy.position, motion, obstacles)
			if enemy.position.distance_to(enemy.home) > 2.0:
				all_home = false
		if mode == "returning" and all_home:
			for enemy in enemies:
				enemy.position = enemy.home
			mode = "idle"
	if mode != alerted_groups.get(zone.id, "idle"):
		var previous_mode: String = alerted_groups.get(zone.id, "idle")
		active_groups += int(mode != "idle") - int(previous_mode != "idle")
		if spatial_events.size() >= SPATIAL_EVENT_LIMIT:
			spatial_events.pop_front()
		spatial_events.append({"group": zone.id, "state": mode, "principal_position": main.position})
	alerted_groups[zone.id] = mode

func pressed(first: int, second: int) -> bool:
	return held_keys.get(first, false) or held_keys.get(second, false)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
		if visible_world and state == "travelling" and not menu_paused:
			held_keys[event.keycode] = event.pressed
			get_viewport().set_input_as_handled()
		elif not event.pressed:
			held_keys.erase(event.keycode)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		held_keys.clear()

func group_for(zone_id: String) -> Array[Dictionary]:
	var group: Array[Dictionary] = []
	for actor in group_members.get(zone_id, []):
		if actor.hp > 0 and not actor.get("retired",false):
			group.append(actor)
	return group

func begin_encounter(enemies: Array[Dictionary]) -> void:
	before_encounter.emit()
	state = "battle"
	held_keys.clear()
	var participants: Array[Dictionary] = [actors[0]]
	participants.append_array(enemies)
	if encounter_record.size() >= ENCOUNTER_LOG_LIMIT:
		encounter_record.pop_front()
	encounter_record.append({"zone": zones[zone_index].id, "principal_position": actors[0].position,
		"enemy_positions": enemies.map(func(actor): return actor.position), "hp_at_start": actors[0].hp})
	combat.begin_encounter(participants)
	route_changed.emit()

func on_combat_finished(outcome: String) -> void:
	if not visible_world or state != "battle":
		return
	if outcome == "Victoria":
		cleared += 1
		var id: String = zones[zone_index].id
		if session!=null and id=="zone_3": session.objectives.final_won=true; session.update_objectives()
		cleared_groups[id] = true
		active_groups -= int(alerted_groups.get(id, "idle") != "idle")
		alerted_groups.erase(id)
		aftermath = 0.0
		state = "aftermath"
	else:
		if session!=null:
			session.sync_actor(actors[0],combat.priority,combat.retained)
			session.recover()
		start()
		combat.message.emit("Derrota · regreso al refugio · colección conservada")
	settled.emit()
	route_changed.emit()

func snapshot() -> Dictionary:
	return {"state": state, "visible_world": visible_world, "zone_index": zone_index, "cleared": cleared,
		"spatial_events": spatial_events.duplicate(true), "obstacles": obstacles, "camera_x": camera_x, "camera_y": camera_y, "route_recalculations": route_recalculations, "spatial_scans": spatial_scans, "active_groups": active_groups, "spatial_event_limit": SPATIAL_EVENT_LIMIT, "encounter_log_limit": ENCOUNTER_LOG_LIMIT, "confrontation": confrontation, "alerted_groups": alerted_groups.duplicate(), "actors": actors.duplicate(true), "encounters": encounter_record.duplicate(true)}

func at_refuge() -> bool:
	return visible_world and state=="travelling" and preload("res://data/demo_rules.gd").REFUGE.has_point(actors[0].position)

func rest() -> Dictionary:
	if not at_refuge() or menu_paused: return {"ok":false,"error":"Descansa en el refugio fuera de combate"}
	if session!=null: session.sync_actor(actors[0],combat.priority,combat.retained); session.recover()
	start()
	settled.emit()
	return {"ok":true}

func export_data() -> Dictionary:
	var enemies: Array=[]
	for actor in actors:
		if actor.get("is_principal",false): continue
		enemies.append({"id":actor.id,"hp":actor.hp,"shield":actor.shield,"turns":actor.turns,"ready_at":actor.ready_at.duplicate(),"retired":actor.get("retired",false),"position":[actor.position.x,actor.position.y]})
	return {"position":[actors[0].position.x,actors[0].position.y],"cleared_groups":cleared_groups.keys(),"enemies":enemies}

func validate_data(data: Dictionary) -> Dictionary:
	if not coordinate(data.get("position")) or not data.get("cleared_groups") is Array or not data.get("enemies") is Array: return {"ok":false,"error":"Recorrido persistente inválido"}
	if not World.MOVEMENT_BOUNDS.has_point(Vector2(data.position[0],data.position[1])): return {"ok":false,"error":"Posición fuera del mundo"}
	var expected: Dictionary={}
	for actor in World.populate():
		if not actor.get("is_principal",false): expected[actor.id]=actor
	var ids: Dictionary={}
	for enemy in data.enemies:
		if not enemy is Dictionary or not enemy.get("id") is String or not expected.has(enemy.id) or ids.has(enemy.id): return {"ok":false,"error":"Encuentro incompatible"}
		ids[enemy.id]=true
		for key in ["hp","shield","turns"]:
			if not preload("res://systems/demo_session.gd").number(enemy.get(key)) or enemy[key]<0 or floor(enemy[key])!=enemy[key]: return {"ok":false,"error":"Estado de encuentro inválido"}
		if enemy.hp>expected[enemy.id].max_hp or not enemy.get("retired") is bool or not enemy.get("ready_at") is Dictionary or not coordinate(enemy.get("position")): return {"ok":false,"error":"Enemigo persistente inválido"}
		if enemy.retired and enemy.hp<=0: return {"ok":false,"error":"Retirada incompatible"}
		for id in enemy.ready_at:
			if not id is String or session.catalog.skill(id).is_empty() or not preload("res://systems/demo_session.gd").number(enemy.ready_at[id]) or enemy.ready_at[id]<0: return {"ok":false,"error":"Reutilización de enemigo inválida"}
	if ids.size()!=expected.size(): return {"ok":false,"error":"Faltan actores del recorrido"}
	var groups: Dictionary={}
	for zone in World.locations(): groups[zone.id]=true
	var cleared_ids: Dictionary={}
	for id in data.cleared_groups:
		if not id is String or not groups.has(id) or cleared_ids.has(id): return {"ok":false,"error":"Grupo incompatible"}
		cleared_ids[id]=true
	for zone in World.locations():
		var alive := false
		for enemy in data.enemies:
			if expected[enemy.id].zone_id==zone.id and enemy.hp>0 and not enemy.retired: alive=true
		if cleared_ids.has(zone.id)==alive: return {"ok":false,"error":"Progreso de grupo incoherente"}
	return {"ok":true}

static func coordinate(value) -> bool:
	return value is Array and value.size()==2 and preload("res://systems/demo_session.gd").number(value[0]) and preload("res://systems/demo_session.gd").number(value[1])

func restore_data(data: Dictionary) -> void:
	start()
	actors[0].position=Vector2(data.position[0],data.position[1])
	for saved in data.enemies:
		for actor in actors:
			if actor.id!=saved.id: continue
			for key in ["hp","shield","turns","retired"]: actor[key]=saved[key]
			actor.ready_at=saved.ready_at.duplicate()
			actor.position=Vector2(saved.position[0],saved.position[1])
	for id in data.cleared_groups: cleared_groups[id]=true
	cleared=cleared_groups.size()
	last_scanned_position=actors[0].position
	camera_x=maxf(0,actors[0].position.x-200)
	camera_y=maxf(0,actors[0].position.y-260)
	route_changed.emit()
