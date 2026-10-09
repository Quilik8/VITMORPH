extends Control
signal selected(index: int)
var state: Dictionary={}
const INK := Color("eee5d3")
const GOLD := Color("e0ad72")

func _ready() -> void:
	custom_minimum_size=Vector2(140,120)
	focus_mode=Control.FOCUS_ALL
	mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	resized.connect(queue_redraw)

func geometry() -> Vector3:
	return Vector3(size.x/2,size.y/2,minf(size.x/2-16,size.y/2-10))

func _draw() -> void:
	if state.is_empty(): return
	var g:=geometry();var center:=Vector2(g.x,g.y)
	for index in 3:
		var radius:=g.z*(1.0-index*.27)
		var color:=GOLD if state.selected==index else Color("6b6266")
		draw_arc(center,radius,0,TAU,64,color,2.5 if state.selected==index else 1.0,true)
		for step in 8:
			var point:=center+Vector2.from_angle(-PI/2+step*TAU/8)*radius
			draw_circle(point,2,INK if step==0 else Color("59535c"))
		var point:=center+Vector2.from_angle(-PI/2+state.positions[index]*TAU/8)*radius
		draw_circle(point,5,GOLD)
		draw_line(center+Vector2(-5,-radius-6),center+Vector2(5,-radius-6),INK,2)
	if has_focus(): draw_arc(center,g.z+8,0,TAU,64,INK,1,true)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		var g:=geometry();var distance: float=event.position.distance_to(Vector2(g.x,g.y))
		var nearest:=0;var error:=INF
		for index in 3:
			var difference:=absf(distance-g.z*(1.0-index*.27))
			if difference<error: nearest=index;error=difference
		selected.emit(nearest);grab_focus();accept_event()
