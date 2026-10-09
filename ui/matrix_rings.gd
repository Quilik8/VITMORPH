extends Control
signal selected(index: int)
var dirty := true
var state: Dictionary={}:
	set(value):
		if state!=value:
			state=value;dirty=true;queue_redraw()
var mesh := ArrayMesh.new()
var vertices := PackedVector2Array()
var colors := PackedColorArray()
var indices := PackedInt32Array()
const INK := Color("eee5d3")
const GOLD := Color("e0ad72")

func _ready() -> void:
	custom_minimum_size=Vector2(140,120)
	focus_mode=Control.FOCUS_ALL
	mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	resized.connect(invalidate)
	focus_entered.connect(invalidate);focus_exited.connect(invalidate)

func invalidate() -> void:
	dirty=true;queue_redraw()

func quad(a: Vector2,b: Vector2,c: Vector2,d: Vector2,color: Color) -> void:
	var first:=vertices.size()
	vertices.append_array(PackedVector2Array([a,b,c,d]))
	for count in 4: colors.append(color)
	indices.append_array(PackedInt32Array([first,first+1,first+2,first,first+2,first+3]))

func line(a: Vector2,b: Vector2,width: float,color: Color) -> void:
	var normal: Vector2=(b-a).normalized().orthogonal()*width*.5
	quad(a-normal,a+normal,b+normal,b-normal,color)

func circle(center: Vector2,radius: float,color: Color) -> void:
	for count in 12:
		var first:=vertices.size()
		vertices.append_array(PackedVector2Array([center,center+Vector2.from_angle(TAU*count/12)*radius,center+Vector2.from_angle(TAU*(count+1)/12)*radius]))
		for vertex in 3: colors.append(color)
		indices.append_array(PackedInt32Array([first,first+1,first+2]))

func arc(center: Vector2,radius: float,width: float,color: Color) -> void:
	for count in 96:
		line(center+Vector2.from_angle(TAU*count/96)*radius,center+Vector2.from_angle(TAU*(count+1)/96)*radius,width,color)

func geometry() -> Vector3:
	return Vector3(size.x/2,size.y/2,minf(size.x/2-16,size.y/2-10))

func _draw() -> void:
	if state.is_empty(): return
	if dirty: rebuild()
	draw_mesh(mesh,null)

func rebuild() -> void:
	dirty=false;vertices.clear();colors.clear();indices.clear()
	var g:=geometry();var center:=Vector2(g.x,g.y)
	for index in 3:
		var radius:=g.z*(1.0-index*.27)
		var color:=GOLD if state.selected==index else Color("6b6266")
		arc(center,radius,2.5 if state.selected==index else 1.5,color)
		for step in 8:
			var point:=center+Vector2.from_angle(-PI/2+step*TAU/8)*radius
			circle(point,2,INK if step==0 else Color("59535c"))
		var point:=center+Vector2.from_angle(-PI/2+state.positions[index]*TAU/8)*radius
		circle(point,5,GOLD)
		line(center+Vector2(-5,-radius-6),center+Vector2(5,-radius-6),2,INK)
	if has_focus(): arc(center,g.z+8,1.5,INK)
	var arrays:=[];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_COLOR]=colors;arrays[Mesh.ARRAY_INDEX]=indices
	mesh.clear_surfaces();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		var g:=geometry();var distance: float=event.position.distance_to(Vector2(g.x,g.y))
		var nearest:=0;var error:=INF
		for index in 3:
			var difference:=absf(distance-g.z*(1.0-index*.27))
			if difference<error: nearest=index;error=difference
		selected.emit(nearest);grab_focus();accept_event()
