extends Node
var main: Node
var report: Dictionary={}
var enemy_mode := false
func start(root: Node, functional := false) -> void:
	enemy_mode=functional
	main=root;report={"running":true,"repetitions":[],"cycles":[]}
	main.build_intents_diagnostics("begin")
	for iteration in 3:
		var pair: Dictionary={}
		for opened in [false,true]:
			main.matrix.sync(false,[])
			main.get_node("BuildIntentsDiagnostics").combat_view()
			if enemy_mode:
				main.combat.actors[1].defense=.2;main.combat.actors[1].matrix_enabled=true
			if opened:
				if enemy_mode: main.open_matrix(main.combat.actors[1].id)
				else: main.open_own_matrix()
			main.combat.advance(9.0)
			if opened and enemy_mode:
				for index in 3:
					main.matrix.select_ring(index)
					for count in [1,3,5][index]: main.matrix.rotate(-1)
			main.combat.set_process(true)
			await get_tree().create_timer(.5).timeout
			main.profile.begin(4.0,"matrix_"+str(iteration)+("_open" if opened else "_closed"))
			await get_tree().create_timer(4.2).timeout
			pair["open" if opened else "closed"]=main.profile.report()
		report.repetitions.append(pair)
	main.get_node("BuildIntentsDiagnostics").combat_view()
	if enemy_mode:
		main.combat.actors[1].defense=.2;main.combat.actors[1].matrix_enabled=true
		main.combat.request_rupture(main.combat.actors[1].id,main.combat.encounter_serial)
	main.matrix.close()
	# Warm node/font/layout caches before measuring bounded cycles.
	open_cycle();await get_tree().process_frame;main.matrix.close();await get_tree().process_frame
	for iteration in 20:
		var start_usec:=Time.get_ticks_usec();open_cycle()
		var open_usec:=Time.get_ticks_usec()-start_usec
		await get_tree().process_frame;await get_tree().process_frame
		main.matrix.rotate(1);main.matrix.close()
		await get_tree().process_frame;await get_tree().process_frame
		report.cycles.append({"index":iteration,"open_cpu_usec":open_usec,"monitors":main.profile.monitors()})
	report.running=false
	var file:=FileAccess.open("res://tests/evidence/enemy_matrix_performance.json" if enemy_mode else "res://tests/evidence/combat_matrix_runtime_performance.json",FileAccess.WRITE)
	if file!=null: file.store_string(JSON.stringify(report,"\t"))
	main.build_intents_diagnostics("finish")

func open_cycle() -> void:
	if enemy_mode: main.open_matrix(main.combat.actors[1].id)
	else: main.open_own_matrix()
