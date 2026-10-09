extends RefCounted
const EngineScript=preload("res://systems/combat_engine.gd")
const Session=preload("res://systems/demo_session.gd")
const World=preload("res://data/world_fixture.gd")
const Status=preload("res://systems/status_system.gd")
var checks: Array[Dictionary]=[]
func check(label: String, ok: bool) -> void: checks.append({"name":label,"passed":ok})
func pair(session: RefCounted) -> Array[Dictionary]:
	var actors: Array[Dictionary]=[session.actor_at(Vector2.ZERO),World.populate()[1]]
	actors[1].position=Vector2(200,0)
	actors[0].abilities=[session.catalog.skill("guard")]
	actors[1].abilities=[]
	return actors
func run() -> Dictionary:
	var session:=Session.new()
	var engine:=EngineScript.new()
	engine.copy_service.completed.connect(session.acquire_actor)
	engine.begin_encounter(pair(session))
	var target: Dictionary=engine.actors[1]
	check("copy above threshold rejected",not engine.request_copy(target.id).ok)
	target.hp=30
	check("copy request accepted",engine.request_copy(target.id).ok)
	check("second request rejected",not engine.request_copy(target.id).ok)
	engine.cancel_copy_request()
	check("pending cancellable",engine.copy_service.pending_id=="")
	engine.request_copy(target.id)
	engine.priority="guard"
	engine.advance(10)
	check("support replaces skill opportunity",engine.pending.get("kind","")=="copy" and engine.actors[0].turns==1 and engine.priority=="guard")
	engine.advance(2.2)
	check("process begins on resolution",not engine.copy_service.process.is_empty() and is_equal_approx(engine.copy_service.process.finish,30.2))
	engine.advance(17.9)
	check("combat continuous before completion",engine.running and session.collection.size()==1 and engine.action_count>=2)
	engine.advance(0.1)
	check("copy success and live withdrawal",session.collection.size()==2 and target.retired and target.hp==30)
	check("last withdrawal wins",not engine.running and engine.result=="Victoria")
	check("unlocks deduplicated library",session.library.size()==3 and "residual" in session.library and "far" in session.library)
	var copied: Dictionary=session.collection[1]
	check("copy starts clean",copied.hp==100 and copied.shield==0 and copied.ready_at.is_empty() and copied.build==target.build)
	check("unique owned identity",copied.id!=session.principal_id)
	session.acquire_actor(target)
	check("repeat acquires new instance no library duplicate",session.collection.size()==3 and session.library.size()==3 and session.collection[1].id!=session.collection[2].id)
	engine.begin_encounter(pair(session))
	target=engine.actors[1]; target.hp=20
	engine.request_copy(target.id); target.hp=40
	engine.advance(10)
	check("dispatch revalidates uses ordinary opportunity",engine.pending.get("kind","")!="copy" and engine.pending.skill.id=="guard" and engine.copy_service.pending_id=="")
	engine.begin_encounter(pair(session))
	target=engine.actors[1]; target.hp=12
	engine.copy_service.process={"target_id":target.id,"start":-6.0,"finish":12.0}
	Status.apply(target,"dot",0)
	var count: int=session.collection.size()
	engine.advance(12)
	check("due damage before simultaneous completion",session.collection.size()==count and target.hp==0 and not target.retired)
	check("failed copy explained",engine.copy_service.message.begins_with("Copia fallida"))
	engine.begin_encounter(pair(session))
	target=engine.actors[1];target.hp=30
	engine.copy_service.begin(target,engine.principal_actor(),0)
	engine.apply_damage(engine.principal_actor(),100)
	check("main defeat fails process",engine.copy_service.process.is_empty() and engine.result=="Derrota")
	engine.free()
	var failures:=checks.filter(func(row):return not row.passed)
	return {"passed":failures.is_empty(),"count":checks.size(),"checks":checks,"failures":failures}
