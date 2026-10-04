extends Node
var report: Dictionary={"running":true}
var original: Dictionary={}
var root: Node

func pointer_drag(source_name: String, target_index: int, cancel := false) -> void:
	report={"running":true}
	var editor: Control=root.editor
	var source: Control=editor.find_child(source_name,true,false)
	var start: Vector2=source.get_global_rect().get_center()
	var destination: Vector2=editor.mounts[target_index].get_global_rect().get_center() if target_index>=0 else Vector2(8,8)
	var before: Dictionary=editor.draft.duplicate(true)
	var count: int=editor.native_drag_count
	var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=start;press.global_position=start
	get_viewport().push_input(press,true)
	await get_tree().process_frame
	var motion:=InputEventMouseMotion.new();motion.position=start+Vector2(0,-24);motion.global_position=motion.position;motion.relative=Vector2(0,-24);motion.button_mask=MOUSE_BUTTON_MASK_LEFT
	get_viewport().push_input(motion,true)
	await get_tree().process_frame
	motion=InputEventMouseMotion.new();motion.position=destination;motion.global_position=destination;motion.relative=destination-start;motion.button_mask=MOUSE_BUTTON_MASK_LEFT
	get_viewport().push_input(motion,true)
	await get_tree().process_frame
	if cancel:
		var escape:=InputEventKey.new();escape.keycode=KEY_ESCAPE;escape.pressed=true
		get_viewport().push_input(escape,true)
	var release:=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=destination;release.global_position=destination
	get_viewport().push_input(release,true)
	await get_tree().process_frame;await get_tree().process_frame
	report={"running":false,"native_drag_started":editor.native_drag_count>count,"before":before,"after":editor.draft.duplicate(true),"applied":root.session.owned(editor.owned_id).build.duplicate(true),"cancelled":cancel,"outside":target_index<0,"method":"Actual Viewport mouse events with held button mask; configured MCP calls this isolated test helper. MCP input_simulate omits MouseMotion.button_mask."}

func begin(main: Node) -> void:
	root=main
	original={"session":main.session.export_data(),"world":main.route.export_data(),"diagnostic":main.diagnostic_mode,"path":main.save_service.path}
	main.save_service.flush();main.diagnostic_mode=true;main.save_service.path="user://tests/assembly_runtime.json"
	if not main.editor.controller.owned_id.is_empty(): main.editor.discard()
	main.editor.close()
	main.session.restore_data(preload("res://systems/demo_session.gd").new().export_data())
	main.session.acquire("starter")
	main.session.library.append("residual");main.session.library.append("slow")
	main.session.inventory.range_2="range"
	main.route.start();main.refresh();main.open_build(false)

func finish() -> void:
	root.editor.discard();root.editor.close();root.save_service.flush()
	root.restore_checkpoint({"session":original.session,"world":original.world})
	root.save_service.path=original.path;root.diagnostic_mode=original.diagnostic

func cycles(main: Node) -> void:
	begin(main)
	main.editor.close()
	for warm in 2:
		main.open_build(false);await get_tree().process_frame
		main.editor.close();await get_tree().process_frame;await get_tree().process_frame
	var records: Array=[]
	for index in 20:
		var stamp:=Time.get_ticks_usec()
		main.open_build(false)
		var open_cpu:=Time.get_ticks_usec()-stamp
		await get_tree().process_frame;await get_tree().process_frame
		stamp=Time.get_ticks_usec()
		main.editor.choose_item(main.editor.controller.payload("normal","range_1"))
		main.editor.choose_target("normal",0)
		var update_cpu:=Time.get_ticks_usec()-stamp
		await get_tree().process_frame;await get_tree().process_frame
		records.append({"index":index,"open_cpu_usec":open_cpu,"update_cpu_usec":update_cpu,"monitors":main.profile.monitors()})
		main.editor.discard();main.editor.close()
		await get_tree().process_frame;await get_tree().process_frame
	var stable: bool=records[0].monitors.nodes==records[-1].monitors.nodes and records[0].monitors.resources==records[-1].monitors.resources and records[-1].monitors.orphan_nodes==0
	report={"running":false,"passed":stable,"cycles":records,"open_cpu":main.profile.summarize(records.map(func(row):return row.open_cpu_usec)),"update_cpu":main.profile.summarize(records.map(func(row):return row.update_cpu_usec)),"limits":"CPU includes synchronous render work; frames awaited separately; compare same warmed view. Not GPU time or OS RAM."}
	finish()

func presentation(main: Node) -> void:
	var checks: Array=[]
	var library:=preload("res://data/visual_library.gd").new()
	var beast:=preload("res://data/visual_asset.gd").new();beast.kind="beast";beast.definition_id="starter"
	# Empty in-memory texture fixture, not generated or supplied game art.
	beast.body=PlaceholderTexture2D.new();beast.icon=beast.body
	var mod:=preload("res://data/visual_asset.gd").new();mod.kind="modifier";mod.definition_id="range";mod.mounted_layer=PlaceholderTexture2D.new();mod.icon=mod.mounted_layer
	var effect:=Node2D.new();mod.equip_effect=PackedScene.new();mod.equip_effect.pack(effect);effect.free();mod.effect_seconds=.1
	mod.persistent_effect=mod.equip_effect;mod.execution_effect=mod.equip_effect;mod.impact_effect=mod.equip_effect
	beast.anchor_z=[-1,1,1,1,1,1,1,1,1,1]
	library.entries=[beast,mod]
	var visuals:=preload("res://systems/visual_catalog.gd").new(library)
	checks.append({"name":"complete typed presentation resources","passed":visuals.issues.is_empty() and visuals.icon("modifier","range")!=null})
	var view:=preload("res://ui/beast_visual.gd").new();view.visuals=visuals;view.catalog=main.session.catalog;add_child(view);view.hide()
	var build: Dictionary=main.session.builds.empty_build(["close","far"]);build.normal[0]="range_1"
	view.configure("starter",build,{"range_1":"range"},Vector2(100,100))
	checks.append({"name":"layer and persistent effect mounted behind body","passed":view.layers.size()==2 and view.layers[0].z_index==-1 and view.has_body()})
	view.play_mount("range_1",0)
	checks.append({"name":"mount burst once","passed":view.effects_started==1 and view.bursts.size()==1})
	view.play_skill("basic");view.play_skill("basic",true)
	checks.append({"name":"execution and impact from mod","passed":view.effects_started==3})
	view.play_skill("guard")
	checks.append({"name":"range mod effect excludes own defense","passed":view.effects_started==3})
	for index in 20: view.play_skill("basic")
	checks.append({"name":"transient effects bounded","passed":view.bursts.size()==12})
	await get_tree().create_timer(.2).timeout
	checks.append({"name":"transient effects released","passed":view.bursts.is_empty()})
	build.normal[0]="";view.configure("starter",build,{"range_1":"range"},Vector2(100,100))
	checks.append({"name":"removal clears persistent visuals","passed":view.layers.is_empty()})
	view.queue_free()
	begin(main)
	var old_visuals: RefCounted=main.arena.visuals
	main.arena.visuals=visuals
	var applied_build: Dictionary=main.session.principal().build.duplicate(true);applied_build.normal[0]="range_1"
	main.session.apply_build(main.session.principal_id,applied_build);main.on_build_applied()
	main.editor.controller.discard()
	main.editor.choose_item(main.editor.controller.payload("normal","range_2"));main.editor.choose_target("normal",3)
	main.arena.sync_visuals(true)
	checks.append({"name":"world uses applied build while editor previews draft","passed":main.arena.actor_visuals.main.build==applied_build and main.editor.draft!=applied_build})
	checks.append({"name":"world assets and layers instantiated","passed":main.arena.actor_visuals.main.layers.size()==2 and main.arena.actor_visuals.main.world_mode})
	main.editor.discard()
	checks.append({"name":"discard restores preview to applied build","passed":main.editor.beast_visual.build==applied_build})
	for node in main.arena.actor_visuals.values(): node.queue_free()
	main.arena.actor_visuals.clear();main.arena.visuals=old_visuals
	finish()
	report={"running":false,"passed":checks.all(func(row):return row.passed),"count":checks.size(),"checks":checks,"limits":"In-memory empty texture and Node2D fixtures; no user art supplied or generated."}

func editor_contract(main: Node) -> void:
	begin(main)
	var checks: Array=[]
	var editor: Control=main.editor
	editor.choose_item(editor.controller.payload("normal","range_1"));editor.choose_target("normal",0)
	editor.request_action({"kind":"copy","id":"copy_000002"})
	checks.append({"name":"switch with dirty build offers decision","passed":editor.decision.visible and editor.owned_id=="copy_000001"})
	main.session.combat_locked=true
	checks.append({"name":"apply failure retains draft and decision","passed":not editor.apply() and editor.controller.dirty() and editor.decision.visible})
	main.session.combat_locked=false;editor.discard();editor.finish_pending()
	checks.append({"name":"discard switch leaves first copy intact","passed":editor.owned_id=="copy_000002" and main.session.owned("copy_000001").build.normal[0]==""})
	editor.choose_item(editor.controller.payload("normal","range_1"));editor.choose_target("normal",1)
	editor.request_action({"kind":"principal"})
	checks.append({"name":"principal switch awaits decision","passed":editor.decision.visible and main.session.principal_id=="copy_000001"})
	if editor.apply(): editor.finish_pending()
	checks.append({"name":"apply then explicitly choose principal","passed":main.session.principal_id=="copy_000002" and main.session.principal().build.normal[1]=="range_1"})
	editor.choose_item(editor.controller.payload("normal","range_2"));editor.choose_target("normal",2)
	editor.close()
	checks.append({"name":"dirty close keeps exploration paused","passed":editor.visible and editor.decision.visible and main.route.menu_paused})
	editor.pending_action.clear();editor.decision.hide()
	checks.append({"name":"continue editing keeps draft","passed":editor.controller.dirty() and editor.visible})
	editor.discard();editor.close()
	checks.append({"name":"clean close restores exploration","passed":not editor.visible and not main.route.menu_paused and main.route.held_keys.is_empty()})
	main.open_build(false)
	checks.append({"name":"reopen applied build","passed":editor.draft.normal[1]=="range_1" and editor.owned_id==main.session.principal_id})
	report={"running":false,"passed":checks.all(func(row):return row.passed),"count":checks.size(),"checks":checks}
	finish()

func compare_legacy(main: Node) -> void:
	if not FileAccess.file_exists("res://.codex/legacy_build_editor.gd"):
		report={"running":false,"passed":false,"reason":"Recreate ignored legacy fixture from 82d8e1a:ui/build_editor.gd before comparison."};return
	begin(main)
	var legacy_script: Script=load("res://.codex/legacy_build_editor.gd")
	var legacy: Control=legacy_script.new();legacy.session=main.session;legacy.theme=main.theme;add_child(legacy)
	var before: Array=[];var after: Array=[]
	for index in 4:
		main.editor.discard();main.editor.close()
		var stamp:=Time.get_ticks_usec();legacy.open(main.session.principal_id);var opening:=Time.get_ticks_usec()-stamp
		await get_tree().process_frame;await get_tree().process_frame
		legacy.section="mods";legacy.selected=0;legacy.draft.normal[0]="range_1"
		stamp=Time.get_ticks_usec();legacy.render();var updating:=Time.get_ticks_usec()-stamp
		await get_tree().process_frame;await get_tree().process_frame
		if index>0: before.append({"open_cpu_usec":opening,"update_cpu_usec":updating})
		legacy.close()
		stamp=Time.get_ticks_usec();main.open_build(false);opening=Time.get_ticks_usec()-stamp
		await get_tree().process_frame;await get_tree().process_frame
		stamp=Time.get_ticks_usec();main.editor.receive_drop(main.editor.controller.payload("normal","range_1"),"normal",0);updating=Time.get_ticks_usec()-stamp
		await get_tree().process_frame;await get_tree().process_frame
		if index>0: after.append({"open_cpu_usec":opening,"update_cpu_usec":updating})
	legacy.queue_free()
	report={"running":false,"before":before,"after":after,"source":"82d8e1a:ui/build_editor.gd copied unchanged to ignored .codex for comparison; identical isolated session with two copies, four library skills and two mods. First warm pair excluded.","limits":"New editor includes hero, ten body controls and pending-change handling. CPU synchronous only; layouts settle outside timers. Updates compare direct draft mutation + old render against new validated drop + render."}
	finish()

func effects_profile(main: Node) -> void:
	begin(main)
	var library:=preload("res://data/visual_library.gd").new()
	var mod:=preload("res://data/visual_asset.gd").new();mod.kind="modifier";mod.definition_id="range"
	var node:=Node2D.new();mod.execution_effect=PackedScene.new();mod.execution_effect.pack(node);node.free();mod.effect_seconds=.8
	library.entries=[mod]
	var view:=preload("res://ui/beast_visual.gd").new();view.visuals=preload("res://systems/visual_catalog.gd").new(library);view.catalog=main.session.catalog;add_child(view);view.hide()
	var build: Dictionary=main.session.principal().build.duplicate(true);build.normal[0]="range_1"
	view.configure("starter",build,main.session.inventory,Vector2(100,100))
	var samples: Array=[]
	for repetition in 3:
		main.profile.begin(3.0,"assembly_effects_%d"%repetition)
		while main.profile.active:
			var stamp:=Time.get_ticks_usec();view.play_skill("basic");main.profile.record("assembly:effect_spawn",Time.get_ticks_usec()-stamp)
			await get_tree().create_timer(.1).timeout
		samples.append(main.profile.report())
	await get_tree().create_timer(1.0).timeout
	var released: bool=view.bursts.is_empty()
	view.queue_free();finish()
	report={"running":false,"passed":released,"samples":samples,"limits":"Empty Node2D fixture isolates scheduling/allocation/cleanup only. No texture, particle, shader, audio or user-art GPU load; not an art budget guarantee."}
