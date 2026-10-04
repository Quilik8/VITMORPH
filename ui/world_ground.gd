extends Node2D
## Terreno retenido: dibujar al cambiar mapa/tamaño; cámara mediante transformación.
var arena: Control
var route: Node
var profile: Node

func project(point: Vector2) -> Vector2:
	return Vector2(point.x / 800.0 * arena.size.x, (arena.size.y - 130.0) * (0.20 + point.y / 430.0 * 0.70))

func polygon(points: Array[Vector2], color: Color) -> void:
	var projected := PackedVector2Array()
	for point in points:
		projected.append(project(point))
	draw_colored_polygon(projected, color)

func _draw() -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	if not route.visible_world:
		var w := arena.size.x
		var h := arena.size.y
		draw_colored_polygon(PackedVector2Array([Vector2(w*.05,h*.23), Vector2(w*.34,h*.13), Vector2(w*.74,h*.20), Vector2(w*.97,h*.46), Vector2(w*.91,h*.80), Vector2(w*.54,h*.92), Vector2(w*.11,h*.84), Vector2(w*.02,h*.53)]), Color("292831"))
		draw_colored_polygon(PackedVector2Array([Vector2(w*.13,h*.43), Vector2(w*.41,h*.28), Vector2(w*.85,h*.40), Vector2(w*.87,h*.75), Vector2(w*.46,h*.81), Vector2(w*.16,h*.72)]), Color("343039"))
		if stamp != 0:
			profile.record("world_ground:_draw", Time.get_ticks_usec() - stamp)
		return
	polygon([Vector2(0,80),Vector2(500,40),Vector2(1050,60),Vector2(1500,90),Vector2(2000,20),Vector2(4050,70),Vector2(4050,2050),Vector2(2150,2050),Vector2(1550,2050),Vector2(750,2050),Vector2(0,2050)], Color("292831"))
	polygon([Vector2(90,110),Vector2(325,90),Vector2(345,460),Vector2(110,485)],Color("42353a"))
	draw_string(ThemeDB.fallback_font,project(Vector2(125,190)),"REFUGIO",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("e0ad72"))
	draw_string(ThemeDB.fallback_font,project(Vector2(125,225)),"Descansar · E",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("aaa3a0"))
	var path := PackedVector2Array([project(route.actors[0].get("route_start",Vector2(150,260)))])
	for zone in route.zones:
		path.append(project(zone.approach))
		draw_string(ThemeDB.fallback_font,project(zone.center+Vector2(-55,-90)),zone.name,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("aaa3a0"))
		draw_circle(project(zone.center), 8.0, Color("9e7964"))
	draw_polyline(path, Color("453c42"), 44.0)
	for obstacle in route.obstacles:
		var corners: Array[Vector2] = [obstacle.position, Vector2(obstacle.end.x, obstacle.position.y), obstacle.end, Vector2(obstacle.position.x, obstacle.end.y)]
		polygon(corners, Color("6b5b58"))
		var outline := PackedVector2Array()
		for corner in corners:
			outline.append(project(corner))
		outline.append(project(corners[0]))
		draw_polyline(outline, Color("b5a097"), 2.0)
	if stamp != 0:
		profile.record("world_ground:_draw", Time.get_ticks_usec() - stamp)
