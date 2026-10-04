extends RefCounted
## Datos exclusivamente técnicos. No son catálogo ni balance definitivo.

const ACTION_SECONDS := 3.8
const RESOLVE_SECONDS := 2.2
const SCENARIOS := ["1 contra 1 · cercano", "1 contra 1 · lejano", "1 contra 2"]

static var catalog := preload("res://data/catalog.gd").new()

static func abilities() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in ["basic", "guard", "close", "far"]:
		result.append(catalog.skill(id))
	return result

static func actor(id: String, label: String, speed: float, position: Vector2, skills: Array[Dictionary]) -> Dictionary:
	return {"id": id, "name": label, "hp": 100, "max_hp": 100, "shield": 0, "speed": speed,
		"position": position, "next_at": 0.0, "turns": 0, "ready_at": {}, "abilities": skills, "team": "player" if id == "main" else "enemy", "is_principal": id == "main", "states": {}, "retired": false}

static func actors(scenario: int) -> Array[Dictionary]:
	var enemy_skills: Array[Dictionary] = [{"id": "enemy_hit", "name": "Ataque técnico", "slot": "FIJA", "damage": 14, "shield": 0, "range": 600.0, "cooldown": 0}]
	var result: Array[Dictionary] = [actor("main", "Principal", 10.0, Vector2(120, 260), abilities())]
	if scenario != 1:
		result.append(actor("near", "Enemigo cercano", 8.0, Vector2(320, 150), enemy_skills.duplicate(true)))
	if scenario != 0:
		result.append(actor("far", "Enemigo lejano", 12.0, Vector2(620, 290), enemy_skills.duplicate(true)))
	return result
