extends Control
signal closed
signal applied
signal main_selected
const Palette = preload("res://ui/demo_theme.gd")
var session: RefCounted
var draft: Dictionary = {}
var owned_id := ""
var collection_mode := false
var section := "skills"
var selected := 0
var heading: Label
var subtitle: Label
var body: BoxContainer
var equipment: VBoxContainer
var context: VBoxContainer
var message: Label
var apply_button: Button
var row_buttons: Array[Button] = []

func text(value: String, size := 16, color := Palette.INK) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func choice(value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 40
	button.pressed.connect(callback)
	return button

func _ready() -> void:
	name = "BuildEditor"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var veil := ColorRect.new()
	veil.color = Color(0.04,0.08,0.06,0.98)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,48)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,28)
	add_child(margin)
	var layout := VBoxContainer.new()
	margin.add_child(layout)
	var header := HBoxContainer.new()
	layout.add_child(header)
	heading = text("",26,Palette.GOLD)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	header.add_child(choice("Volver  [Esc]",close))
	subtitle = text("",14,Palette.MUTED)
	layout.add_child(subtitle)
	var tabs := HBoxContainer.new()
	layout.add_child(tabs)
	tabs.add_child(choice("Habilidades",func(): section="skills"; selected=0; collection_mode=false; render()))
	tabs.add_child(choice("Modificadores",func(): section="mods"; selected=0; collection_mode=false; render()))
	tabs.add_child(choice("Colección",func(): collection_mode=true; render()))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	body = BoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	equipment = VBoxContainer.new()
	equipment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(equipment)
	context = VBoxContainer.new()
	context.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(context)
	message = text("",14,Palette.TEAL)
	layout.add_child(message)
	var footer := HBoxContainer.new()
	layout.add_child(footer)
	var hint := text("Flechas / Tab · elegir     Enter · seleccionar",13,Palette.MUTED)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(hint)
	apply_button = choice("Aplicar cambios",apply)
	footer.add_child(apply_button)
	resized.connect(reflow)
	hide()

func reflow() -> void:
	if body != null: body.vertical = size.x < 900

func open(id: String, as_collection := false) -> void:
	owned_id = id
	draft = session.owned(id).build.duplicate(true)
	collection_mode = as_collection
	section = "skills"
	selected = 0
	show()
	render()
	if not row_buttons.is_empty(): row_buttons[0].grab_focus()

func close() -> void:
	hide()
	draft.clear()
	closed.emit()

func clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func render() -> void:
	var focus := get_viewport().gui_get_focus_owner()
	var focus_text: String = focus.text if focus is Button else ""
	clear(equipment)
	clear(context)
	row_buttons.clear()
	var beast: Dictionary = session.owned(owned_id)
	if beast.is_empty(): return
	heading.text = "Colección" if collection_mode else beast.name + " / build"
	subtitle.text = "Elegir principal · una bestia activa" if collection_mode else "Exploración pausada · " + ("Vista previa" if draft!=beast.build else "Configuración equipada")
	if collection_mode:
		for item in session.collection:
			var id: String = item.id
			var b := choice(item.name + (" · Principal" if id==session.principal_id else "")+" · %d PV"%item.hp,func(): owned_id=id; draft=session.owned(id).build.duplicate(true); collection_mode=false; render())
			equipment.add_child(b)
			row_buttons.append(b)
		context.add_child(text("Selecciona una bestia para revisar su configuración",20))
		message.text = "Las copias conservan su propia vida y habilidades."
		apply_button.hide()
		return
	apply_button.show()
	if owned_id != session.principal_id:
		equipment.add_child(choice("Elegir como principal",func():
			var result: Dictionary = session.select_principal(owned_id)
			if result.ok: main_selected.emit(); render()
			else: message.text=result.error))
	if section == "skills":
		equipment.add_child(text("Habilidades equipadas",19))
		for fixed in session.catalog.beast(beast.definition_id).fixed:
			equipment.add_child(text(session.catalog.skill(fixed).name+" · Fija",16,Palette.MUTED))
		for index in 2:
			var slot := index
			var button := choice(("› " if selected==index else "")+session.catalog.skill(draft.modular[index]).name,func(): selected=slot; render())
			equipment.add_child(button)
			row_buttons.append(button)
		context.add_child(text("Reemplazar modular %d"%(selected+1),19,Palette.GOLD))
		if session.library.is_empty(): context.add_child(text("Obtén una copia para desbloquear sus habilidades."))
		for id in session.library:
			var skill_id: String = id
			var skill: Dictionary = session.catalog.skill(id)
			var button := choice(skill.name,func(): draft.modular[selected]=skill_id; render())
			button.tooltip_text = "%d daño · alcance %.0f · reutilización %d"%[skill.damage,skill.range,skill.cooldown]
			if skill.get("status","")=="dot": button.tooltip_text += " · Residuo: 4 daño cada 4 s durante 12 s"
			if skill.get("status","")=="slow": button.tooltip_text += " · Ralentización: −25 % ATB durante 8 s"
			button.disabled = id in draft.modular and id!=draft.modular[selected]
			if button.disabled: button.text += " · Ya equipada"
			context.add_child(button)
	else:
		equipment.add_child(text("Normales · %d / 8"%draft.normal.filter(func(id):return id!="").size(),19))
		for index in 8:
			var slot := index
			var id: String = draft.normal[index]
			var button := choice(("› " if selected==index else "")+str(index+1)+"  "+("Vacía" if id=="" else "Alcance +30 %"),func(): selected=slot; render())
			equipment.add_child(button)
			row_buttons.append(button)
		equipment.add_child(text("Especiales · 0 / 2",14,Palette.MUTED))
		context.add_child(text("Equipar en ranura %d"%(selected+1),19,Palette.GOLD))
		context.add_child(choice("Retirar modificador",func():draft.normal[selected]="";render()))
		for id in session.inventory:
			var instance: String = id
			var button := choice("Alcance +30 %",func():draft.normal[selected]=instance;render())
			var occupied: bool = instance in draft.normal and draft.normal[selected]!=instance
			for other in session.collection:
				occupied = occupied or (other.id!=owned_id and instance in other.build.normal)
			button.disabled = occupied
			if occupied: button.text += " · Equipada"
			context.add_child(button)
		context.add_child(text("Afecta a todos los ataques compatibles de esta bestia.",14,Palette.MUTED))
	context.add_child(text("Comparación de alcance",16,Palette.GOLD))
	var preview: Dictionary = session.preview_build(owned_id,draft)
	for row in preview.changes:
		context.add_child(text(row.name+": "+("Objetivo propio · sin cambio" if row.base==0 else "%.0f → %.0f"%[row.base,row.result]),14))
	var validation: Dictionary = session.validate_build(owned_id,draft)
	apply_button.disabled = not validation.ok or draft==beast.build
	message.text = " · ".join(validation.errors) if not validation.ok else ("Sin cambios" if draft==beast.build else "Vista previa · Aplicar actualiza la build")
	reflow()
	for node in find_children("*", "Button", true, false):
		if node.text == focus_text and not node.disabled:
			node.call_deferred("grab_focus")
			break

func apply() -> void:
	var result: Dictionary = session.apply_build(owned_id,draft)
	if result.ok:
		applied.emit()
		render()
		message.text = "Configuración aplicada"
	else: message.text=" · ".join(result.errors)

func _input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
		var focus := get_viewport().gui_get_focus_owner()
		if focus != null:
			var next := focus.find_prev_valid_focus() if event.keycode in [KEY_UP, KEY_LEFT] else focus.find_next_valid_focus()
			if next != null: next.grab_focus()
		get_viewport().set_input_as_handled()
	if visible and event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
