extends Node2D
## Indicador retenido: modificar fracción/posición, sin reconstruir el trazo.
var progress := -1.0
var arc_mesh: ArrayMesh
var shader_material: ShaderMaterial

func _ready() -> void:
	var points := PackedVector2Array()
	for index in 41:
		var angle := -PI / 2.0 + TAU * index / 40.0
		points.append(Vector2(cos(angle), sin(angle)) * 37.0)
	arc_mesh = preload("res://ui/stroke_mesh.gd").build(points, 2.0, true)
	shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://ui/anticipation_arc.gdshader")
	material = shader_material
	self_modulate = Color("d4bb79")
	hide()

func update_progress(center: Vector2, value: float) -> void:
	position = center
	show()
	if value != progress:
		progress = value
		shader_material.set_shader_parameter("fraction", progress)

func _draw() -> void:
	draw_mesh(arc_mesh, null)
