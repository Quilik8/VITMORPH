extends Control
## Campo 2D y siluetas geométricas de prueba; no son criaturas ni arte final.
var combat: Node
var route: Node
var action: Dictionary = {}
var popups: Array[Dictionary] = []
var shield_pulse := 0.0
var last_world_positions: Array[Vector2] = []
var last_camera := Vector2(INF, INF)
const INK := Color("eee5d3")
const MUTED := Color("9ba896")
const MAIN := Color("d4bb79")
const ENEMY := Color("bc8875")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 340)
	clip_contents = true
	resized.connect(queue_redraw)

func reset_feedback() -> void:
	action = {}
	popups.clear()
	queue_redraw()

func show_action(value: Dictionary) -> void:
	action = value.duplicate(true)
	queue_redraw()

func flash(id: String, damage: int, absorbed: int) -> void:
	var caption := "−%d" % damage
	if absorbed > 0:
		caption = "Bloqueado" if damage == 0 else "−%d · protegido" % damage
	popups.append({"id": id, "text": caption, "age": 0.0, "damage": damage})
	queue_redraw()

func _process(delta: float) -> void:
	var had_popups := not popups.is_empty()
	for index in range(popups.size() - 1, -1, -1):
		popups[index].age += delta
		if popups[index].age >= 2.0:
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
	if combat != null and (combat.running or had_popups or world_moved):
		queue_redraw()

func point(actor: Dictionary) -> Vector2:
	if route != null and route.visible_world:
		return world_point(actor.position)
	return Vector2((actor.position.x + 55.0) / 800.0 * size.x, (size.y - 130.0) * (0.20 + actor.position.y / 430.0 * 0.70))

func world_point(position: Vector2) -> Vector2:
	return Vector2((position.x - route.camera_x) / 800.0 * size.x, (size.y - 130.0) * (0.20 + (position.y - route.camera_y) / 430.0 * 0.70))

func world_polygon(points: Array[Vector2], color: Color) -> void:
	var projected := PackedVector2Array()
	for position in points:
		projected.append(world_point(position))
	draw_colored_polygon(projected, color)

func draw_world_ground() -> void:
	world_polygon([Vector2(0,80),Vector2(500,40),Vector2(1050,60),Vector2(1500,90),Vector2(2000,20),Vector2(4050,70),Vector2(4050,2050),Vector2(2150,2050),Vector2(1550,2050),Vector2(750,2050),Vector2(0,2050)], Color("20392a"))
	var path := PackedVector2Array([world_point(route.actors[0].get("route_start",Vector2(150,260)))])
	for zone in route.zones:
		path.append(world_point(zone.approach))
		draw_circle(world_point(zone.center), 8.0, Color("4b6248"))
	draw_polyline(path, Color("2d4934"), 44.0)
	for obstacle in route.obstacles:
		var corners: Array[Vector2] = [obstacle.position, Vector2(obstacle.end.x, obstacle.position.y), obstacle.end, Vector2(obstacle.position.x, obstacle.end.y)]
		world_polygon(corners, Color("50604c"))
		var outline := PackedVector2Array()
		for corner in corners:
			outline.append(world_point(corner))
		outline.append(world_point(corners[0]))
		draw_polyline(outline, Color("97a080"), 2.0)

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
	var width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, at - Vector2(width / 2, 0), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 40:
		var angle := TAU * index / 40.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)

func _draw() -> void:
	var w := size.x
	var h := size.y
	# Área de encuentro abstracta. El borde irregular comunica suelo, no un panel de HUD.
	var in_world: bool = route != null and route.visible_world
	if in_world:
		draw_world_ground()
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(w*.05,h*.23), Vector2(w*.34,h*.13), Vector2(w*.74,h*.20), Vector2(w*.97,h*.46), Vector2(w*.91,h*.80), Vector2(w*.54,h*.92), Vector2(w*.11,h*.84), Vector2(w*.02,h*.53)]), Color("20392a"))
		draw_colored_polygon(PackedVector2Array([Vector2(w*.13,h*.43), Vector2(w*.41,h*.28), Vector2(w*.85,h*.40), Vector2(w*.87,h*.75), Vector2(w*.46,h*.81), Vector2(w*.16,h*.72)]), Color("27422f"))
	var font := ThemeDB.fallback_font
	var visible_actors: Array[Dictionary] = route.actors if in_world else combat.actors
	if combat == null or visible_actors.is_empty():
		centered(font, "Un principal · decisiones automáticas", Vector2(w*.5,h*.52), 20, MUTED)
		return
	for actor in visible_actors:
		var base := point(actor)
		if base.x < -120 or base.x > size.x + 120 or base.y < -120 or base.y > size.y + 120:
			continue
		var center := screen_actor(actor)
		var color: Color = MAIN if actor.id == "main" else ENEMY
		if actor.hp <= 0:
			color = Color("556358")
		ellipse(base + Vector2(0,26), Vector2(44,14), Color(0.05,0.08,0.06,0.55))
		var acting: bool = not action.is_empty() and action.actor_id == actor.id and combat.running
		if not action.is_empty() and action.target_id == actor.id and action.actor_id != actor.id and combat.running and not combat.resolved:
			draw_polyline(PackedVector2Array([base+Vector2(-6,-86), base+Vector2(0,-80), base+Vector2(6,-86)]), INK, 2.0)
		if acting:
			var footprint := PackedVector2Array()
			for index in 41:
				var angle := TAU * index / 40.0
				footprint.append(base + Vector2(cos(angle)*43, 26+sin(angle)*13))
			draw_polyline(footprint, MAIN, 2)
			if not combat.resolved:
				var anticipation: float = clampf(combat.elapsed / combat.resolve_seconds, 0, 1)
				draw_arc(center, 37, -PI/2, -PI/2 + TAU * anticipation, 40, MAIN, 2)
		if actor.id == "main":
			draw_colored_polygon(PackedVector2Array([center + Vector2(0,-30), center + Vector2(28,-6), center + Vector2(18,25), center + Vector2(-18,25), center + Vector2(-28,-6)]), color)
		else:
			var shape := PackedVector2Array()
			for index in 6:
				var angle := TAU * index / 6.0
				shape.append(center + Vector2(cos(angle)*29, sin(angle)*32))
			draw_colored_polygon(shape, color)
		if combat.running:
			if actor.shield > 0:
				draw_arc(center, 40, 0, TAU, 40, Color("86bbb0"), 3)
				centered(font, "Protección %d" % actor.shield, base + Vector2(0,91), 14, Color("86bbb0"))
			centered(font, actor.name, base + Vector2(0,-62), 16, INK)
			draw_line(base + Vector2(-45,53), base + Vector2(45,53), Color("122119"), 4)
			draw_line(base + Vector2(-45,53), base + Vector2(-45 + 90.0 * actor.hp / actor.max_hp,53), color, 4)
			centered(font, "%d PV" % actor.hp, base + Vector2(0,75), 14, INK)
	for popup in popups:
		var actor: Dictionary = combat.actor_by_id(popup.id)
		if actor.is_empty():
			continue
		var fade: float = 1.0 - clampf((popup.age - 1.3) / 0.7, 0, 1)
		var color := INK if popup.damage > 0 else Color("86bbb0")
		color.a = fade
		centered(font, popup.text, point(actor) + Vector2(90,-12-popup.age*16), 25, color)
