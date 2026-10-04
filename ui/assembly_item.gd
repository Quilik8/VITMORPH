extends Button
const Palette=preload("res://ui/demo_theme.gd")
var glyph := ""
var piece_icon: Texture2D
var editor: Control
var payload: Dictionary={}
var target_kind := ""
var target_index := -1

func _ready() -> void:
	if target_kind in ["normal","special"]:
		for state in ["normal","hover","pressed","focus","disabled"]: add_theme_stylebox_override(state,StyleBoxEmpty.new())
		focus_entered.connect(queue_redraw);focus_exited.connect(queue_redraw);mouse_entered.connect(queue_redraw);mouse_exited.connect(queue_redraw)

func _draw() -> void:
	if target_kind not in ["normal","special"]:
		if glyph.is_empty(): return
		var at:=Vector2(size.x*.5,28)
		if piece_icon!=null:
			var dimensions:=piece_icon.get_size()
			dimensions*=minf(40.0/dimensions.x,40.0/dimensions.y)
			draw_texture_rect(piece_icon,Rect2(at-dimensions*.5,dimensions),false)
		else:
			draw_polyline(PackedVector2Array([at+Vector2(0,-16),at+Vector2(18,0),at+Vector2(0,16),at+Vector2(-18,0),at+Vector2(0,-16)]),Palette.LINE,1.0,true)
			draw_string(ThemeDB.fallback_font,at+Vector2(-6,6),glyph,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Palette.GOLD)
		return
	var center:=size*.5
	var color:=Palette.LINE if disabled else Palette.MUTED
	if not payload.is_empty():
		color=Palette.GOLD
	if has_focus(): color=Palette.INK
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
