extends RefCounted
var catalog: RefCounted

func _init(source: RefCounted) -> void:
	catalog = source

func empty_build(modular: Array) -> Dictionary:
	return {"modular":modular.duplicate(), "normal":["","","","","","","",""], "special":["",""]}

func validate_build(beast: Dictionary, build: Dictionary, library: Array, inventory: Dictionary, collection: Array = []) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	for key in build:
		if key not in ["modular","normal","special"]: errors.append("Campo de build no editable: "+str(key))
	if not build.get("modular") is Array or not build.get("normal") is Array or not build.get("special") is Array:
		return {"ok":false,"errors":["Configuración incompleta"],"warnings":[]}
	if build.modular.size()!=2 or build.normal.size()!=8 or build.special.size()!=2:
		errors.append("Se requieren 2 modulares, 8 normales y 2 especiales")
	var used := {}
	for id in build.modular:
		var skill: Dictionary = catalog.skill(str(id))
		if skill.is_empty() or not skill.get("modular",false) or id not in library:
			errors.append("Modular no disponible: "+str(id))
		if used.has(id):
			errors.append("Una modular solo puede equiparse una vez")
		used[id] = true
	used.clear()
	for id in build.normal:
		if id == "": continue
		if not inventory.has(id): errors.append("Modificador no disponible")
		if used.has(id): errors.append("Instancia de modificador repetida")
		used[id] = true
		for other in collection:
			if other.id != beast.id and id in other.build.normal:
				errors.append("Modificador equipado en otra bestia")
	for id in build.special:
		if id != "": errors.append("No hay modificadores especiales en esta demo")
	return {"ok":errors.is_empty(),"errors":errors,"warnings":warnings}

func compatible(skill: Dictionary, property: String) -> bool:
	match property:
		"range": return skill.get("range",0.0)>0 and skill.get("shield",0)==0
		"damage": return skill.get("damage",0)>0
		"status_duration": return skill.get("status","") in ["dot","slow"]
	return false

func preview_build(beast: Dictionary, build: Dictionary, inventory: Dictionary) -> Dictionary:
	var definition: Dictionary = catalog.beast(beast.definition_id)
	var skills: Array[Dictionary] = []
	var changes: Array[Dictionary] = []
	for id in definition.fixed + build.modular:
		var skill: Dictionary = catalog.skill(id)
		if skill.is_empty(): continue
		var properties := {}
		var rules = preload("res://data/demo_rules.gd")
		skill["status_duration"] = rules.DOT_DURATION if skill.get("status","")=="dot" else (rules.SLOW_DURATION if skill.get("status","")=="slow" else 0.0)
		for property in ["range","damage","status_duration"]:
			var base: float = float(skill[property])
			var percent := 0.0
			var contributions: Array = []
			var accepts := compatible(skill,property)
			for instance in build.normal:
				if not inventory.has(instance): continue
				var modifier: Dictionary = catalog.get_value("modifier:"+inventory[instance])
				if accepts and modifier.get("property","")==property:
					percent += modifier.get("percent",0.0)
					contributions.append({"instance":instance,"percent":modifier.get("percent",0.0)})
			var value := base*(1.0+percent)
			skill[property] = int(floor(value+0.5)) if property=="damage" else value
			properties[property] = {"base":base,"result":skill[property],"contributions":contributions,"compatible":accepts,"reason":"" if accepts else ("Sin estado con duración" if property=="status_duration" else ("Sin daño directo" if property=="damage" else "Objetivo propio; sin alcance"))}
		skill["derived_properties"] = properties.duplicate(true)
		skills.append(skill)
		changes.append({"id":id,"name":skill.name,"base":properties.range.base,"result":skill.range,"contributions":properties.range.contributions,"reason":properties.range.reason,"properties":properties})
	return {"abilities":skills,"changes":changes}
