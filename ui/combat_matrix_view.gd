extends VBoxContainer
var controller: RefCounted
var combat: Node
var title: Label
var status: Label
var rings: Control
var choices: Array[Button]=[]
var compact := false
var content: BoxContainer
var last_focus: Control
var rotations: Array[Button]=[]
var clock_bucket := -1
var note: Label

func _ready() -> void:
	name="Matrix"
	add_theme_constant_override("separation",4)
	var heading:=HBoxContainer.new();heading.add_theme_constant_override("separation",4);add_child(heading)
	title=Label.new();title.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size",14);title.clip_text=true;heading.add_child(title)
	var close:=Button.new();close.name="CloseMatrix";close.text="Cerrar [Esc]";heading.add_child(close);close.pressed.connect(controller.close)
	compact_button(close)
	content=BoxContainer.new();content.vertical=true;content.size_flags_vertical=Control.SIZE_EXPAND_FILL;add_child(content)
	rings=preload("res://ui/matrix_rings.gd").new();rings.name="Rings";rings.size_flags_vertical=Control.SIZE_EXPAND_FILL;rings.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_child(rings)
	var info:=VBoxContainer.new();info.name="Info";info.add_theme_constant_override("separation",4);info.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_child(info)
	note=Label.new();note.text="ANILLOS · diagnóstico";note.add_theme_font_size_override("font_size",11);info.add_child(note)
	rings.selected.connect(controller.select_ring)
	rings.focus_entered.connect(func():last_focus=rings)
	var row:=HBoxContainer.new();row.add_theme_constant_override("separation",4);row.alignment=BoxContainer.ALIGNMENT_CENTER;info.add_child(row)
	for index in 3:
		var button:=Button.new();button.name="Ring"+str(index);button.text=str(index+1);button.toggle_mode=true;row.add_child(button);choices.append(button)
		compact_button(button)
		button.pressed.connect(func():controller.select_ring(index))
		button.focus_entered.connect(func():last_focus=button)
	for direction in [-1,1]:
		var button:=Button.new();button.name="Left" if direction<0 else "Right";button.text="← Girar" if direction<0 else "Girar →";button.tooltip_text="Girar un paso";row.add_child(button)
		compact_button(button)
		button.pressed.connect(func():controller.rotate(direction))
		rotations.append(button)
		button.focus_entered.connect(func():last_focus=button)
	status=Label.new();status.add_theme_font_size_override("font_size",12);status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;info.add_child(status)
	var help:=Label.new();help.text="↑↓ anillo · ←→ giro\nTab navegar";help.add_theme_font_size_override("font_size",11);info.add_child(help)
	controller.changed.connect(update_view)
	combat.rupture_changed.connect(func(_id):update_view())
	update_view()

func compact_button(button: Button) -> void:
	button.add_theme_font_size_override("font_size",13)
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style: StyleBox=get_theme_stylebox(state,"Button").duplicate();style.content_margin_top=4;style.content_margin_bottom=4;button.add_theme_stylebox_override(state,style)

func set_compact(value: bool) -> void:
	compact=value
	content.vertical=not value
	rings.custom_minimum_size=Vector2(180,120) if value else Vector2(140,120)

func update_view() -> void:
	visible=controller.owner_id!=""
	if not visible: return
	var actor: Dictionary=combat.actor_by_id(controller.owner_id)
	title.text=("Propia · " if actor.get("is_principal",false) else "Enemiga · ")+str(actor.get("name",""))
	title.tooltip_text=title.text
	var state: Dictionary=controller.current()
	rings.state=state;rings.queue_redraw()
	for index in 3: choices[index].set_pressed_no_signal(state.selected==index)
	for button in rotations: button.disabled=state.resolved
	var count:=0
	for step in state.positions:
		if step==0: count+=1
	status.text="Matriz alineada — prueba sin efecto de combate" if state.resolved else "%d/3 alineados · destino: marcas superiores"%count
	var defense: String=combat.defense_status(controller.owner_id)
	note.text="ANILLOS · ruptura de defensa" if defense!="" else "ANILLOS · diagnóstico"
	if defense!="":
		status.text=defense+("\n%d/3 alineados"%count if not state.resolved else "")
		status.tooltip_text="Rompe la mitigación durante 12 s; conserva Protección. Una ruptura por encuentro."
		return
	status.tooltip_text=status.text

func update_clock() -> void:
	if not visible: return
	var bucket:=int(combat.combat_clock)
	if bucket!=clock_bucket: clock_bucket=bucket;update_view()
