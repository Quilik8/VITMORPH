extends RefCounted
signal build_changed
signal library_changed
signal principal_changed
const Catalog = preload("res://data/catalog.gd")
const Builds = preload("res://systems/build_service.gd")
var catalog := Catalog.new()
var builds := Builds.new(catalog)
var collection: Array[Dictionary] = []
var library: Array = []
var inventory: Dictionary = {"range_1":"range","power_1":"power","duration_1":"duration"}
var build_content_version := 1
var principal_id := ""
var next_id := 1
var combat_locked := false
var objectives := {"copied":false,"new_modular_used":false,"final_won":false,"completed":false}
var copied_skills: Array = []

func _init() -> void:
	var first := acquire("starter")
	principal_id = first.id

func acquire(definition_id: String, build: Dictionary = {}) -> Dictionary:
	var definition: Dictionary = catalog.beast(definition_id)
	if definition.is_empty(): return {}
	var owned := {"id":"copy_%06d"%next_id,"definition_id":definition_id,"name":definition.name,"build":build.duplicate(true) if not build.is_empty() else builds.empty_build(definition.modular),"hp":definition.max_hp,"shield":0,"turns":0,"ready_at":{},"priority":"","retained":""}
	next_id += 1
	collection.append(owned)
	for id in owned.build.modular:
		if id not in library: library.append(id)
	library_changed.emit()
	return owned

func owned(id: String) -> Dictionary:
	for beast in collection:
		if beast.id == id: return beast
	return {}

func principal() -> Dictionary:
	return owned(principal_id)

func validate_build(id: String, build: Dictionary) -> Dictionary:
	var beast := owned(id)
	if beast.is_empty(): return {"ok":false,"errors":["Bestia desconocida"],"warnings":[]}
	return builds.validate_build(beast,build,library,inventory,collection)

func preview_build(id: String, build: Dictionary) -> Dictionary:
	return builds.preview_build(owned(id),build,inventory)

func apply_build(id: String, build: Dictionary) -> Dictionary:
	if combat_locked: return {"ok":false,"errors":["Edición disponible fuera de combate"]}
	var result := validate_build(id,build)
	if not result.ok: return result
	var beast := owned(id)
	beast.build = build.duplicate(true)
	var equipped: Array = catalog.beast(beast.definition_id).fixed + build.modular
	for key in ["priority","retained"]:
		if beast[key] not in equipped: beast[key] = ""
	build_changed.emit()
	return result

func select_principal(id: String) -> Dictionary:
	if combat_locked or owned(id).is_empty() or owned(id).hp<=0:
		return {"ok":false,"error":"Principal no disponible"}
	principal_id = id
	principal_changed.emit()
	return {"ok":true}

func actor_at(position: Vector2) -> Dictionary:
	var beast := principal()
	var definition: Dictionary = catalog.beast(beast.definition_id)
	return {"id":"main","owned_id":beast.id,"definition_id":beast.definition_id,"name":beast.name,"team":"player","is_principal":true,"hp":beast.hp,"max_hp":definition.max_hp,"shield":beast.shield,"speed":definition.speed,"position":position,"turns":beast.turns,"ready_at":beast.ready_at.duplicate(),"abilities":preview_build(beast.id,beast.build).abilities,"build":beast.build.duplicate(true),"states":{},"retired":false,"next_at":0.0}

func sync_actor(actor: Dictionary, priority: String, retained: String) -> void:
	var beast := owned(actor.get("owned_id",""))
	if beast.is_empty(): return
	for key in ["hp","shield","turns"]: beast[key] = actor[key]
	beast.ready_at = actor.ready_at.duplicate()
	beast.priority = priority
	beast.retained = retained

func recover() -> void:
	for beast in collection:
		beast.hp = catalog.beast(beast.definition_id).max_hp
		beast.shield = 0
		beast.turns = 0
		beast.ready_at.clear()

func export_data() -> Dictionary:
	return {"build_content_version":build_content_version,"collection":collection.duplicate(true),"library":library.duplicate(),"inventory":inventory.duplicate(),"principal_id":principal_id,"next_id":next_id,"objectives":objectives.duplicate(),"copied_skills":copied_skills.duplicate()}

func validate_data(data: Dictionary) -> Dictionary:
	if data.has("build_content_version") and (not number(data.build_content_version) or data.build_content_version<0 or data.build_content_version>1 or floor(data.build_content_version)!=data.build_content_version):
		return {"ok":false,"error":"Versión de contenido incompatible"}
	for key in ["collection","library","copied_skills"]:
		if not data.get(key) is Array: return {"ok":false,"error":"Lista persistente inválida: "+key}
	for key in ["inventory","objectives"]:
		if not data.get(key) is Dictionary: return {"ok":false,"error":"Datos persistentes inválidos: "+key}
	if data.collection.is_empty() or not data.get("principal_id") is String or not number(data.get("next_id")):
		return {"ok":false,"error":"Identidad persistente inválida"}
	var ids := {}
	var skills := {}
	for id in data.library:
		if not id is String or catalog.skill(id).is_empty() or not catalog.skill(id).get("modular",false) or skills.has(id): return {"ok":false,"error":"Biblioteca incompatible"}
		skills[id]=true
	for id in data.copied_skills:
		if id not in data.library: return {"ok":false,"error":"Habilidad copiada incompatible"}
	for id in data.inventory:
		if not id is String or id=="" or not data.inventory[id] is String or catalog.get_value("modifier:"+data.inventory[id]).is_empty(): return {"ok":false,"error":"Inventario incompatible"}
	for beast in data.collection:
		if not beast is Dictionary or not beast.get("id") is String or not beast.get("definition_id") is String or not beast.get("name") is String: return {"ok":false,"error":"Bestia persistente inválida"}
		var definition: Dictionary = catalog.beast(beast.definition_id)
		if definition.is_empty() or ids.has(beast.id) or beast.id=="": return {"ok":false,"error":"Definición o identidad incompatible"}
		ids[beast.id]=true
		if not beast.get("build") is Dictionary or not beast.get("ready_at") is Dictionary: return {"ok":false,"error":"Build persistente inválida"}
		for key in ["hp","shield","turns"]:
			if not number(beast.get(key)) or beast[key]<0 or floor(beast[key])!=beast[key]: return {"ok":false,"error":"Valor persistente inválido: "+key}
		if beast.hp>definition.max_hp: return {"ok":false,"error":"Vida fuera del perfil"}
		for id in beast.ready_at:
			if not id is String or catalog.skill(id).is_empty() or not number(beast.ready_at[id]) or beast.ready_at[id]<0: return {"ok":false,"error":"Reutilización incompatible"}
		for slots in ["modular","normal","special"]:
			if not beast.build.get(slots) is Array: return {"ok":false,"error":"Ranuras inválidas"}
			for id in beast.build[slots]:
				if not id is String: return {"ok":false,"error":"Referencia de ranura inválida"}
		for key in ["priority","retained"]:
			if not beast.get(key) is String or (beast[key]!="" and beast[key] not in definition.fixed+beast.build.modular): return {"ok":false,"error":"Marca incompatible"}
	for beast in data.collection:
		var validation: Dictionary=builds.validate_build(beast,beast.build,data.library,data.inventory,data.collection)
		if not validation.ok: return {"ok":false,"error":"Build incompatible: "+"; ".join(validation.errors)}
	if not ids.has(data.principal_id) or data.next_id<=0 or floor(data.next_id)!=data.next_id: return {"ok":false,"error":"Principal o secuencia incompatible"}
	for id in ids:
		if id.begins_with("copy_") and int(id.trim_prefix("copy_"))>=data.next_id: return {"ok":false,"error":"Secuencia de identidades incompatible"}
	for key in ["copied","new_modular_used","final_won","completed"]:
		if not data.objectives.get(key) is bool: return {"ok":false,"error":"Hitos incompatibles"}
	if data.objectives.completed!=(data.objectives.copied and data.objectives.new_modular_used and data.objectives.final_won): return {"ok":false,"error":"Hitos incoherentes"}
	return {"ok":true}

static func number(value) -> bool:
	return (value is int or value is float) and is_finite(float(value))

func restore_data(data: Dictionary) -> Dictionary:
	var validation:=validate_data(data)
	if not validation.ok: return validation
	collection.assign(data.collection.duplicate(true))
	library=data.library.duplicate()
	inventory=data.inventory.duplicate()
	# Version marker prevents granting removed instances again on every load.
	if int(data.get("build_content_version",0)) < 1:
		for entry in {"power_1":"power","duration_1":"duration"}:
			if not inventory.has(entry): inventory[entry]="power" if entry=="power_1" else "duration"
	build_content_version=1
	principal_id=data.principal_id
	next_id=int(data.next_id)
	objectives=data.objectives.duplicate()
	copied_skills=data.copied_skills.duplicate()
	combat_locked=false
	library_changed.emit(); principal_changed.emit(); build_changed.emit()
	return {"ok":true}

func acquire_actor(actor: Dictionary) -> Dictionary:
	var build: Dictionary = actor.build.duplicate(true)
	for index in build.normal.size():
		var instance: String = build.normal[index]
		if instance=="": continue
		var source: String = actor.get("modifier_definitions",{}).get(instance,inventory.get(instance,""))
		if source=="": return {}
		var fresh := "mod_%06d_%d"%[next_id,index]
		inventory[fresh]=source
		build.normal[index]=fresh
	var before := library.duplicate()
	var beast := acquire(actor.definition_id,build)
	if beast.is_empty(): return {}
	objectives.copied=true
	for id in library:
		if id not in before and id not in copied_skills: copied_skills.append(id)
	update_objectives()
	return beast

func record_skill(id: String) -> void:
	if id in copied_skills: objectives.new_modular_used=true; update_objectives()

func update_objectives() -> void:
	objectives.completed=objectives.copied and objectives.new_modular_used and objectives.final_won
