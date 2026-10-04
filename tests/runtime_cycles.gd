extends Node
var report: Dictionary={"running":true}

func run(main: Node) -> void:
	var saved_path: String=main.save_service.path
	var saved_snapshot: Dictionary={"session":main.session.export_data(),"world":main.route.export_data()}
	main.save_service.flush()
	main.save_service.path="user://tests/runtime_cycles.json"
	main.combat.running=false
	main.route.start()
	for warm in 2:
		main.open_build(false);await get_tree().process_frame
		main.editor.close();await get_tree().process_frame;await get_tree().process_frame
	var before: Dictionary=main.profile.monitors()
	var cycles: Array=[]
	for index in 20:
		var stamp:=Time.get_ticks_usec()
		main.open_build(index%2==1)
		await get_tree().process_frame
		var open_usec:=Time.get_ticks_usec()-stamp
		main.editor.close()
		await get_tree().process_frame;await get_tree().process_frame
		cycles.append({"cycle":index+1,"view":"collection" if index%2==1 else "build","open_wall_usec":open_usec,"monitors":main.profile.monitors()})
	var after: Dictionary=main.profile.monitors()
	var tours: Array=[]
	for index in 5:
		main.route.actors[0].position=Vector2(530,150)
		await get_tree().process_frame;await get_tree().process_frame
		var started: bool=main.combat.running
		main.combat.priority=""
		main.combat.retained=""
		for step in 4000:
			if not main.combat.running:break
			main.combat.advance(0.1)
		await get_tree().process_frame
		main.route.aftermath=3.0
		await get_tree().process_frame
		main.route.actors[0].position=Vector2(150,260)
		main.route.rest()
		await get_tree().process_frame;await get_tree().process_frame
		main.save_service.flush()
		tours.append({"tour":index+1,"started":started,"refuge":main.route.at_refuge(),"monitors":main.profile.monitors(),"save_write_usec":main.save_service.last_write_usec})
	main.save_service.flush()
	main.save_service.path=saved_path
	main.restore_checkpoint(saved_snapshot)
	var stable := true
	for parity in 2:
		stable=stable and cycles[parity].monitors.nodes==cycles[18+parity].monitors.nodes and cycles[parity].monitors.resources==cycles[18+parity].monitors.resources
	report={"running":false,"before":before,"after":after,"ui_cycles":cycles,"tours":tours,"scene_instance":main.get_instance_id(),"passed":stable and tours.all(func(tour):return tour.started and tour.refuge),"method":"Compare same view first/last; hidden editor retains different node counts by view. Tours warmed graphic memory compared separately."}
