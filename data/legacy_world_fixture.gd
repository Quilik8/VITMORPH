extends RefCounted
## Un recorrido técnico continuo; no define regiones, historia ni balance de campaña.
const Fixture = preload("res://data/combat_fixture.gd")
const TRAVEL_SPEED := 180.0
const ENCOUNTER_RADIUS := 210.0
const DETECTION_RADIUS := 380.0
const PURSUIT_SPEED := 65.0
const LOSE_RADIUS := 500.0
const LEASH_RADIUS := 620.0
const AFTERMATH_SECONDS := 2.8
const ENEMY_HP := 30
const ENEMY_DAMAGE := 4
const START_POSITION := Vector2(150, 260)
const MOVEMENT_BOUNDS := Rect2(80, 80, 3920, 1920)

static func locations() -> Array[Dictionary]:
	return [
		{"id": "zone_1", "name": "Grupo cercano", "center": Vector2(720,245), "approach": Vector2(520,245), "enemies": [Vector2(690,150), Vector2(770,210)]},
		{"id": "zone_2", "confronts": true, "name": "Grupo perseguidor", "center": Vector2(1540,250), "approach": Vector2(1290,320), "enemies": [Vector2(1450,380),Vector2(1780,180)]},
		{"id": "zone_3", "name": "Grupo separado", "center": Vector2(2420,280), "approach": Vector2(2160,240), "enemies": [Vector2(2320,130),Vector2(2610,360)]},
	]

static func populate() -> Array[Dictionary]:
	var result: Array[Dictionary] = [Fixture.actor("main", "Principal", 10.0, START_POSITION, Fixture.abilities())]
	for zone in locations():
		for index in zone.enemies.size():
			var abilities: Array[Dictionary] = [{"id": "enemy_hit", "name": "Ataque técnico", "slot": "FIJA", "damage": ENEMY_DAMAGE, "shield": 0, "range": 600.0, "cooldown": 0}]
			var enemy: Dictionary = Fixture.actor("%s_%d" % [zone.id,index], "Enemigo %d" % (index+1), 8.0 if index == 0 else 12.0, zone.enemies[index], abilities)
			enemy.hp = ENEMY_HP
			enemy.max_hp = ENEMY_HP
			enemy["zone_id"] = zone.id
			enemy["home"] = enemy.position
			result.append(enemy)
	return result

static func obstacles() -> Array[Rect2]:
	return [Rect2(380,175,120,150), Rect2(1220,200,100,100), Rect2(2120,140,120,150)]
