extends Node
## Diagnóstico optativo de CPU; inactivo fuera de una captura solicitada por MCP.
var active := false
var label := ""
var started_usec := 0
var duration_usec := 0
var frames: Array[float] = []
var scopes: Dictionary = {}
var elapsed_seconds := 0.0
const SAMPLE_LIMIT := 8192
var wall_frames: Array[float] = []
var monitor_samples: Array[Dictionary] = []
var monitor_elapsed := 0.0
var previous_frame_usec := 0
var frame_count := 0
var over_16_67 := 0
var over_33_33 := 0
var over_50 := 0

func _ready() -> void:
	process_priority = 100
	set_process(false)

func begin(seconds: float = 4.0, capture_label: String = "") -> void:
	label = capture_label
	frames.clear()
	scopes.clear()
	wall_frames.clear()
	monitor_samples.clear()
	monitor_elapsed = 0.0
	previous_frame_usec = 0
	frame_count = 0
	over_16_67 = 0
	over_33_33 = 0
	over_50 = 0
	elapsed_seconds = 0.0
	duration_usec = int(clampf(seconds, 1.0, 30.0) * 1000000.0)
	started_usec = Time.get_ticks_usec()
	active = true
	monitor_samples.append(monitors())
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
	if row.samples.size() < SAMPLE_LIMIT:
		row.samples.append(usec)

func _process(delta: float) -> void:
	var now := Time.get_ticks_usec()
	frame_count += 1
	if frames.size() < SAMPLE_LIMIT:
		frames.append(delta * 1000.0)
	if previous_frame_usec != 0:
		var wall_ms := (now - previous_frame_usec) / 1000.0
		if wall_frames.size() < SAMPLE_LIMIT:
			wall_frames.append(wall_ms)
		over_16_67 += int(wall_ms > 16.67)
		over_33_33 += int(wall_ms > 33.33)
		over_50 += int(wall_ms > 50.0)
	previous_frame_usec = now
	elapsed_seconds = (now - started_usec) / 1000000.0
	monitor_elapsed += delta
	if monitor_elapsed >= 0.25:
		monitor_samples.append(monitors())
		monitor_elapsed = 0.0
	if now - started_usec >= duration_usec:
		active = false
		set_process(false)
		monitor_samples.append(monitors())

func summarize(values: Array) -> Dictionary:
	if values.is_empty():
		return {}
	var sorted := values.duplicate()
	sorted.sort()
	var total := 0.0
	for value in sorted:
		total += value
	return {"mean": total / sorted.size(), "p50": sorted[(sorted.size()-1)/2], "p95": sorted[ceili(sorted.size()*0.95)-1], "p99": sorted[ceili(sorted.size()*0.99)-1], "max": sorted[-1]}

func monitors() -> Dictionary:
	return {"engine_memory_bytes": int(Performance.get_monitor(Performance.MEMORY_STATIC)), "texture_bytes": int(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)), "render_buffer_bytes": int(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED)), "video_memory_bytes": int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)), "nodes": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)), "orphan_nodes": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)), "resources": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)), "objects": int(Performance.get_monitor(Performance.OBJECT_COUNT)), "draw_calls": int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)), "primitives": int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))}

func monitor_summary() -> Dictionary:
	var result := {}
	if monitor_samples.is_empty():
		return result
	for metric in monitor_samples[0]:
		var values := []
		for sample in monitor_samples:
			values.append(sample[metric])
		result[metric] = {"start": values[0], "end": values[-1], "delta": values[-1] - values[0], "peak_sampled": values.max(), "min_sampled": values.min()}
	return result

func report() -> Dictionary:
	var rows := {}
	for scope in scopes:
		var row: Dictionary = scopes[scope]
		rows[scope] = {"calls": row.calls, "mean_usec": float(row.total_usec)/row.calls, "max_usec": row.max_usec, "sample_usec": summarize(row.samples)}
	return {"label": label, "active": active, "wall_seconds": elapsed_seconds, "frames": frame_count, "average_fps": frame_count / elapsed_seconds if elapsed_seconds > 0.0 else 0.0, "frame_delta_ms": summarize(frames), "wall_frame_ms": summarize(wall_frames), "hitches": {"over_16_67_ms": over_16_67, "over_33_33_ms": over_33_33, "over_50_ms": over_50}, "monitors": monitor_summary(), "monitor_sample_count": monitor_samples.size(), "scopes": rows, "fps_monitor": Performance.get_monitor(Performance.TIME_FPS), "frame_process_ms_monitor": Performance.get_monitor(Performance.TIME_PROCESS)*1000.0, "draw_calls_monitor": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "limits": "Memory is engine allocations, not OS working set; sampled peaks at 0.25s are not exact peaks. Some monitors can lag or be unavailable. Zero is not proof of no usage. Scopes overlap; no direct GPU timing. Samples capped at 8192; counters include all frames."}
