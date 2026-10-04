extends RefCounted
## Geometría técnica compartida por movimiento, detección y persecución.
const RADIUS := 22.0

static func blocked(point: Vector2, obstacles: Array[Rect2], padding: float = RADIUS) -> bool:
	for obstacle in obstacles:
		if obstacle.grow(padding).has_point(point):
			return true
	return false

static func segment_clear(from: Vector2, to: Vector2, obstacles: Array[Rect2], padding: float = 0.0) -> bool:
	for obstacle in obstacles:
		var rect := obstacle.grow(padding)
		if rect.has_point(from) or rect.has_point(to):
			return false
		var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
		for index in 4:
			if Geometry2D.segment_intersects_segment(from, to, corners[index], corners[(index + 1) % 4]) != null:
				return false
	return true

static func move_sliding(from: Vector2, motion: Vector2, obstacles: Array[Rect2]) -> Vector2:
	if motion == Vector2.ZERO:
		return from
	var position := from
	var steps := maxi(1, ceili(motion.length() / 4.0))
	var step := motion / float(steps)
	for index in steps:
		var candidate := position + Vector2(step.x, 0)
		if not blocked(candidate, obstacles):
			position = candidate
		candidate = position + Vector2(0, step.y)
		if not blocked(candidate, obstacles):
			position = candidate
	return position

static func waypoint(from: Vector2, destination: Vector2, obstacles: Array[Rect2]) -> Vector2:
	if segment_clear(from, destination, obstacles, RADIUS):
		return destination
	var points: Array[Vector2] = [from, destination]
	for obstacle in obstacles:
		var rect := obstacle.grow(RADIUS + 3.0)
		for point in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
			if not blocked(point, obstacles):
				points.append(point)
	var distances: Array[float] = []
	var previous: Array[int] = []
	var visited: Array[bool] = []
	for point in points:
		distances.append(INF)
		previous.append(-1)
		visited.append(false)
	distances[0] = 0.0
	for iteration in points.size():
		var best := -1
		for index in points.size():
			if not visited[index] and (best == -1 or distances[index] < distances[best]):
				best = index
		if best == -1 or distances[best] == INF:
			break
		if best == 1:
			var next := 1
			while previous[next] > 0:
				next = previous[next]
			return points[next]
		visited[best] = true
		for index in points.size():
			if visited[index] or not segment_clear(points[best], points[index], obstacles, RADIUS):
				continue
			var cost := distances[best] + points[best].distance_to(points[index])
			if cost < distances[index]:
				distances[index] = cost
				previous[index] = best
	return from
