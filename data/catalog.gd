extends RefCounted
const Definition = preload("res://data/definition.gd")
var definitions: Dictionary = {}

func _init() -> void:
	add_skill("basic", "Ataque básico", 18, 0, 400.0, 0, 0)
	add_skill("guard", "Defensa", 0, 24, 0.0, 0, 1)
	add_skill("close", "Ataque cercano", 30, 0, 240.0, 2, 2, true)
	add_skill("far", "Ataque distante", 12, 0, 600.0, 1, 3, true)
	add_skill("residual", "Impacto residual", 10, 0, 400.0, 2, 4, true, "dot")
	add_skill("slow", "Freno", 6, 0, 400.0, 2, 5, true, "slow")
	add_skill("enemy_hit", "Ataque técnico", 4, 0, 600.0, 0, 6)
	add_skill("enemy_guard", "Protección técnica", 0, 12, 0.0, 0, 7)
	add("modifier:range", "modifier", {"id":"range", "name":"Alcance", "property":"range", "percent":0.30})
	add_beast("starter", "Principal inicial", 10.0, ["basic","guard"], ["close","far"])
	add_beast("residual_beast", "Bestia residual", 8.0, ["enemy_hit","enemy_guard"], ["residual","slow"])
	add_beast("ranged_beast", "Bestia distante", 12.0, ["enemy_hit","enemy_guard"], ["close","far"])

func add(key: String, domain: String, payload: Dictionary) -> void:
	var definition := Definition.new()
	definition.id = key
	definition.domain = domain
	definition.payload = payload.duplicate(true)
	definitions[key] = definition

func add_skill(id: String, name: String, damage: int, shield: int, distance: float, cooldown: int, order: int, modular := false, status := "") -> void:
	add("skill:"+id, "skill", {"id":id,"name":name,"damage":damage,"shield":shield,"range":distance,"cooldown":cooldown,"order":order,"modular":modular,"status":status,"slot":"MODULAR" if modular else "FIJA"})

func add_beast(id: String, name: String, speed: float, fixed: Array, modular: Array) -> void:
	add("beast:"+id, "beast", {"id":id,"name":name,"speed":speed,"max_hp":100,"fixed":fixed,"modular":modular})

func get_value(key: String) -> Dictionary:
	return definitions[key].value() if definitions.has(key) else {}

func skill(id: String) -> Dictionary:
	return get_value("skill:"+id)

func beast(id: String) -> Dictionary:
	return get_value("beast:"+id)

func check() -> Array[String]:
	var errors: Array[String] = []
	for definition in definitions.values():
		if definition.domain == "beast":
			for id in definition.payload.fixed + definition.payload.modular:
				if skill(id).is_empty():
					errors.append("Habilidad desconocida: "+id)
	return errors
