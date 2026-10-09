extends RefCounted
const EngineScript=preload("res://systems/combat_engine.gd")
const Session=preload("res://systems/demo_session.gd")
const World=preload("res://data/world_fixture.gd")
const Save=preload("res://systems/save_service.gd")
var checks: Array[Dictionary]=[]
func check(label: String, ok: bool) -> void:checks.append({"name":label,"passed":ok})
func run() -> Dictionary:
	var session:=Session.new()
	var engine:=EngineScript.new()
	engine.copy_service.completed.connect(session.acquire_actor)
	engine.action_executed.connect(func(action):
		if engine.actor_by_id(action.actor_id).get("is_principal",false) and not action.skill.is_empty():session.record_skill(action.skill.id))
	var build: Dictionary=session.principal().build.duplicate(true)
	build.normal[0]="range_1"
	check("new game applies build",session.apply_build(session.principal_id,build).ok)
	var main: Dictionary=session.actor_at(Vector2(530,150))
	var enemy: Dictionary=World.populate()[1]
	var participants: Array[Dictionary]=[main,enemy]
	engine.begin_encounter(participants)
	var requested:=false
	for step in 2400:
		if not engine.running:break
		if not requested and enemy.hp<=30 and enemy.hp>0:
			engine.command("priority","guard")
			engine.command("retain","close")
			requested=engine.request_copy(enemy.id).ok
		engine.advance(0.1)
	check("natural damage reaches copy eligibility",requested)
	check("new game completes copy",session.collection.size()==2 and enemy.retired and engine.result=="Victoria")
	session.sync_actor(main,engine.priority,engine.retained)
	build=session.principal().build.duplicate(true)
	build.modular=["residual","far"]
	build.normal[1]="power_1";build.normal[2]="duration_1"
	check("copied library incorporated",session.apply_build(session.principal_id,build).ok)
	# Rest is an existing player option, not a combat heal or hidden balance change.
	session.recover()
	main=session.actor_at(Vector2(2240,130))
	var final: Dictionary=World.populate()[-1]
	participants=[main,final]
	engine.begin_encounter(participants);engine.priority="residual";engine.retained=""
	for step in 4000:
		if not engine.running:break
		engine.advance(0.1)
	check("new modular used in actual decisions",session.objectives.new_modular_used)
	check("final encounter beaten",engine.result=="Victoria")
	session.objectives.final_won=engine.result=="Victoria";session.update_objectives()
	check("full demo milestone cycle",session.objectives.completed)
	session.sync_actor(main,engine.priority,engine.retained)
	var reloaded:=Session.new()
	var json_data: Dictionary=JSON.parse_string(JSON.stringify(session.export_data()))
	check("completed session restored",reloaded.restore_data(json_data).ok and reloaded.objectives.completed and reloaded.collection.size()==2)
	var principal: Dictionary=reloaded.actor_at(Vector2(1290,320))
	var two := World.populate()
	participants=[principal,two[2],two[3]]
	engine.begin_encounter(participants);engine.priority="guard";engine.retained="residual"
	var kept: int=reloaded.collection.size()
	engine.apply_damage(principal,1000)
	check("resolved defeat preserves acquired copies",engine.result=="Derrota" and reloaded.collection.size()==kept)
	reloaded.recover()
	check("refuge recovery retains builds",reloaded.principal().hp==100 and reloaded.principal().build.modular==["residual","far"] and reloaded.objectives.completed)
	engine.free()
	var failures:=checks.filter(func(row):return not row.passed)
	return {"passed":failures.is_empty(),"count":checks.size(),"checks":checks,"failures":failures}
