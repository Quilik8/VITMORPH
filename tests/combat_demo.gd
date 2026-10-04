extends RefCounted
const EngineScript = preload("res://systems/combat_engine.gd")
const Fixture = preload("res://data/combat_fixture.gd")
const Status = preload("res://systems/status_system.gd")
const AI = preload("res://systems/combat_ai.gd")
const Catalog = preload("res://data/catalog.gd")
var results: Array[Dictionary] = []

func check(label: String, condition: bool) -> void:
	results.append({"name":label,"passed":condition})

func pair() -> Array[Dictionary]:
	var actors := Fixture.actors(0)
	actors[0].position=Vector2.ZERO
	actors[1].position=Vector2(200,0)
	actors[0].abilities=[Catalog.new().skill("guard")]
	actors[1].abilities=[Catalog.new().skill("enemy_guard")]
	return actors

func run() -> Dictionary:
	var engine := EngineScript.new()
	var actors := pair()
	engine.begin_encounter(actors)
	engine.advance(10)
	check("ATB arrival and action",engine.pending.actor_id==actors[0].id and is_equal_approx(engine.elapsed,0.0))
	engine.advance(2.2)
	check("impact exact",engine.resolved and actors[0].shield==24)
	engine.advance(2.6)
	check("stable waiting actor dispatched",engine.pending.actor_id==actors[1].id and is_equal_approx(engine.elapsed,0.0))
	engine.begin_encounter(pair())
	actors=engine.actors
	actors[1].abilities.clear()
	Status.apply(actors[1],"dot",0)
	engine.advance(4)
	check("dot first pulse",actors[1].hp==96)
	Status.apply(actors[1],"dot",4)
	check("dot reapply preserves cadence",actors[1].states.dot.next==8 and actors[1].states.dot.expires==16)
	engine.advance(4)
	check("dot second pulse",actors[1].hp==92)
	actors[1].shield=3
	engine.advance(4)
	check("dot through shared protection",actors[1].hp==91 and actors[1].shield==0)
	engine.advance(4)
	check("dot extended final pulse and expiry",actors[1].hp==87 and not actors[1].states.has("dot"))
	engine.begin_encounter(pair())
	actors=engine.actors
	Status.apply(actors[0],"slow",0)
	engine.advance(8)
	check("slow retains accumulated charge",is_equal_approx(actors[0].atb,60) and not actors[0].states.has("slow"))
	engine.advance(4)
	check("slow expiry and future arrival",engine.pending.actor_id==actors[0].id and is_equal_approx(engine.combat_clock,12))
	var forecast := engine.forecast(7)
	check("forecast repeated sequence",forecast.size()==7 and forecast[0].id==actors[0].id)
	engine.begin_encounter(pair())
	Status.apply(engine.actors[0],"slow",0)
	check("forecast accounts expiry",is_equal_approx(engine.forecast(2)[0].time,12))
	engine.begin_encounter(pair())
	engine.advance(60)
	var large := [engine.combat_clock,engine.action_count,engine.elapsed,engine.pending.duplicate(true),engine.actors.duplicate(true)]
	engine.begin_encounter(pair())
	for tick in 600: engine.advance(0.1)
	check("large delta action parity",engine.action_count==large[1] and engine.pending.get("actor_id","")==large[3].get("actor_id","") and is_equal_approx(engine.elapsed,large[2]))
	check("large delta charge parity",is_equal_approx(engine.actors[0].atb,large[4][0].atb) and is_equal_approx(engine.actors[1].atb,large[4][1].atb))
	actors=Fixture.actors(0)
	actors[0].position=Vector2.ZERO; actors[1].position=Vector2(200,0)
	actors[0].id="any_player_id"
	actors[0].turns=1
	check("team targeting independent of ID",AI.choose(actors[0],actors,"basic","").target_id==actors[1].id)
	check("valid priority",AI.choose(actors[0],actors,"far","").skill.id=="far")
	check("retain beats priority",AI.choose(actors[0],actors,"close","close").skill.id!="close")
	actors[0].ready_at.close=3
	check("invalid priority fallback",AI.choose(actors[0],actors,"close","").skill.id!="close")
	actors[0].turns=3
	check("priority becomes valid",AI.choose(actors[0],actors,"close","").skill.id=="close")
	actors[0].hp=40
	check("defense threshold",AI.choose(actors[0],actors,"","").skill.id=="guard")
	actors[0].abilities=[]
	check("no valid loses opportunity",AI.choose(actors[0],actors,"","").skill.is_empty())
	actors=pair(); actors[0].abilities=[Catalog.new().skill("slow"),Catalog.new().skill("residual")]; actors[0].turns=1
	actors[1].atb=70.0
	check("AI control advanced charge",AI.choose(actors[0],actors,"","").skill.id=="slow")
	Status.apply(actors[1],"slow",0)
	check("AI avoids equivalent control",AI.choose(actors[0],actors,"","").skill.id=="residual")
	engine.begin_encounter(pair())
	actors=engine.actors; actors[1].hp=4
	Status.apply(actors[1],"dot",0)
	engine.advance(4)
	check("periodic death resolves encounter",not engine.running and engine.result=="Victoria" and actors[1].states.is_empty())
	engine.free()
	var failures := results.filter(func(row): return not row.passed)
	return {"passed":failures.is_empty(),"count":results.size(),"failures":failures,"checks":results}
