extends RefCounted
const Session = preload("res://systems/demo_session.gd")
const EngineScript = preload("res://systems/combat_engine.gd")
const Fixture = preload("res://data/combat_fixture.gd")
const Status = preload("res://systems/status_system.gd")
const AI = preload("res://systems/combat_ai.gd")
var checks: Array[Dictionary] = []
func check(label: String, passed: bool) -> void: checks.append({"name":label,"passed":passed})
func run() -> Dictionary:
	checks.clear()
	var session := Session.new()
	var beast := session.principal()
	var build: Dictionary = beast.build.duplicate(true)
	build.normal[0]="range_1"; build.normal[1]="power_1"; build.normal[2]="duration_1"
	var preview: Dictionary = session.preview_build(beast.id,build)
	check("independent properties",preview.abilities[0].range==520.0 and preview.abilities[0].damage==22)
	check("close power",preview.abilities[2].damage==36 and preview.abilities[2].range==312.0)
	check("guard unchanged",preview.abilities[1].shield==24 and preview.abilities[1].range==0 and preview.abilities[1].damage==0)
	check("catalog immutable",session.catalog.skill("basic").damage==18 and session.catalog.skill("basic").range==400.0)
	check("duration incompatible instantaneous",preview.abilities[0].status_duration==0)
	session.acquire("residual_beast"); session.acquire("ranged_beast")
	build.modular=["residual","slow"]
	preview=session.preview_build(beast.id,build)
	check("DOT duration",preview.abilities[2].status_duration==18.0)
	check("slow duration",preview.abilities[3].status_duration==12.0)
	check("direct damage only",preview.abilities[2].damage==12 and preview.abilities[3].damage==7)
	check("cooldown unchanged",preview.abilities[2].cooldown==2)
	session.inventory.power_2="power";build.normal[3]="power_2"
	check("sum percentages once",session.preview_build(beast.id,build).abilities[0].damage==25)
	beast.hp=39;beast.ready_at.close=7
	check("apply preserves state",session.apply_build(beast.id,build).ok and beast.hp==39 and beast.ready_at.close==7)
	check("copies independent",session.collection[1].build.normal[0]=="")
	var old := session.export_data()
	old.erase("build_content_version");old.inventory.erase("power_1");old.inventory.erase("duration_1")
	old.collection[0].build.normal[1]="";old.collection[0].build.normal[2]=""
	old=JSON.parse_string(JSON.stringify(old))
	var restored := Session.new()
	var migration: Dictionary=restored.restore_data(old)
	check("legacy migration: "+str(migration),migration.ok and restored.inventory.has("power_1") and restored.inventory.has("duration_1"))
	check("migration preserves copy",restored.principal_id==session.principal_id and restored.principal().hp==39 and restored.principal().ready_at.close==7)
	var upgraded := restored.export_data();upgraded.inventory.erase("duration_1")
	check("migration not repeated",restored.restore_data(upgraded).ok and not restored.inventory.has("duration_1"))
	check("shared timing",Fixture.ACTION_SECONDS==3.8 and Fixture.RESOLVE_SECONDS==2.2)
	var failures: Array = checks.filter(func(row):return not row.passed)
	return {"passed":failures.is_empty(),"count":checks.size(),"checks":checks,"failures":failures}
