extends RefCounted
const INK := Color("eee5d3")
const MUTED := Color("a5aa9b")
const GOLD := Color("d4bb79")
const TEAL := Color("86bbb0")

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
	var colors := {"normal":Color("566755"),"hover":GOLD,"pressed":GOLD,"disabled":Color("354238"),"focus":INK}
	for state in colors:
		var box := underline(colors[state],Color("263a2e") if state=="hover" else Color.TRANSPARENT)
		value.set_stylebox(state,"Button",box)
		value.set_stylebox(state,"OptionButton",box)
	value.set_constant("separation","VBoxContainer",12)
	value.set_constant("separation","HBoxContainer",18)
	return value
