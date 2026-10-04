extends RefCounted
const Session=preload("res://systems/demo_session.gd")
const EngineScript=preload("res://systems/combat_engine.gd")
const Fixture=preload("res://data/combat_fixture.gd")
const Status=preload("res://systems/status_system.gd")
const AI=preload("res://systems/combat_ai.gd")
const Geometry=preload("res://systems/world_geometry.gd")
var checks: Array[Dictionary]=[]
func check(label: String, ok: bool) -> void: checks.append({"name":label,"passed":ok})
func run() -> Dictionary:
	var session:=Session.new()
	var first: String=session.principal_id
	var second: Dictionary=session.acquire("starter")
	var build: Dictionary=session.principal().build.duplicate(true)
	build.normal[0]="range_1";session.inventory.range_2="range";build.normal[1]="range_2"
	check("percentage contributions add once",session.preview_build(first,build).abilities[0].range==640.0)
	check("second build remains intact",session.preview_build(second.id,second.build).abilities[0].range==400.0)
	check("catalog remains intact",session.catalog.skill("basic").range==400.0)
	check("apply valid multiple instances",session.apply_build(first,build).ok)
	var other: Dictionary=second.build.duplicate(true);other.normal[0]="range_1"
	check("owned modifier cannot equip twice across beasts",not session.apply_build(second.id,other).ok)
	var bad: Dictionary=build.duplicate(true);bad.fixed=["far","close"]
	check("fixed skills cannot replace",not session.apply_build(first,bad).ok)
	bad=build.duplicate(true);bad.modular.append("close")
	check("slot limits enforced",not session.apply_build(first,bad).ok)
	var engine:=EngineScript.new()
	var actors:=Fixture.actors(0)
	actors[0].position=Vector2.ZERO;actors[1].position=Vector2(200,0)
	engine.begin_encounter(actors);engine.command("priority","basic")
	engine.advance(10)
	var chosen: String=engine.pending.skill.id
	engine.command("priority","far");engine.command("retain","basic")
	check("commands do not cancel begun action",engine.pending.skill.id==chosen)
	engine.advance(2.2)
	check("retained begun action still resolves",actors[1].hp==82)
	check("next choice uses new priority",AI.choose(actors[0],actors,engine.priority,engine.retained).skill.id=="far")
	var original_ready: float=engine.actors[1].ready_time
	engine.actors[1].atb=100.0;engine.actors[1].ready_time=12.0
	Status.apply(engine.actors[1],"slow",engine.combat_clock)
	check("slow preserves registered arrival",engine.actors[1].ready_time==12.0)
	Status.apply(engine.actors[1],"slow",engine.combat_clock+2,0.1)
	check("reapply preserves stronger intensity and extends",engine.actors[1].states.slow.intensity==0.25 and is_equal_approx(engine.actors[1].states.slow.expires,engine.combat_clock+10))
	actors[0].abilities=[session.catalog.skill("far"),session.catalog.skill("basic")];actors[0].turns=1
	actors[0].ready_at.clear()
	actors[1].hp=5;actors[1].shield=0
	check("overkill capped stable skill order",AI.choose(actors[0],actors,"","").skill.id=="basic")
	var extra: Dictionary=actors[1].duplicate(true);extra.id="other_enemy"
	actors.append(extra)
	check("target tie stable order",AI.target_for(actors[0],session.catalog.skill("basic"),actors).id==actors[1].id)
	var obstacles: Array[Rect2]=[Rect2(100,100,100,100)]
	var moved: Vector2=Geometry.move_sliding(Vector2(50,150),Vector2(100,0),obstacles)
	check("obstacles constrain world movement",moved.x<100)
	engine.finish("Victoria")
	check("states clean at encounter end",engine.actors.all(func(actor):return actor.states.is_empty()))
	engine.free()
	var failures:=checks.filter(func(row):return not row.passed)
	return {"passed":failures.is_empty(),"count":checks.size(),"checks":checks,"failures":failures}
