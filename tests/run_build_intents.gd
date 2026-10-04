extends SceneTree
func _initialize() -> void:
	var report: Dictionary = preload("res://tests/build_intents.gd").new().run()
	print(JSON.stringify(report))
	var file := FileAccess.open("res://tests/evidence/build_intents_checks.json",FileAccess.WRITE)
	if file!=null: file.store_string(JSON.stringify(report,"\t"))
	quit(0 if report.passed else 1)
