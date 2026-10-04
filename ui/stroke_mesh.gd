extends RefCounted
## Construcción única de trazos; el runtime reutiliza los buffers.
static func build(source: PackedVector2Array, width: float, closed: bool = false) -> ArrayMesh:
	var points := source.duplicate()
	if closed and points[0].is_equal_approx(points[-1]):
		points.resize(points.size() - 1)
	var count := points.size()
	var segments := count if closed else count - 1
	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for index in segments + 1:
		var cursor := index % count
		var previous := (cursor - 1 + count) % count if closed else maxi(0, cursor - 1)
		var next := (cursor + 1) % count if closed else mini(count - 1, cursor + 1)
		var tangent := (points[next] - points[previous]).normalized()
		var normal := Vector2(-tangent.y, tangent.x) * width * 0.5
		vertices.append(points[cursor] + normal)
		vertices.append(points[cursor] - normal)
		uvs.append(Vector2(float(index) / segments, 0))
		uvs.append(Vector2(float(index) / segments, 1))
		if index < segments:
			var first := index * 2
			indices.append_array(PackedInt32Array([first, first+1, first+2, first+1, first+3, first+2]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
