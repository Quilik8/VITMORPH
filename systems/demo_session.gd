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
var inventory: Dictionary = {"range_1":"range"}
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
	return {"collection":collection.duplicate(true),"library":library.duplicate(),"inventory":inventory.duplicate(),"principal_id":principal_id,"next_id":next_id,"objectives":objectives.duplicate(),"copied_skills":copied_skills.duplicate()}
