extends RefCounted
const Damage=preload("res://systems/damage_resolution.gd")
const EngineScript=preload("res://systems/combat_engine.gd")
const Status=preload("res://systems/status_system.gd")
const AI=preload("res://systems/combat_ai.gd")
const Catalog=preload("res://data/catalog.gd")
var checks: Array=[]
var encounters: Array=[]
func check(label: String, value: bool) -> void: checks.append({"name":label,"passed":value})
func engine() -> Node:
	var value:=EngineScript.new();value.start(0)
	value.actors[1].defense=.2;value.actors[1].matrix_enabled=true
	value.actors[1].abilities[0].damage=8
	return value

func run() -> Dictionary:
	for row in [[18,14],[22,18],[30,24],[36,29],[4,3]]:
		var target: Dictionary={"defense":.2,"shield":0}
		check("mitigation "+str(row[0]),Damage.preview(target,row[0],0).damage==row[1])
		target.vulnerability_until=12.0
		check("rupture preserves potential "+str(row[0]),Damage.preview(target,row[0],0).damage==row[0])
	check("round halves upward",Damage.preview({"defense":.25,"shield":0},18,0).damage==14)
	check("old fixture defense zero",Damage.preview({"shield":0},30,0).damage==30)
	check("defense validation",not Damage.valid_defense(-.1) and not Damage.valid_defense(1.0) and not Damage.valid_defense(NAN) and Damage.valid_defense(.2))
	var shield: Dictionary={"defense":.2,"shield":10}
	check("protection after mitigation",Damage.preview(shield,30,0)=={"potential":30,"mitigated":6,"absorbed":10,"damage":14})
	shield.vulnerability_until=12.0
	check("rupture retains protection",Damage.preview(shield,30,0).damage==20)
	check("exact expiry has defense",Damage.preview(shield,30,12).damage==14)
	check("query immutable",shield.shield==10 and shield.defense==.2)
	var e:=engine();var target: Dictionary=e.actors[1];var token: int=e.encounter_serial
	check("old encounter rejected",not e.request_rupture(target.id,token-1).ok)
	check("own matrix rejected",not e.request_rupture("main",token).ok)
	check("unknown actor rejected",not e.request_rupture("missing",token).ok)
	var charge: float=e.actors[0].atb
	check("rupture accepted",e.request_rupture(target.id,token).ok and target.vulnerability_until==12.0)
	check("rupture no ATB cost",e.actors[0].atb==charge and e.pending.is_empty())
	check("repeat no extension",not e.request_rupture(target.id,token).ok and target.vulnerability_until==12.0)
	e.command("priority","close");e.command("retain","close")
	check("commands coexist",e.priority=="close" and e.retained=="close")
	target.shield=10;e.apply_damage(target,30)
	check("shared live damage",target.hp==80 and target.shield==0 and e.last_damage.breakdown.damage==20)
	e.finish("Prueba")
	check("end cleans rupture",target.vulnerability_until==-1 and not target.rupture_used)
	check("finished request rejected",not e.request_rupture(target.id,token).ok);e.free()
	e=engine();target=e.actors[1]
	target.retired=true;check("retirement rejects",not e.request_rupture(target.id,e.encounter_serial).ok)
	target.retired=false;target.hp=0;check("death rejects",not e.request_rupture(target.id,e.encounter_serial).ok);e.free()
	e=engine();target=e.actors[1];target.matrix_enabled=false
	check("diagnostic inert actor rejects",not e.request_rupture(target.id,e.encounter_serial).ok);e.free()
	e=engine();target=e.actors[1]
	e.request_rupture(target.id,e.encounter_serial)
	# Prevent actions so only periodic event timing affects the test.
	for actor in e.actors: actor.speed=.01
	Status.apply(target,"dot",0)
	e.advance(12.0)
	check("pulses consult expiry",target.hp==89 and target.states.is_empty())
	check("expiry clears clock",target.vulnerability_until==-1 and target.rupture_used)
	e.initialize_atb();check("new encounter resets",not target.rupture_used and target.vulnerability_until==-1)
	e.free()
	e=engine();target=e.actors[1]
	e.request_rupture(target.id,e.encounter_serial)
	for actor in e.actors: actor.speed=.01
	Status.apply(target,"dot",0)
	for tick in 120: e.advance(.1)
	check("partitioned delta expiry",target.hp==89)
	e.free()
	e=engine();target=e.actors[1]
	var attack: Dictionary=Catalog.new().skill("close")
	e.pending={"actor_id":"main","target_id":target.id,"skill":attack,"reason":"Prueba"};e.elapsed=2.0;e.resolved=false
	e.request_rupture(target.id,e.encounter_serial);e.advance(.2)
	check("anticipation rupture affects impact",target.hp==70)
	var hp: int=target.hp;e.request_rupture(target.id,e.encounter_serial)
	check("no retroactive impact",target.hp==hp)
	e.free()
	var periodic: Dictionary={"defense":.2,"shield":0,"states":{},"vulnerability_until":8.0}
	check("AI includes known expiry",Damage.additional_dot(periodic,0,12)==10.0)
	periodic.states.dot={"intensity":4.0,"next":4.0,"expires":12.0}
	check("AI excludes equivalent active damage",Damage.additional_dot(periodic,0,12)==0)
	check("AI extension only new pulses",Damage.additional_dot(periodic,0,18)==3.0)
	var catalog:=Catalog.new();var original: Dictionary=catalog.skill("close")
	for kind in ["pressure","wear","control"]:
		var pair: Array=[]
		for broken in [false,true]:
			e=engine()
			var ids: Array=["close","far"] if kind=="pressure" else (["residual","far"] if kind=="wear" else ["slow","close"])
			e.actors[0].abilities=[catalog.skill("basic"),catalog.skill("guard"),catalog.skill(ids[0]),catalog.skill(ids[1])]
			for skill in e.actors[0].abilities:
				if kind=="pressure" or kind=="control": skill.damage=int(floor(skill.damage*1.2+.5))
				if kind!="pressure" and skill.has("status_duration"): skill.status_duration*=1.5
			e.advance(18.0)
			if broken: e.request_rupture(e.actors[1].id,e.encounter_serial)
			e.advance(12.0)
			var window_hp: int=e.actors[1].hp
			var ticks:=0
			while e.running and ticks<2000: e.advance(.1);ticks+=1
			pair.append({"broken":broken,"result":e.result,"seconds":e.combat_clock,"actions":e.action_count,"hp":e.actors[0].hp,"enemy_hp_at_30":window_hp})
			check(kind+(" with" if broken else " without")+" matrix remains viable",e.result=="Victoria")
			e.free()
		encounters.append({"build":kind,"cases":pair})
		check(kind+" rupture increases actual window damage",pair[1].enemy_hp_at_30<pair[0].enemy_hp_at_30)
	check("catalog unchanged",catalog.skill("close")==original)
	var failures: Array=checks.filter(func(row):return not row.passed)
	return {"passed":failures.is_empty(),"count":checks.size(),"checks":checks,"failures":failures,"encounters":encounters}
