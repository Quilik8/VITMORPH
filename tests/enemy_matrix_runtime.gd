extends Node
var report: Dictionary={"running":true,"checks":[],"layouts":[]}
func check(label: String, value: bool) -> void: report.checks.append({"name":label,"passed":value})
func run(main: Node) -> void:
	main.start_enemy_matrix_trial()
	main.combat.set_process(false)
	var driver: Node=main.get_node("BuildIntentsDiagnostics")
	var owner: String=main.combat.actors[1].id
	main.open_matrix(owner)
	var before: Dictionary=main.matrix.current()
	main.matrix_view.rings.grab_focus()
	var focus: Control=main.get_viewport().gui_get_focus_owner()
	for index in 3:
		main.matrix.select_ring(index)
		for count in [1,3,5][index]: main.matrix.rotate(-1)
	check("solving requests actual rupture",main.combat.actors[1].rupture_used and main.combat.actors[1].vulnerability_until==12.0)
	check("solve preserves focus",main.get_viewport().gui_get_focus_owner()==focus)
	check("status explains rupture",main.matrix_view.status.text.contains("Defensa rota"))
	for dimensions in [Vector2i(1200,820),Vector2i(1018,696),Vector2i(760,820),Vector2i(640,640)]:
		driver.resize(dimensions.x,dimensions.y)
		await get_tree().process_frame;await get_tree().process_frame
		check(str(dimensions)+" commands inside",main.intervention_strip.get_global_rect().end.y<=main.size.y)
		check(str(dimensions)+" functional matrix inside",main.matrix_view.get_global_rect().end.y<=main.size.y)
		report.layouts.append({"logical":[main.size.x,main.size.y],"status":main.matrix_view.status.text})
	main.combat.command("priority","close");main.combat.command("retain","close")
	check("commands survive rupture",main.combat.priority=="close" and main.combat.retained=="close")
	await get_tree().process_frame;await get_tree().process_frame
	check("marked commands inside minimum",main.intervention_strip.get_global_rect().end.y<=main.size.y)
	main.matrix_view.rings.grab_focus()
	main.show_parry_probe()
	check("Parry preserves functional matrix focus",main.get_viewport().gui_get_focus_owner()==main.matrix_view.rings and main.matrix.current().resolved)
	main.combat.advance(12.0);main.refresh();main.matrix_view.update_view()
	check("expired status",main.matrix_view.status.text.contains("ruptura utilizada"))
	main.matrix.close();main.open_matrix(owner)
	check("reopen remains aligned",main.matrix.current().resolved)
	check("cannot repeat rupture",not main.combat.request_rupture(owner,main.combat.encounter_serial).ok)
	check("initial progress distinct",before.positions==[1,3,5])
	main.end_enemy_matrix_trial()
	check("normal profile restored",not main.diagnostic_mode and main.save_service.path=="user://vitmorph_demo.json")
	report.running=false
	var failures: Array=report.checks.filter(func(row):return not row.passed)
	report.passed=failures.is_empty();report.failures=failures;report.count=report.checks.size()
	var file:=FileAccess.open("res://tests/evidence/enemy_matrix_ui_checks.json",FileAccess.WRITE)
	if file!=null: file.store_string(JSON.stringify(report,"\t"))
