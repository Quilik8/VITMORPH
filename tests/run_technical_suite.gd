extends SceneTree
func _initialize() -> void:
	var results := {}
	var passed := true
	for name in ["demo_rules","combat_demo","copy_demo","save_demo","demo_journey","demo_edges","assembly_checks","build_intents"]:
		var suite: RefCounted=load("res://tests/"+name+".gd").new()
		var report: Dictionary=suite.run()
		results[name]=report
		passed=passed and report.passed
		print(name+": "+str(report.count)+" checks; failures: "+JSON.stringify(report.get("failures",[])))
	var file := FileAccess.open("res://tests/evidence/build_intents_regression.json",FileAccess.WRITE)
	if file!=null: file.store_string(JSON.stringify({"passed":passed,"suites":results},"\t"))
	quit(0 if passed else 1)
