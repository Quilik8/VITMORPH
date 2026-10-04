extends Node
var profile: Node
## Recorrido, encuentro y retorno al recorrido comparten actores y escena.
signal route_changed
signal world_rebuilt
signal travelling_started
const Geometry = preload("res://systems/world_geometry.gd")
const World = preload("res://data/world_fixture.gd")
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
	combat.priority = ""
	combat.retained = ""
	combat.result = ""
	combat.pending = {}
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
	if not visible_world:
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
					if enemy.hp <= 0:
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
		if visible_world and state == "travelling":
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
		if actor.hp > 0:
			group.append(actor)
	return group

func begin_encounter(enemies: Array[Dictionary]) -> void:
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
		cleared_groups[id] = true
		active_groups -= int(alerted_groups.get(id, "idle") != "idle")
		alerted_groups.erase(id)
		aftermath = 0.0
		state = "aftermath"
	else:
		state = "failed"
	route_changed.emit()

func snapshot() -> Dictionary:
	return {"state": state, "visible_world": visible_world, "zone_index": zone_index, "cleared": cleared,
		"spatial_events": spatial_events.duplicate(true), "obstacles": obstacles, "camera_x": camera_x, "camera_y": camera_y, "route_recalculations": route_recalculations, "spatial_scans": spatial_scans, "active_groups": active_groups, "spatial_event_limit": SPATIAL_EVENT_LIMIT, "encounter_log_limit": ENCOUNTER_LOG_LIMIT, "confrontation": confrontation, "alerted_groups": alerted_groups.duplicate(), "actors": actors.duplicate(true), "encounters": encounter_record.duplicate(true)}
