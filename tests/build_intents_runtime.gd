extends Node
var main: Node
var original: Dictionary
var report := {}
func begin(root: Node) -> void:
	main=root
	original={"size":main.get_window().size,"scale":main.get_window().content_scale_size,"session":main.session.export_data(),"world":main.route.export_data(),"diagnostic":main.diagnostic_mode,"path":main.save_service.path}
	main.assembly_diagnostics("begin")
func combat_view() -> void:
	main.editor.discard();main.editor.close()
	main.route.start()
	main.route.actors[0].position=Vector2(1480,280)
	main.route.camera_x=1080;main.route.camera_y=0
	main.route.begin_encounter(main.route.group_for("zone_2"))
	main.combat.set_process(false)
	main.refresh()
func resize(width: int, height: int) -> void:
	main.get_window().content_scale_size=Vector2i(width,height)
	main.get_window().size=Vector2i(width,height)
func finish() -> void:
	main.combat.set_process(true)
	main.combat.running=false;main.combat.intentions_dirty=true;main.combat.refresh_intentions()
	main.editor.discard();main.editor.close();main.save_service.flush()
	main.restore_checkpoint({"session":original.session,"world":original.world})
	main.save_service.path=original.path;main.diagnostic_mode=original.diagnostic
	main.get_window().content_scale_size=original.scale
	main.get_window().size=original.size
func cycles() -> void:
	main.assembly_diagnostics("cycles")
	await get_tree().process_frame
	while main.get_node("AssemblyDiagnostics").report.get("running",true): await get_tree().process_frame
	report=main.get_node("AssemblyDiagnostics").report.duplicate(true)
