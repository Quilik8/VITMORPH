extends Control
var visuals: RefCounted=preload("res://systems/visual_catalog.gd").new()
var actor_visuals: Dictionary={}
var profile: Node
## Campo 2D y siluetas geométricas de prueba; no son criaturas ni arte final.
var combat: Node
var route: Node
var action: Dictionary = {}
var popups: Array[Dictionary] = []
var popup_pool: Array[Dictionary] = []
var popup_peak := 0
var cached_font: Font
var text_widths: Dictionary = {}
var ground: Node2D
var last_ground_world := false
var shadow_mesh: ArrayMesh
var main_mesh: ArrayMesh
var enemy_mesh: ArrayMesh
var footprint_mesh: ArrayMesh
var shield_mesh: ArrayMesh
var anticipation_arc: Node2D
var shadow_shape := PackedVector2Array()
var footprint_shape := PackedVector2Array()
var enemy_shape := PackedVector2Array()
var main_shape := PackedVector2Array([Vector2(0,-30),Vector2(28,-6),Vector2(18,25),Vector2(-18,25),Vector2(-28,-6)])
var last_world_positions: Array[Vector2] = []
var last_camera := Vector2(INF, INF)
const INK := Color("eee5d3")
const MUTED := Color("aaa3a0")
const MAIN := Color("e0ad72")
const ENEMY := Color("bc8875")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 340)
	clip_contents = true
	for index in 4:
		popup_pool.append({"id": "", "text": "", "age": 0.0, "damage": 0})
	ground = preload("res://ui/world_ground.gd").new()
	ground.name = "WorldGround"
	ground.arena = self
	ground.route = route
	ground.profile = profile
	ground.show_behind_parent = true
	add_child(ground)
	for index in 40:
		var angle := TAU * index / 40.0
		shadow_shape.append(Vector2(cos(angle)*44, sin(angle)*14))
		footprint_shape.append(Vector2(cos(angle)*43, 26+sin(angle)*13))
	footprint_shape.append(footprint_shape[0])
	for index in 6:
		var angle := TAU * index / 6.0
		enemy_shape.append(Vector2(cos(angle)*29, sin(angle)*32))
	shadow_mesh = polygon_mesh(shadow_shape)
	main_mesh = polygon_mesh(main_shape)
	enemy_mesh = polygon_mesh(enemy_shape)
	footprint_mesh = preload("res://ui/stroke_mesh.gd").build(footprint_shape, 2.0, true)
	var shield_points := PackedVector2Array()
	for index in 40:
		var angle := TAU * index / 40.0
		shield_points.append(Vector2(cos(angle), sin(angle)) * 40.0)
	shield_mesh = preload("res://ui/stroke_mesh.gd").build(shield_points, 3.0, true)
	anticipation_arc = preload("res://ui/anticipation_arc.gd").new()
	anticipation_arc.name = "AnticipationArc"
	add_child(anticipation_arc)
	route.world_rebuilt.connect(ground.queue_redraw)
	route.world_rebuilt.connect(func():sync_visuals(true))
	resized.connect(func(): ground.queue_redraw(); queue_redraw())

func polygon_mesh(points: PackedVector2Array) -> ArrayMesh:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_INDEX] = Geometry2D.triangulate_polygon(points)
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func reset_feedback() -> void:
	action = {}
	for popup in popups:
		recycle_popup(popup)
	popups.clear()
	if anticipation_arc != null:
		anticipation_arc.hide()
	queue_redraw()

func recycle_popup(popup: Dictionary) -> void:
	if popup_pool.size() < 8:
		popup_pool.append(popup)

func show_action(value: Dictionary) -> void:
	action = value.duplicate(true)
	sync_visuals()
	if actor_visuals.has(value.actor_id) and not value.skill.is_empty(): actor_visuals[value.actor_id].play_skill(value.skill.id)
	queue_redraw()

func show_impact(value: Dictionary) -> void:
	if value.skill.is_empty() or not actor_visuals.has(value.actor_id): return
	var target: Dictionary=combat.actor_by_id(value.target_id)
	if target.is_empty() or target.get("retired",false): return
	actor_visuals[value.actor_id].play_skill(value.skill.id,true,screen_actor(target)-actor_visuals[value.actor_id].position)

func sync_visuals(update_build := false) -> void:
	if visuals.entries.is_empty() and actor_visuals.is_empty(): return
	var actors: Array=route.actors if route!=null and route.visible_world else combat.actors
	var active: Dictionary={}
	for actor in actors:
		if actor.get("retired",false): continue
		active[actor.id]=true
		if not actor_visuals.has(actor.id):
			var view:=preload("res://ui/beast_visual.gd").new()
			view.visuals=visuals;view.catalog=route.session.catalog;add_child(view);actor_visuals[actor.id]=view
			view.configure(actor.get("definition_id",""),actor.get("build",{}),route.session.inventory,Vector2(70,76),true)
		var view: Node2D=actor_visuals[actor.id]
		if update_build: view.configure(actor.get("definition_id",""),actor.get("build",{}),route.session.inventory,Vector2(70,76),true)
		view.position=screen_actor(actor)
		view.visible=view.position.x>=-120 and view.position.x<=size.x+120 and view.position.y>=-120 and view.position.y<=size.y+120
	for id in actor_visuals.keys():
		if not active.has(id): actor_visuals[id].queue_free();actor_visuals.erase(id)

func flash(id: String, damage: int, absorbed: int) -> void:
	var caption := "−%d" % damage
	if absorbed > 0:
		caption = "Bloqueado" if damage == 0 else "−%d · protegido" % damage
	var popup: Dictionary = popup_pool.pop_back() if not popup_pool.is_empty() else {}
	popup.id = id
	popup.text = caption
	popup.age = 0.0
	popup.damage = damage
	popups.append(popup)
	popup_peak = maxi(popup_peak, popups.size())
	queue_redraw()

func _process(delta: float) -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	_process_body(delta)
	if stamp != 0:
		profile.record("ui/arena_view.gd:_process", Time.get_ticks_usec() - stamp)

func _process_body(delta: float) -> void:
	sync_visuals()
	if combat.running and not combat.pending.is_empty() and not combat.resolved:
		var actor: Dictionary = combat.actor_by_id(combat.pending.actor_id)
		anticipation_arc.update_progress(screen_actor(actor), clampf(combat.elapsed / combat.resolve_seconds, 0.0, 1.0))
	else:
		anticipation_arc.hide()
	var world_visible: bool = route != null and route.visible_world
	if world_visible != last_ground_world:
		last_ground_world = world_visible
		ground.queue_redraw()
	if world_visible:
		ground.position = Vector2(-route.camera_x * size.x / 800.0, -route.camera_y * (size.y - 130.0) * 0.70 / 430.0)
	else:
		ground.position = Vector2.ZERO
	var had_popups := not popups.is_empty()
	for index in range(popups.size() - 1, -1, -1):
		popups[index].age += delta
		if popups[index].age >= 2.0:
			recycle_popup(popups[index])
			popups.remove_at(index)
	var world_moved := false
	if route != null and route.visible_world:
		var camera := Vector2(route.camera_x, route.camera_y)
		world_moved = camera != last_camera or last_world_positions.size() != route.actors.size()
		last_camera = camera
		last_world_positions.resize(route.actors.size())
		for index in route.actors.size():
			var position: Vector2 = route.actors[index].position
			world_moved = world_moved or last_world_positions[index] != position
			last_world_positions[index] = position
	var animating: bool = combat.running and not combat.pending.is_empty() and not combat.pending.skill.is_empty() and combat.pending.skill.damage > 0 and combat.elapsed > combat.resolve_seconds * 0.64 and combat.elapsed < combat.resolve_seconds + 0.65
	if animating or had_popups or world_moved:
		queue_redraw()

func point(actor: Dictionary) -> Vector2:
	if route != null and route.visible_world:
		return world_point(actor.position)
	return Vector2((actor.position.x + 55.0) / 800.0 * size.x, (size.y - 130.0) * (0.20 + actor.position.y / 430.0 * 0.70))

func world_point(position: Vector2) -> Vector2:
	return Vector2((position.x - route.camera_x) / 800.0 * size.x, (size.y - 130.0) * (0.20 + (position.y - route.camera_y) / 430.0 * 0.70))

func screen_actor(actor: Dictionary) -> Vector2:
	var center := point(actor)
	if action.is_empty() or not combat.running or action.actor_id != actor.id or action.skill.is_empty() or action.skill.shield > 0:
		return center
	var target: Dictionary = combat.actor_by_id(action.target_id)
	if target.is_empty():
		return center
	var forward := (point(target) - center).normalized()
	var amount := 0.0
	var launch: float = combat.resolve_seconds * 0.64
	if combat.elapsed > launch and combat.elapsed < combat.resolve_seconds:
		amount = smoothstep(launch, combat.resolve_seconds, combat.elapsed)
	elif combat.elapsed >= combat.resolve_seconds:
		amount = 1.0 - smoothstep(combat.resolve_seconds, combat.resolve_seconds + 0.65, combat.elapsed)
	return center + forward * minf(90.0, center.distance_to(point(target)) * 0.36) * amount

func centered(font: Font, caption: String, at: Vector2, font_size: int, color: Color) -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	centered_body(font, caption, at, font_size, color)
	if stamp != 0:
		profile.record("arena:centered", Time.get_ticks_usec() - stamp)

func centered_body(font: Font, caption: String, at: Vector2, font_size: int, color: Color) -> void:
	if cached_font != font:
		cached_font = font
		text_widths.clear()
	var key := "%d:%s" % [font_size, caption]
	if not text_widths.has(key):
		if text_widths.size() >= 256:
			text_widths.clear()
		text_widths[key] = font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var width: float = text_widths[key]
	draw_string(font, at - Vector2(width / 2, 0), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw() -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	_draw_body()
	if stamp != 0:
		profile.record("ui/arena_view.gd:_draw", Time.get_ticks_usec() - stamp)

func _draw_body() -> void:
	var w := size.x
	var h := size.y
	# Área de encuentro abstracta. El borde irregular comunica suelo, no un panel de HUD.
	var in_world: bool = route != null and route.visible_world
	var font := ThemeDB.fallback_font
	var visible_actors: Array[Dictionary] = route.actors if in_world else combat.actors
	if combat == null or visible_actors.is_empty():
		centered(font, "Un principal · decisiones automáticas", Vector2(w*.5,h*.52), 20, MUTED)
		return
	for actor in visible_actors:
		if actor.get("retired",false): continue
		var base := point(actor)
		if base.x < -120 or base.x > size.x + 120 or base.y < -120 or base.y > size.y + 120:
			continue
		var center := screen_actor(actor)
		var color: Color = MAIN if actor.get("is_principal",false) else ENEMY
		if actor.hp <= 0:
			color = Color("5c5662")
		draw_mesh(shadow_mesh, null, Transform2D(0.0, base + Vector2(0,26)), Color(0.05,0.08,0.06,0.55))
		var acting: bool = not action.is_empty() and action.actor_id == actor.id and combat.running
		if not action.is_empty() and action.target_id == actor.id and action.actor_id != actor.id and combat.running and not combat.resolved:
			draw_polyline(PackedVector2Array([base+Vector2(-6,-86), base+Vector2(0,-80), base+Vector2(6,-86)]), INK, 2.0)
		if acting:
			draw_mesh(footprint_mesh, null, Transform2D(0.0, base), MAIN)
		if not actor_visuals.has(actor.id) or not actor_visuals[actor.id].has_body():
			draw_mesh(main_mesh if actor.get("is_principal",false) else enemy_mesh, null, Transform2D(0.0, center), color)
		if combat.running:
			if actor.shield > 0:
				draw_mesh(shield_mesh, null, Transform2D(0.0, center), Color("a1bbd0"))
				centered(font, "Protección %d" % actor.shield, base + Vector2(0,91), 14, Color("a1bbd0"))
			centered(font, actor.name, base + Vector2(0,-62), 16, INK)
			draw_line(base + Vector2(-45,53), base + Vector2(45,53), Color("25242b"), 4)
			draw_line(base + Vector2(-45,53), base + Vector2(-45 + 90.0 * actor.hp / actor.max_hp,53), color, 4)
			centered(font, "%d PV" % actor.hp, base + Vector2(0,75), 14, INK)
			var status_text: Array[String]=[]
			if actor.get("states",{}).has("dot"): status_text.append("Residuo")
			if actor.get("states",{}).has("slow"): status_text.append("ATB −25 %")
			if not status_text.is_empty(): centered(font," · ".join(status_text),base+Vector2(0,112),12,Color("a1bbd0"))
	for popup in popups:
		var actor: Dictionary = combat.actor_by_id(popup.id)
		if actor.is_empty():
			continue
		var fade: float = 1.0 - clampf((popup.age - 1.3) / 0.7, 0, 1)
		var color := INK if popup.damage > 0 else Color("a1bbd0")
		color.a = fade
		centered(font, popup.text, point(actor) + Vector2(90,-12-popup.age*16), 25, color)
