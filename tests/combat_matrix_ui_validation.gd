extends Node
var report: Dictionary={"running":true,"checks":[],"layouts":[]}
func check(label: String, valid: bool) -> void: report.checks.append({"name":label,"passed":valid})
func run(main: Node) -> void:
	var driver: Node=main.get_node("BuildIntentsDiagnostics")
	var original_size: Vector2i=main.get_window().content_scale_size
	var positions: Array=[]
	main.combat.command("priority","guard");main.combat.command("retain","guard")
	for actor in main.combat.actors: positions.append(actor.position)
	for dimensions in [Vector2i(1200,820),Vector2i(1018,696),Vector2i(760,820),Vector2i(640,640)]:
		driver.resize(dimensions.x,dimensions.y)
		await get_tree().process_frame;await get_tree().process_frame
		main.open_own_matrix()
		await get_tree().process_frame;await get_tree().process_frame
		var footer: Rect2=main.intervention_strip.get_global_rect()
		var panel: Rect2=main.matrix_view.get_global_rect()
		check(str(dimensions)+" footer within window",footer.end.y<=main.size.y and footer.end.x<=main.size.x)
		check(str(dimensions)+" panel within window",panel.end.y<=main.size.y and panel.end.x<=main.size.x)
		check(str(dimensions)+" status within window",main.save_label.get_global_rect().end.y<=main.size.y)
		check(str(dimensions)+" correct orientation",main.battle_region.vertical==(dimensions.x<1000))
		check(str(dimensions)+" allocated matrix size",is_equal_approx(panel.size.y,220) if dimensions.x<1000 else is_equal_approx(panel.size.x,320))
		report.layouts.append({"logical":[main.size.x,main.size.y],"field":[main.arena.size.x,main.arena.size.y],"matrix":[panel.size.x,panel.size.y],"footer_end":footer.end.y})
		main.matrix.close()
	check("world positions untouched",positions==main.combat.actors.map(func(actor):return actor.position))
	main.open_own_matrix();main.matrix.rotate(-1)
	var progress: Dictionary=main.matrix.current()
	driver.resize(620,620);await get_tree().process_frame;await get_tree().process_frame
	check("below minimum closes",main.matrix.owner_id=="")
	check("below minimum message",main.save_label.text=="Amplía la ventana para editar la matriz")
	driver.resize(760,820);await get_tree().process_frame;await get_tree().process_frame
	main.open_own_matrix();check("below minimum retains progress",main.matrix.current()==progress)
	await get_tree().process_frame
	main.matrix_view.rings.grab_focus()
	var focus: Control=main.get_viewport().gui_get_focus_owner()
	main.show_parry_probe();check("Parry probe keeps focus",main.get_viewport().gui_get_focus_owner()==focus)
	check("Parry probe keeps matrix",main.matrix.current()==progress)
	var saved_owner: String=main.matrix.owner_id
	main.matrix.close();await get_tree().process_frame;await get_tree().process_frame
	check("closing focuses target",main.get_viewport().gui_get_focus_owner()==main.copy_targets)
	main.open_matrix(saved_owner)
	check("reopening keeps progress",main.matrix.current()==progress)
	main.matrix.close();driver.resize(original_size.x,original_size.y)
	report.running=false
	var failures: Array=report.checks.filter(func(row):return not row.passed)
	report["passed"]=failures.is_empty();report["failures"]=failures;report["count"]=report.checks.size()
	var output:=FileAccess.open("res://tests/evidence/combat_matrix_ui_checks.json",FileAccess.WRITE)
	if output!=null: output.store_string(JSON.stringify(report,"\t"))
