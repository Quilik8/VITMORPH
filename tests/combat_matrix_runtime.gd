extends Node
var main: Node
var report: Dictionary={}
func start(root: Node) -> void:
	main=root;report={"running":true,"repetitions":[],"cycles":[]}
	main.build_intents_diagnostics("begin")
	for iteration in 3:
		var pair: Dictionary={}
		for opened in [false,true]:
			main.matrix.sync(false,[])
			main.get_node("BuildIntentsDiagnostics").combat_view()
			if opened: main.open_own_matrix()
			main.combat.advance(9.0)
			main.combat.set_process(true)
			await get_tree().create_timer(.5).timeout
			main.profile.begin(4.0,"matrix_"+str(iteration)+("_open" if opened else "_closed"))
			await get_tree().create_timer(4.2).timeout
			pair["open" if opened else "closed"]=main.profile.report()
		report.repetitions.append(pair)
	main.get_node("BuildIntentsDiagnostics").combat_view()
	main.matrix.close()
	# Warm node/font/layout caches before measuring bounded cycles.
	main.open_own_matrix();await get_tree().process_frame;main.matrix.close();await get_tree().process_frame
	for iteration in 20:
		var start_usec:=Time.get_ticks_usec();main.open_own_matrix()
		var open_usec:=Time.get_ticks_usec()-start_usec
		await get_tree().process_frame;await get_tree().process_frame
		main.matrix.rotate(1);main.matrix.close()
		await get_tree().process_frame;await get_tree().process_frame
		report.cycles.append({"index":iteration,"open_cpu_usec":open_usec,"monitors":main.profile.monitors()})
	report.running=false
	var file:=FileAccess.open("res://tests/evidence/combat_matrix_runtime_performance.json",FileAccess.WRITE)
	if file!=null: file.store_string(JSON.stringify(report,"\t"))
	main.build_intents_diagnostics("finish")
