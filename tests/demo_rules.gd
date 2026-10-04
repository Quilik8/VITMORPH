extends RefCounted
var results: Array[Dictionary] = []
const Session = preload("res://systems/demo_session.gd")

func check(label: String, condition: bool) -> void:
	results.append({"name":label,"passed":condition})

func run() -> Dictionary:
	results.clear()
	var session := Session.new()
	var id: String = session.principal_id
	var beast: Dictionary = session.principal()
	var build: Dictionary = beast.build.duplicate(true)
	check("catalog references",session.catalog.check().is_empty())
	check("initial library",session.library.size()==2)
	check("slot structure",build.normal.size()==8 and build.special.size()==2)
	build.normal[0] = "range_1"
	check("normal equipped",session.apply_build(id,build).ok)
	var preview: Dictionary = session.preview_build(id,build)
	check("basic range",is_equal_approx(preview.abilities[0].range,520.0))
	check("guard unaffected",preview.abilities[1].range==0.0)
	check("close range",is_equal_approx(preview.abilities[2].range,312.0))
	check("far range",is_equal_approx(preview.abilities[3].range,780.0))
	check("definition untouched",session.catalog.skill("basic").range==400.0)
	var bad: Dictionary = build.duplicate(true)
	bad.modular = ["close","close"]
	check("duplicate modular rejected",not session.apply_build(id,bad).ok)
	bad = build.duplicate(true)
	bad.normal[1] = "range_1"
	check("duplicate instance rejected",not session.apply_build(id,bad).ok)
	bad.modular = ["residual","far"]
	check("locked modular rejected",not session.validate_build(id,bad).ok)
	beast.hp = 33
	beast.ready_at.close = 6
	beast.priority = "close"
	beast.retained = "far"
	build.modular = ["far","close"]
	check("swap accepted",session.apply_build(id,build).ok)
	check("swap marks and health",beast.priority=="close" and beast.retained=="far" and beast.hp==33 and beast.ready_at.close==6)
	session.acquire("residual_beast")
	build.modular = ["residual","slow"]
	session.apply_build(id,build)
	check("removed marks clear",beast.priority=="" and beast.retained=="")
	check("unequipped cooldown kept",beast.ready_at.close==6)
	session.combat_locked = true
	check("combat locks builds",not session.apply_build(id,build).ok)
	check("combat locks main",not session.select_principal(session.collection[1].id).ok)
	session.combat_locked = false
	check("select copied main",session.select_principal(session.collection[1].id).ok)
	check("individual identity and state",session.principal_id!=id and session.owned(id).hp==33)
	var failures: Array = results.filter(func(row): return not row.passed)
	return {"passed":failures.is_empty(),"count":results.size(),"failures":failures,"checks":results}
