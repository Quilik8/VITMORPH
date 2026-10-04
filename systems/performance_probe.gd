extends Node
## Diagnóstico optativo de CPU; inactivo fuera de una captura solicitada por MCP.
var active := false
var label := ""
var started_usec := 0
var duration_usec := 0
var frames: Array[float] = []
var scopes: Dictionary = {}
var elapsed_seconds := 0.0

func _ready() -> void:
	process_priority = 100
	set_process(false)

func begin(seconds: float = 4.0, capture_label: String = "") -> void:
	label = capture_label
	frames.clear()
	scopes.clear()
	elapsed_seconds = 0.0
	duration_usec = int(clampf(seconds, 1.0, 30.0) * 1000000.0)
	started_usec = Time.get_ticks_usec()
	active = true
	set_process(true)

func record(scope: String, usec: int) -> void:
	if not active:
		return
	if not scopes.has(scope):
		scopes[scope] = {"calls": 0, "total_usec": 0, "max_usec": 0, "samples": []}
	var row: Dictionary = scopes[scope]
	row.calls += 1
	row.total_usec += usec
	row.max_usec = maxi(row.max_usec, usec)
	if row.samples.size() < 8192:
		row.samples.append(usec)

func _process(delta: float) -> void:
	frames.append(delta * 1000.0)
	elapsed_seconds = (Time.get_ticks_usec() - started_usec) / 1000000.0
	if Time.get_ticks_usec() - started_usec >= duration_usec:
		active = false
		set_process(false)

func summarize(values: Array) -> Dictionary:
	if values.is_empty():
		return {}
	var sorted := values.duplicate()
	sorted.sort()
	var total := 0.0
	for value in sorted:
		total += value
	return {"mean": total / sorted.size(), "p50": sorted[(sorted.size()-1)/2], "p95": sorted[ceili(sorted.size()*0.95)-1], "max": sorted[-1]}

func report() -> Dictionary:
	var rows := {}
	for scope in scopes:
		var row: Dictionary = scopes[scope]
		rows[scope] = {"calls": row.calls, "mean_usec": float(row.total_usec)/row.calls, "max_usec": row.max_usec, "sample_usec": summarize(row.samples)}
	return {"label": label, "active": active, "wall_seconds": elapsed_seconds, "frames": frames.size(), "frame_delta_ms": summarize(frames), "scopes": rows, "fps_monitor": Performance.get_monitor(Performance.TIME_FPS), "frame_process_ms_monitor": Performance.get_monitor(Performance.TIME_PROCESS)*1000.0, "draw_calls_monitor": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
