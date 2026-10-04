extends RefCounted
signal changed
var session: RefCounted
var owned_id := ""
var build: Dictionary = {}
var last_error := ""

func _init(source: RefCounted) -> void:
	session=source

func select_copy(id: String) -> Dictionary:
	if session.combat_locked or session.owned(id).is_empty(): return failure("Bestia no disponible")
	owned_id=id
	build=session.owned(id).build.duplicate(true)
	last_error=""
	changed.emit()
	return {"ok":true}

func dirty() -> bool:
	return not owned_id.is_empty() and build!=session.owned(owned_id).build

func failure(reason: String) -> Dictionary:
	last_error=reason
	return {"ok":false,"error":reason}

func payload(kind: String, id: String, origin := -1) -> Dictionary:
	return {"kind":kind,"id":id,"origin":origin,"owned_id":owned_id}

func candidate(data: Dictionary, kind: String, index: int) -> Dictionary:
	if session.combat_locked: return failure("Edición disponible fuera de combate")
	if data.get("owned_id","")!=owned_id: return failure("La selección pertenece a otra bestia")
	if kind not in ["modular","normal"] or data.get("kind","")!=kind: return failure("Destino incompatible")
	if index<0 or index>=build[kind].size(): return failure("Destino no disponible")
	var next: Dictionary=build.duplicate(true)
	var id: String=str(data.get("id",""))
	var origin: int=int(data.get("origin",-1))
	if origin>=0:
		if origin>=next[kind].size() or next[kind][origin]!=id: return failure("El elemento de origen cambió")
		var previous: String=next[kind][index]
		next[kind][index]=id
		next[kind][origin]=previous
	else:
		if kind=="normal" and id in next.normal and next.normal[index]!=id:
			return failure("Esta instancia ya está montada; arrástrala desde su punto")
		next[kind][index]=id
	var validation: Dictionary=session.validate_build(owned_id,next)
	if not validation.ok: return failure(" · ".join(validation.errors))
	return {"ok":true,"build":next}

func equip(data: Dictionary, kind: String, index: int) -> Dictionary:
	var result:=candidate(data,kind,index)
	if not result.ok: return result
	var modified: bool=build!=result.build
	build=result.build
	last_error=""
	if modified: changed.emit()
	return {"ok":true,"modified":modified}

func remove(index: int) -> Dictionary:
	if session.combat_locked or index<0 or index>=8: return failure("Destino no disponible")
	var next: Dictionary=build.duplicate(true)
	next.normal[index]=""
	var validation: Dictionary=session.validate_build(owned_id,next)
	if not validation.ok: return failure(" · ".join(validation.errors))
	build=next;last_error="";changed.emit()
	return {"ok":true}

func preview() -> Dictionary:
	return session.preview_build(owned_id,build)

func apply() -> Dictionary:
	var result: Dictionary=session.apply_build(owned_id,build)
	if not result.ok: return failure(" · ".join(result.errors))
	build=session.owned(owned_id).build.duplicate(true)
	last_error="";changed.emit()
	return {"ok":true}

func discard() -> void:
	if owned_id.is_empty(): return
	build=session.owned(owned_id).build.duplicate(true)
	last_error="";changed.emit()

func owner_of(instance: String) -> String:
	for other in session.collection:
		if other.id!=owned_id and instance in other.build.normal: return other.id
	return ""
