extends SceneTree
const Fixture = preload("res://data/combat_fixture.gd")
const Status = preload("res://systems/status_system.gd")
const Probe = preload("res://systems/performance_probe.gd")
func measure(script: Script, effects: bool) -> Dictionary:
	var engine: Node=script.new()
	var actors:=Fixture.actors(2)
	for actor in actors: actor.hp=10000;actor.max_hp=10000
	engine.begin_encounter(actors)
	if effects:
		Status.apply(actors[0],"slow",0.0,-1.0,12.0)
		Status.apply(actors[1],"dot",0.0,-1.0,18.0)
	var samples: Array=[]
	for index in 2400:
		var start := Time.get_ticks_usec()
		engine.advance(1.0/60.0)
		if index>=120: samples.append(Time.get_ticks_usec()-start)
	engine.free()
	var probe := Probe.new()
	var result: Dictionary=probe.summarize(samples)
	probe.free()
	return result
func _initialize() -> void:
	var baseline: Script=load("res://.godot/build_intents_baseline_engine.gd")
	var current: Script=load("res://systems/combat_engine.gd")
	if baseline==null or current==null: quit(2);return
	var records: Array=[]
	for repetition in 3:
		records.append({"baseline":measure(baseline,false),"current":measure(current,false),"states_active":measure(current,true)})
	var result := {"repetitions":records,"unit":"microseconds per advance","reference":"dc485aa engine; same current AI/fixture/status dependencies; isolates intent integration overhead, not complete historical binary","limits":"headless CPU, not rendered frames or GPU; 120 warmup updates then 2280 samples; no nested scopes summed"}
	var file:=FileAccess.open("res://tests/evidence/build_intents_simulation_performance.json",FileAccess.WRITE)
	if file!=null: file.store_string(JSON.stringify(result,"\t"))
	print(JSON.stringify(result));quit()
