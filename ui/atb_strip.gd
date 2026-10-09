extends Control
var profile: Node
## Franja contextual de tiempo; no representa rondas fijas.
var combat: Node
var cached_forecast: Array[Dictionary] = []
var refresh_elapsed := 1.0
var dirty := true
var forecast_updates := 0
const INK := Color("eee5d3")
const MUTED := Color("aaa3a0")
const GOLD := Color("e0ad72")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	combat.state_changed.connect(func(): dirty = true)

func _process(delta: float) -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	_process_body(delta)
	if stamp != 0:
		profile.record("ui/atb_strip.gd:_process", Time.get_ticks_usec() - stamp)

func _process_body(delta: float) -> void:
	if visible and combat != null:
		refresh_elapsed += delta
		if dirty or refresh_elapsed >= 0.2:
			cached_forecast = combat.forecast(7)
			forecast_updates += 1
			refresh_elapsed = 0.0
			dirty = false
			queue_redraw()

func _draw() -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	_draw_body()
	if stamp != 0:
		profile.record("ui/atb_strip.gd:_draw", Time.get_ticks_usec() - stamp)

func _draw_body() -> void:
	if combat == null:
		return
	var rows: Array[Dictionary] = cached_forecast
	if rows.is_empty():
		return
	var width := minf(154.0, size.x / rows.size())
	var left := (size.x - width * rows.size()) * 0.5
	var font := ThemeDB.fallback_font
	for index in rows.size():
		var row: Dictionary = rows[index]
		var x := left + index * width + 10.0
		var color := GOLD if row.id == "main" else Color("bc8875")
		var caption: String = "Ahora" if row.current else "en %d s" % ceili(row.time)
		var actor_name: String = row.name.replace("Enemigo ", "En. ")
		if width<130.0: actor_name=actor_name.replace("Bestia de ","").replace("Principal inicial","Principal")
		draw_string(font, Vector2(x, 24), actor_name, HORIZONTAL_ALIGNMENT_LEFT, width - 30, 15, color)
		draw_string(font, Vector2(x, 45), caption, HORIZONTAL_ALIGNMENT_LEFT, width - 30, 12, MUTED)
		if row.current:
			draw_line(Vector2(x, 52), Vector2(x + width - 30, 52), INK, 2)
		if index < rows.size() - 1:
			draw_string(font, Vector2(x + width - 24, 24), "→", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, MUTED)
