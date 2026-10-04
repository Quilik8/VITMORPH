extends RefCounted
var catalog: RefCounted

func _init(source: RefCounted) -> void:
	catalog = source

func empty_build(modular: Array) -> Dictionary:
	return {"modular":modular.duplicate(), "normal":["","","","","","","",""], "special":["",""]}

func validate_build(beast: Dictionary, build: Dictionary, library: Array, inventory: Dictionary, collection: Array = []) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
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

func preview_build(beast: Dictionary, build: Dictionary, inventory: Dictionary) -> Dictionary:
	var definition: Dictionary = catalog.beast(beast.definition_id)
	var skills: Array[Dictionary] = []
	var changes: Array[Dictionary] = []
	for id in definition.fixed + build.modular:
		var skill: Dictionary = catalog.skill(id)
		if skill.is_empty(): continue
		var base: float = skill.range
		var percent := 0.0
		var contributions: Array = []
		if base > 0 and skill.shield == 0:
			for instance in build.normal:
				if inventory.has(instance):
					var modifier: Dictionary = catalog.get_value("modifier:"+inventory[instance])
					percent += modifier.get("percent",0.0)
					contributions.append({"instance":instance,"percent":modifier.get("percent",0.0)})
			skill.range = base * (1.0+percent)
		skills.append(skill)
		changes.append({"id":id,"name":skill.name,"base":base,"result":skill.range,"contributions":contributions,"reason":"Objetivo propio; sin cambio" if skill.shield>0 else "Distancia al objetivo"})
	return {"abilities":skills,"changes":changes}
