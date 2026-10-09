extends RefCounted
## Estado efímero de diagnóstico. Ninguna dependencia de daño, ATB o guardado.
signal changed
signal aligned(actor_id: String)
signal closed
var active := false
var encounter := 0
var owner_id := ""
var matrices: Dictionary = {}

func sync(running: bool, actors: Array) -> void:
	if not running:
		if active:
			active=false; matrices.clear(); close(); changed.emit()
		return
	if not active:
		active=true; encounter+=1; matrices.clear()
	var alive := {}
	for actor in actors:
		if actor.hp>0 and not actor.get("retired",false): alive[actor.id]=true
	for id in matrices.keys():
		if not alive.has(id): matrices.erase(id)
	if owner_id!="" and not alive.has(owner_id): close()

func open(actor_id: String, actors: Array) -> bool:
	if not active: return false
	var valid := false
	for actor in actors:
		if actor.id==actor_id and actor.hp>0 and not actor.get("retired",false): valid=true
	if not valid: return false
	if not matrices.has(actor_id): matrices[actor_id]={"positions":[1,3,5],"selected":0,"resolved":false}
	owner_id=actor_id; changed.emit(); return true

func close() -> void:
	if owner_id=="": return
	owner_id=""; closed.emit(); changed.emit()

func select_ring(index: int) -> void:
	if owner_id=="" or index<0 or index>2: return
	matrices[owner_id].selected=index; changed.emit()

func rotate(direction: int) -> void:
	if owner_id=="" or direction not in [-1,1]: return
	var state: Dictionary=matrices[owner_id]
	if state.resolved: return
	state.positions[state.selected]=posmod(state.positions[state.selected]+direction,8)
	state.resolved=state.positions==[0,0,0]
	changed.emit()
	if state.resolved: aligned.emit(owner_id)

func reset() -> void:
	if owner_id=="": return
	matrices[owner_id]={"positions":[1,3,5],"selected":0,"resolved":false};changed.emit()

func snapshot() -> Dictionary:
	return {"encounter":encounter,"owner_id":owner_id,"active":active,"matrices":matrices.duplicate(true)}

func current() -> Dictionary:
	return matrices.get(owner_id,{}).duplicate(true)
