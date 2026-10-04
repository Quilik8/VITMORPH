extends RefCounted
## Datos exclusivamente técnicos. No son catálogo ni balance definitivo.

const ACTION_SECONDS := 4.8
const RESOLVE_SECONDS := 2.2
const SCENARIOS := ["1 contra 1 · cercano", "1 contra 1 · lejano", "1 contra 2"]

static func abilities() -> Array[Dictionary]:
	return [
		{"id": "basic", "name": "Ataque básico", "slot": "FIJA 01", "damage": 18, "shield": 0, "range": 400.0, "cooldown": 0},
		{"id": "guard", "name": "Defensa", "slot": "FIJA 02", "damage": 0, "shield": 24, "range": 0.0, "cooldown": 0},
		{"id": "close", "name": "Ataque cercano", "slot": "MODULAR 01", "damage": 30, "shield": 0, "range": 240.0, "cooldown": 2},
		{"id": "far", "name": "Ataque distante", "slot": "MODULAR 02", "damage": 12, "shield": 0, "range": 600.0, "cooldown": 1},
	]

static func actor(id: String, label: String, speed: float, position: Vector2, skills: Array[Dictionary]) -> Dictionary:
	return {"id": id, "name": label, "hp": 100, "max_hp": 100, "shield": 0, "speed": speed,
		"position": position, "next_at": 0.0, "turns": 0, "ready_at": {}, "abilities": skills}

static func actors(scenario: int) -> Array[Dictionary]:
	var enemy_skills: Array[Dictionary] = [{"id": "enemy_hit", "name": "Ataque técnico", "slot": "FIJA", "damage": 14, "shield": 0, "range": 600.0, "cooldown": 0}]
	var result: Array[Dictionary] = [actor("main", "Principal", 10.0, Vector2(120, 260), abilities())]
	if scenario != 1:
		result.append(actor("near", "Enemigo cercano", 8.0, Vector2(320, 150), enemy_skills.duplicate(true)))
	if scenario != 0:
		result.append(actor("far", "Enemigo lejano", 12.0, Vector2(620, 290), enemy_skills.duplicate(true)))
	return result
