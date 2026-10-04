extends Button
var editor: Control
var payload: Dictionary={}
var target_kind := ""
var target_index := -1

func _ready() -> void:
	if target_kind in ["normal","special"]:
		for state in ["normal","hover","pressed","focus","disabled"]: add_theme_stylebox_override(state,StyleBoxEmpty.new())
		focus_entered.connect(queue_redraw);focus_exited.connect(queue_redraw);mouse_entered.connect(queue_redraw);mouse_exited.connect(queue_redraw)

func _draw() -> void:
	if target_kind not in ["normal","special"]: return
	var center:=size*.5
	var color:=Color("5c6b59") if disabled else Color("a5aa9b")
	if not payload.is_empty(): color=Color("d4bb79")
	if has_focus(): color=Color("eee5d3")
	draw_arc(center,19,0,TAU,32,color,2 if has_focus() else 1,true)

func _get_drag_data(_at: Vector2) -> Variant:
	if disabled or payload.is_empty(): return null
	editor.drag_active=true
	editor.native_drag_count+=1
	editor.highlight_targets(payload)
	var preview:=HBoxContainer.new()
	if icon!=null:
		var image:=TextureRect.new();image.texture=icon;image.custom_minimum_size=Vector2(36,36);image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;preview.add_child(image)
	var label:=Label.new();label.text=text;label.add_theme_color_override("font_color",Color("d4bb79"));preview.add_child(label)
	set_drag_preview(preview)
	return payload.duplicate()

func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	if disabled or target_kind.is_empty() or not data is Dictionary: return false
	var result: Dictionary=editor.controller.candidate(data,target_kind,target_index)
	if not result.ok: editor.message.text=result.error
	return result.ok

func _drop_data(_at: Vector2, data: Variant) -> void:
	editor.receive_drop(data,target_kind,target_index)

func _notification(what: int) -> void:
	if what==NOTIFICATION_DRAG_END and editor!=null:
		editor.drag_active=false
		editor.restore_highlights()
