extends RefCounted
const Session=preload("res://systems/demo_session.gd")
const Save=preload("res://systems/save_service.gd")
const Route=preload("res://systems/world_route.gd")
const EngineScript=preload("res://systems/combat_engine.gd")
const World=preload("res://data/world_fixture.gd")
var checks: Array[Dictionary]=[]
var session: RefCounted
var route: Node
func check(label: String, ok: bool) -> void: checks.append({"name":label,"passed":ok})
func validate(data: Dictionary) -> Dictionary:
	if not data.get("session") is Dictionary or not data.get("world") is Dictionary: return {"ok":false,"error":"Snapshot incompleto"}
	var result: Dictionary=session.validate_data(data.session)
	return route.validate_data(data.world) if result.ok else result
func snapshot_data() -> Dictionary:
	return {"session":session.export_data(),"world":route.export_data()}
func run() -> Dictionary:
	session=Session.new()
	var engine:=EngineScript.new()
	route=Route.new(); route.session=session; route.combat=engine; route.start()
	var save:=Save.new()
	DirAccess.make_dir_recursive_absolute("user://tests")
	save.path="user://tests/demo_roundtrip.json"
	for suffix in ["",".bak",".tmp",".bak.tmp"]:
		if FileAccess.file_exists(save.path+suffix): DirAccess.remove_absolute(save.path+suffix)
	check("snapshot references valid",validate(snapshot_data()).ok)
	var first:=snapshot_data()
	check("checkpoint queued",save.create_checkpoint(first).ok)
	save.flush()
	check("write confirmed",save.confirmed==1 and save.status=="Guardado")
	var restored: Dictionary=save.restore_checkpoint(validate)
	check("JSON roundtrip valid",restored.ok and restored.snapshot.session.principal_id==session.principal_id)
	session.principal().hp=68
	save.create_checkpoint(snapshot_data()); save.flush()
	check("last valid backup retained",FileAccess.file_exists(save.path+".bak") and Save.read_document(save.path+".bak").snapshot.session.collection[0].hp==100)
	var corrupt:=FileAccess.open(save.path,FileAccess.WRITE);corrupt.store_string("{broken");corrupt.close()
	restored=save.restore_checkpoint(validate)
	check("corrupt main uses valid backup",restored.ok and restored.backup and restored.snapshot.session.collection[0].hp==100)
	save.create_checkpoint(first);save.flush()
	check("repair preserves usable backup",save.status=="Guardado" and Save.read_document(save.path+".bak").get("schema")==1)
	for value in [80,70,60]:
		session.principal().hp=value;save.create_checkpoint(snapshot_data())
	save.flush()
	check("latest write wins",Save.read_document(save.path).snapshot.session.collection[0].hp==60 and save.confirmed==save.sequence)
	var invalid:=first.duplicate(true)
	invalid.session.collection[0].definition_id="missing"
	check("unknown definition rejected",not validate(invalid).ok)
	invalid=first.duplicate(true); invalid.session.collection[0].build.modular=["close","close"]
	check("invalid saved build rejected",not validate(invalid).ok)
	invalid=first.duplicate(true); invalid.world.position=["oops",0]
	check("invalid coordinates rejected",not validate(invalid).ok)
	var copy: Dictionary=session.acquire_actor(route.actors[1])
	check("copy retained in session",copy.id!="" and session.collection.size()==2)
	check("restore pre encounter reverts copy",session.restore_data(first.session).ok and session.collection.size()==1)
	check("restore keeps HP state",session.principal().hp==100)
	var fail:=Save.new();fail.path="user://tests/missing_directory/no_save.json"
	fail.create_checkpoint(first);fail.flush()
	check("write failure never reports saved",fail.confirmed==0 and fail.status!="Guardado")
	fail.free()
	var blocked:=Save.new();blocked.path="user://tests/incompatible.json"
	for suffix in ["",".bak"]:
		if FileAccess.file_exists(blocked.path+suffix):DirAccess.remove_absolute(blocked.path+suffix)
	var incompatible:=FileAccess.open(blocked.path,FileAccess.WRITE);incompatible.store_string(JSON.stringify({"schema":999,"snapshot":first}));incompatible.close()
	var outcome: Dictionary=blocked.restore_checkpoint(validate)
	check("incompatible schema preserves file",not outcome.ok and blocked.blocked and Save.read_document(blocked.path).schema==999)
	check("incompatible not silently overwritten",not blocked.create_checkpoint(first).ok)
	blocked.free()
	session.principal().hp=20;session.principal().shield=10;session.principal().ready_at.basic=9
	route.actors[1].retired=true;route.actors[1].hp=30;route.cleared_groups.zone_1=true
	route.state="travelling";route.actors[0].position=World.START_POSITION
	engine.copy_service.pending_id="old_request"
	engine.copy_service.process={"target_id":"old_process","start":0.0,"finish":18.0}
	check("refuge rest valid",route.rest().ok)
	check("rest discards pending battle copy",engine.copy_service.pending_id=="" and engine.copy_service.process.is_empty())
	check("rest resets health and encounters",session.principal().hp==100 and session.principal().shield==0 and session.principal().ready_at.is_empty() and route.cleared_groups.is_empty() and not route.actors[1].retired)
	session.objectives.copied=true;session.objectives.new_modular_used=true;session.objectives.final_won=true;session.update_objectives()
	check("three milestones complete demo",session.objectives.completed)
	route.rest()
	check("rest preserves completion and library",session.objectives.completed and session.library.size()==2)
	check("continuous world ready after rest",route.state=="travelling" and route.visible_world)
	session.acquire_actor(route.actors[1])
	route.state="battle"
	route.actors[0].hp=0
	route.on_combat_finished("Derrota")
	check("resolved defeat keeps collection in world controller",session.collection.size()==2 and session.library.size()==4)
	check("resolved defeat returns refuge and resets groups",route.at_refuge() and route.actors[0].hp==100 and route.cleared_groups.is_empty())
	engine.free();route.free();save.free()
	var failures:=checks.filter(func(row):return not row.passed)
	return {"passed":failures.is_empty(),"count":checks.size(),"checks":checks,"failures":failures}
