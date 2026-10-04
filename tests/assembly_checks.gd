extends RefCounted
var checks: Array[Dictionary]=[]
func check(label: String, passed: bool) -> void: checks.append({"name":label,"passed":passed})
func run() -> Dictionary:
	var session:=preload("res://systems/demo_session.gd").new()
	var first: String=session.principal_id
	var second: Dictionary=session.acquire("starter")
	var controller:=preload("res://systems/build_draft.gd").new(session)
	controller.select_copy(first)
	check("copies independent",session.owned(first).build==second.build and first!=second.id)
	var p: Dictionary=controller.payload("normal","range_1")
	check("click equips draft",controller.equip(p,"normal",0).ok and controller.dirty())
	check("draft not applied",session.owned(first).build.normal[0]=="")
	var click_build: Dictionary=controller.build.duplicate(true)
	controller.discard()
	check("drop equivalent",controller.equip(p,"normal",0).ok and controller.build==click_build)
	check("invalid drop leaves draft",not controller.equip(p,"modular",0).ok and controller.build==click_build)
	check("wrong copy rejected",not controller.equip({"kind":"normal","id":"range_1","origin":-1,"owned_id":second.id},"normal",0).ok)
	check("duplicate instance rejected",not controller.equip(p,"normal",1).ok)
	check("move mount",controller.equip(controller.payload("normal","range_1",0),"normal",1).ok and controller.build.normal[0]=="" and controller.build.normal[1]=="range_1")
	session.inventory.range_2="range"
	controller.equip(controller.payload("normal","range_2"),"normal",0)
	check("swap occupied mounts",controller.equip(controller.payload("normal","range_1",1),"normal",0).ok and controller.build.normal[1]=="range_2")
	check("remove explicit",controller.remove(1).ok and controller.build.normal[1]=="")
	check("duplicate modular rejected",not controller.equip(controller.payload("modular","far"),"modular",0).ok)
	check("move modular swaps",controller.equip(controller.payload("modular","close",0),"modular",1).ok and controller.build.modular==["far","close"])
	session.owned(first).hp=63;session.owned(first).turns=4;session.owned(first).ready_at={"close":8};session.owned(first).priority="close";session.owned(first).retained="close"
	check("apply draft",controller.apply().ok and not controller.dirty())
	check("state and marks persist",session.owned(first).hp==63 and session.owned(first).ready_at.close==8 and session.owned(first).priority=="close" and session.owned(first).retained=="close")
	controller.select_copy(second.id)
	check("editing does not select principal",session.principal_id==first and controller.build.normal[0]=="")
	check("other copy owns instance",controller.owner_of("range_1")==first and not controller.equip(controller.payload("normal","range_1"),"normal",0).ok)
	session.combat_locked=true
	check("combat locks editing",not controller.equip(controller.payload("normal","range_2"),"normal",0).ok and not controller.apply().ok)
	session.combat_locked=false
	var empty:=preload("res://data/visual_library.gd").new()
	var visuals:=preload("res://systems/visual_catalog.gd").new(empty)
	check("missing assets safe",visuals.icon("modifier","range")==null and visuals.anchors("starter").size()==10)
	var asset:=preload("res://data/visual_asset.gd").new();asset.kind="beast";asset.definition_id="starter";asset.editor_anchors=[Vector2(2,1)]
	empty.entries=[asset,asset]
	visuals=preload("res://systems/visual_catalog.gd").new(empty)
	check("invalid references diagnosed",visuals.issues.size()>=2 and visuals.anchors("starter").size()==10)
	asset.anchor_scales=[NAN];empty.entries=[asset]
	visuals=preload("res://systems/visual_catalog.gd").new(empty)
	check("invalid transforms excluded",visuals.get_asset("beast","starter")==null and not visuals.issues.is_empty())
	asset=preload("res://data/visual_asset.gd").new();asset.kind="modifier";asset.definition_id="range";asset.effect_seconds=-1.0;empty.entries=[asset]
	visuals=preload("res://systems/visual_catalog.gd").new(empty)
	check("invalid effect duration excluded",visuals.get_asset("modifier","range")==null and not visuals.issues.is_empty())
	var serialized: String=JSON.stringify(session.export_data())
	check("save contains no presentation",not "editor_anchors" in serialized and not "mounted_layer" in serialized)
	return {"passed":checks.all(func(row):return row.passed),"count":checks.size(),"checks":checks,"failures":checks.filter(func(row):return not row.passed)}
