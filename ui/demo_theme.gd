extends RefCounted
const INK := Color("eee5d3")
const MUTED := Color("aaa3a0")
const GOLD := Color("e0ad72")
const TEAL := Color("a1bbd0")
const ASSEMBLY_BACKGROUND := Color("17171d")
const SURFACE := Color("25242b")
const LINE := Color("615552")
const WORLD_BACKGROUND := Color("1c1c24")

static func tile(accent: Color, fill: Color) -> StyleBoxFlat:
	var box:=StyleBoxFlat.new()
	box.bg_color=fill;box.border_color=accent
	box.set_border_width_all(1);box.set_corner_radius_all(6)
	box.set_content_margin_all(10)
	return box

static func underline(color: Color, fill: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = color
	style.border_width_bottom = 2
	style.set_content_margin_all(8)
	return style

static func make() -> Theme:
	var value := Theme.new()
	value.default_font_size = 16
	value.set_color("font_color","Label",INK)
	value.set_color("font_color","Button",INK)
	value.set_color("font_color","OptionButton",INK)
	value.set_color("font_disabled_color","Button",MUTED)
	var colors := {"normal":LINE,"hover":GOLD,"pressed":GOLD,"disabled":Color("413b40"),"focus":INK}
	for state in colors:
		var box := underline(colors[state],SURFACE if state=="hover" else Color.TRANSPARENT)
		value.set_stylebox(state,"Button",box)
		value.set_stylebox(state,"OptionButton",box)
	value.set_constant("separation","VBoxContainer",12)
	value.set_constant("separation","HBoxContainer",18)
	return value
