extends Control
var matrix := preload("res://systems/combat_matrix.gd").new()
var matrix_view: Control
var matrix_button: Button
var battle_region: BoxContainer
var skill_row: GridContainer
var feedback: VBoxContainer
var parry_notice: Label
var parry_remaining := 0.0
var parry_answered := false
var matrix_notice := ""
var narrow_hud := false
var profile: Node
## HUD de intervención: campo primero, detalles contextuales y diagnóstico optativo.
const EngineScript = preload("res://systems/combat_engine.gd")
const Fixture = preload("res://data/combat_fixture.gd")
const AI = preload("res://systems/combat_ai.gd")
const ArenaScript = preload("res://ui/arena_view.gd")
const ATBStrip = preload("res://ui/atb_strip.gd")
const RouteScript = preload("res://systems/world_route.gd")
const INK := Color("eee5d3")
const MUTED := Color("aaa3a0")
const GOLD := Color("e0ad72")
const TEAL := Color("a1bbd0")
var save_service: Node
var save_label: Label
var diagnostic_mode := false
var demo_before_diagnostics: Dictionary = {}
var session := preload("res://systems/demo_session.gd").new()
var editor: Control
var build_button: Button
var collection_button: Button
var combat: Node
var route: Node
var arena: Control
var selection: OptionButton
var start_button: Button
var diagnostic_button: Button
var diagnostic_view: VBoxContainer
var action_label: Label
var result_label: Label
var detail_label: Label
var log_label: Label
var queue_label: Label
var priority_button: Button
var retain_button: Button
var intervention_strip: VBoxContainer
var atb_strip: Control
var exploration_help: Label
var skill_buttons: Array[Button] = []
var copy_targets: OptionButton
var copy_button: Button
var copy_label: Label
var copy_target_ids: Array[String] = []
var copy_notice := ""
var copy_notice_seconds := 0.0
var selected_skill := "basic"
var intention_context_id := ""
var log_lines: Array[String] = []

func _ready() -> void:
	profile = preload("res://systems/performance_probe.gd").new()
	profile.name = "PerformanceProbe"
	add_child(profile)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = make_theme()
	combat = EngineScript.new()
	combat.name = "Combat"
	combat.profile = profile
	add_child(combat)
	route = RouteScript.new()
	route.name = "WorldRoute"
	route.profile = profile
	route.combat = combat
	route.session = session
	add_child(route)
	build_screen()
	arena.intention_focused.connect(func(id):intention_context_id=id;refresh())
	editor = preload("res://ui/build_editor.gd").new()
	editor.session = session
	editor.visuals=arena.visuals
	add_child(editor)
	editor.closed.connect(func():route.menu_paused=false;route.held_keys.clear();build_button.grab_focus())
	editor.applied.connect(on_build_applied)
	editor.main_selected.connect(on_build_applied)
	combat.copy_service.completed.connect(func(actor):session.acquire_actor(actor); refresh())
	combat.copy_service.changed.connect(func():
		if combat.copy_service.message.begins_with("Copia obtenida") or combat.copy_service.message.begins_with("Copia fallida"):
			copy_notice=combat.copy_service.message; copy_notice_seconds=8.0
		refresh())
	combat.action_executed.connect(func(action):
		arena.show_impact(action)
		if combat.actor_by_id(action.actor_id).get("is_principal",false) and not action.skill.is_empty() and action.get("kind","")!="copy": session.record_skill(action.skill.id))
	combat.state_changed.connect(refresh)
	combat.action_chosen.connect(on_action)
	combat.message.connect(add_message)
	combat.damage_applied.connect(arena.flash)
	combat.combat_finished.connect(on_finished)
	route.route_changed.connect(refresh)
	route.travelling_started.connect(arena.reset_feedback)
	save_service=preload("res://systems/save_service.gd").new()
	save_service.name="SaveService"
	add_child(save_service)
	save_service.saved.connect(func(_sequence): save_label.text=save_service.status)
	save_service.failed.connect(func(reason): save_label.text=reason; save_label.tooltip_text=reason)
	route.before_encounter.connect(create_checkpoint)
	route.settled.connect(func():call_deferred("create_checkpoint"))
	get_tree().auto_accept_quit=false
	on_mode_selected(3)
	begin()
	var restored: Dictionary=save_service.restore_checkpoint(validate_snapshot)
	if restored.ok: restore_checkpoint(restored.snapshot)
	elif not restored.found: create_checkpoint()
	save_label.text=save_service.status
	refresh()
	if "--validate-demo" in OS.get_cmdline_user_args(): call_deferred("validate_exported_demo")

func underline(color: Color, fill: Color = Color(0,0,0,0)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = color
	style.border_width_bottom = 2
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

func make_theme() -> Theme:
	return preload("res://ui/demo_theme.gd").make()

func label(text: String, font_size: int = 16, color: Color = INK) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	return node

func button(text: String, callback: Callable, node_name: String) -> Button:
	var node := Button.new()
	node.name = node_name
	node.text = text
	node.custom_minimum_size.y = 30
	node.add_theme_font_size_override("font_size",14)
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style: StyleBox=theme.get_stylebox(state,"Button").duplicate()
		style.content_margin_top=4;style.content_margin_bottom=4
		node.add_theme_stylebox_override(state,style)
	node.pressed.connect(callback)
	return node

func build_screen() -> void:
	var background:=ColorRect.new()
	background.color=Color("1c1c24");background.mouse_filter=Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
	var margins:=MarginContainer.new();margins.name="Layout"
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]: margins.add_theme_constant_override("margin_"+side,12)
	add_child(margins)
	var root:=VBoxContainer.new();root.name="Body";root.add_theme_constant_override("separation",4);margins.add_child(root)
	var header:=HBoxContainer.new();header.name="Header";root.add_child(header)
	var title:=label("VITMORPH",17,GOLD);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(title)
	build_button=button("Build [B]",func():open_build(false),"Build");header.add_child(build_button)
	collection_button=button("Bestias [C]",func():open_build(true),"Collection");header.add_child(collection_button)
	diagnostic_button=button("Pruebas [F3]",toggle_diagnostics,"Diagnostics");header.add_child(diagnostic_button)
	atb_strip=ATBStrip.new();atb_strip.name="ATB";atb_strip.profile=profile;atb_strip.combat=combat
	atb_strip.custom_minimum_size.y=56;root.add_child(atb_strip)
	feedback=VBoxContainer.new();feedback.name="Feedback";feedback.add_theme_constant_override("separation",0);root.add_child(feedback)
	result_label=label("",12,MUTED);result_label.clip_text=true;feedback.add_child(result_label)
	var action_row:=HBoxContainer.new();action_row.add_theme_constant_override("separation",4);feedback.add_child(action_row)
	action_label=label("",16);action_label.clip_text=true;action_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;action_row.add_child(action_label)
	parry_notice=label("",12,GOLD);parry_notice.custom_minimum_size.x=210;parry_notice.clip_text=true;action_row.add_child(parry_notice)
	# Keep notice geometry allocated: visibility changes must not move the puzzle.
	parry_notice.show();parry_notice.text=" "
	battle_region=BoxContainer.new();battle_region.name="BattleRegion";battle_region.size_flags_vertical=Control.SIZE_EXPAND_FILL;root.add_child(battle_region)
	arena=ArenaScript.new();arena.name="Battlefield";arena.profile=profile;arena.combat=combat;arena.route=route
	arena.custom_minimum_size=Vector2(0,140);arena.size_flags_horizontal=Control.SIZE_EXPAND_FILL;arena.size_flags_vertical=Control.SIZE_EXPAND_FILL;battle_region.add_child(arena)
	matrix_view=preload("res://ui/combat_matrix_view.gd").new();matrix_view.controller=matrix;matrix_view.combat=combat;battle_region.add_child(matrix_view)
	exploration_help=label("WASD / flechas · desplazarte",12,MUTED);exploration_help.clip_text=true;root.add_child(exploration_help)
	intervention_strip=VBoxContainer.new();intervention_strip.name="Interventions";intervention_strip.add_theme_constant_override("separation",2);root.add_child(intervention_strip)
	skill_row=GridContainer.new();skill_row.name="Skills";skill_row.columns=4;intervention_strip.add_child(skill_row)
	for index in 4:
		var slot:=index;var skill: Dictionary=Fixture.abilities()[index]
		var item:=button(skill.name,func():select_skill(equipped_skills()[slot].id),skill.id.capitalize())
		item.toggle_mode=true;item.clip_text=true;item.custom_minimum_size=Vector2(0,40);item.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		item.add_theme_font_size_override("font_size",13);skill_row.add_child(item);skill_buttons.append(item)
	var commands:=HBoxContainer.new();commands.name="Commands";intervention_strip.add_child(commands)
	detail_label=label("",12,MUTED);detail_label.clip_text=true;detail_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;commands.add_child(detail_label)
	priority_button=button("Priorizar [P]",func():toggle_command("priority"),"Prioritize");commands.add_child(priority_button)
	retain_button=button("Retener [R]",func():toggle_command("retain"),"Retain");commands.add_child(retain_button)
	var context:=HBoxContainer.new();context.name="TargetContext";intervention_strip.add_child(context)
	copy_targets=OptionButton.new();copy_targets.name="CopyTargets";copy_targets.size_flags_horizontal=Control.SIZE_EXPAND_FILL;copy_targets.clip_text=true
	copy_targets.add_theme_font_size_override("font_size",13)
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style: StyleBox=theme.get_stylebox(state,"OptionButton").duplicate();style.content_margin_top=4;style.content_margin_bottom=4;copy_targets.add_theme_stylebox_override(state,style)
	copy_targets.item_selected.connect(func(_i):refresh());context.add_child(copy_targets)
	matrix_button=button("Matriz · prueba",open_target_matrix,"OpenMatrix");context.add_child(matrix_button)
	copy_button=button("Copiar [X]",copy_selected,"Copy");context.add_child(copy_button)
	copy_label=label("",12,TEAL);copy_label.clip_text=true;intervention_strip.add_child(copy_label)
	save_label=label("",11,MUTED);save_label.clip_text=true;root.add_child(save_label)
	# Tools are a bounded optional surface, not a permanent toolbar.
	var surface:=PanelContainer.new();surface.name="DiagnosticSurface"
	surface.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	surface.offset_left=-370;surface.offset_right=-12;surface.offset_top=54;surface.offset_bottom=450
	var style:=StyleBoxFlat.new();style.bg_color=Color(.09,.09,.12,.97);style.set_content_margin_all(12);surface.add_theme_stylebox_override("panel",style);add_child(surface)
	var scroll:=ScrollContainer.new();scroll.name="Scroll";surface.add_child(scroll)
	diagnostic_view=VBoxContainer.new();diagnostic_view.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(diagnostic_view)
	diagnostic_view.add_child(label("PRUEBAS · F3 cerrar",13,GOLD))
	selection=OptionButton.new();selection.name="Scenario"
	for value in Fixture.SCENARIOS: selection.add_item(value)
	selection.add_item("Recorrido continuo");selection.select(3);selection.item_selected.connect(on_mode_selected);diagnostic_view.add_child(selection)
	start_button=button("Comenzar",begin,"Start");diagnostic_view.add_child(start_button)
	diagnostic_view.add_child(button("Matriz del principal · prueba",open_own_matrix,"OwnMatrix"))
	diagnostic_view.add_child(button("Reiniciar matriz · prueba",matrix.reset,"ResetMatrix"))
	diagnostic_view.add_child(button("Aviso Parry · prueba",show_parry_probe,"ParryProbe"))
	queue_label=label("",12,MUTED);queue_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;diagnostic_view.add_child(queue_label)
	log_label=label("",12);log_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;diagnostic_view.add_child(log_label)
	surface.hide()
	matrix.changed.connect(layout_hud)
	matrix.closed.connect(func():copy_targets.call_deferred("grab_focus"))
	resized.connect(layout_hud)
	call_deferred("layout_hud")

func diagnostic_surface() -> Control:
	return diagnostic_view.get_parent().get_parent()

func layout_hud() -> void:
	if matrix_view==null: return
	narrow_hud=size.x<1000
	result_label.visible=not narrow_hud
	if matrix.owner_id!="" and (size.x<640 or size.y<640):
		matrix_notice="Amplía la ventana para editar la matriz";matrix.close()
	battle_region.vertical=narrow_hud
	matrix_view.set_compact(narrow_hud)
	matrix_view.custom_minimum_size=Vector2(0,220) if narrow_hud else Vector2(320,0)
	matrix_view.size_flags_horizontal=Control.SIZE_EXPAND_FILL if narrow_hud else Control.SIZE_FILL
	matrix_view.size_flags_vertical=Control.SIZE_FILL if narrow_hud else Control.SIZE_EXPAND_FILL
	skill_row.columns=4
	detail_label.visible=not narrow_hud
	copy_label.visible=not narrow_hud and copy_label.text!=""
	if matrix_notice!="": save_label.text=matrix_notice
	var surface:=diagnostic_surface()
	surface.offset_left=-minf(370,size.x-24);surface.offset_bottom=minf(450,size.y-12)
	if arena!=null: arena.queue_redraw()

func open_matrix(actor_id: String) -> bool:
	if size.x<640 or size.y<640:
		matrix_notice="Amplía la ventana para editar la matriz";save_label.text=matrix_notice;return false
	matrix_notice=""
	if save_label.text=="Amplía la ventana para editar la matriz" and save_service!=null: save_label.text=save_service.status
	var accepted: bool=matrix.open(actor_id,combat.actors)
	if accepted:
		diagnostic_surface().hide();matrix_view.rings.call_deferred("grab_focus");route.held_keys.clear()
	return accepted

func open_target_matrix() -> void:
	if copy_targets.selected>=0 and copy_targets.selected<copy_target_ids.size(): open_matrix(copy_target_ids[copy_targets.selected])

func open_own_matrix() -> void:
	var actor: Dictionary=combat.principal_actor()
	if not actor.is_empty(): open_matrix(actor.id)

func show_parry_probe() -> void:
	if not combat.running: return
	parry_remaining=1.0;parry_answered=false
	parry_notice.text="Prueba de aviso de Parry · Espacio"
	parry_notice.tooltip_text="Prueba de aviso de Parry · Espacio · sin efecto mecánico"
	diagnostic_surface().hide()
	if matrix.owner_id!="" and is_instance_valid(matrix_view.last_focus): matrix_view.last_focus.grab_focus()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or not combat.running: return
	if parry_remaining>0 and event.keycode==KEY_SPACE:
		parry_answered=true;parry_notice.text="Respuesta registrada · sin efecto de combate";get_viewport().set_input_as_handled();return
	if matrix.owner_id=="": return
	var focused: Control=get_viewport().gui_get_focus_owner()
	if event.keycode in [KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT] and focused!=null and not matrix_view.is_ancestor_of(focused): return
	match event.keycode:
		KEY_ESCAPE: matrix.close()
		KEY_UP: matrix.select_ring(posmod(int(matrix.current().selected)-1,3))
		KEY_DOWN: matrix.select_ring(posmod(int(matrix.current().selected)+1,3))
		KEY_LEFT: matrix.rotate(-1)
		KEY_RIGHT: matrix.rotate(1)
		_: return
	get_viewport().set_input_as_handled()

func equipped_skills() -> Array[Dictionary]:
	var actor: Dictionary = combat.actor_by_id("main") if combat.running else (route.actors[0] if route.visible_world else {})
	if not actor.is_empty():
		return actor.abilities
	return Fixture.abilities()

func select_skill(id: String) -> void:
	intention_context_id=""
	selected_skill = id
	refresh()

func selected_data() -> Dictionary:
	for skill in equipped_skills():
		if skill.id == selected_skill:
			return skill
	return equipped_skills()[0]

func begin() -> void:
	log_lines.clear()
	arena.reset_feedback()
	if selection.selected == 3:
		if route.is_active(): route.rest()
		else: route.start()
	else:
		route.visible_world = false
		combat.start(selection.selected)
	refresh()

func on_mode_selected(index: int) -> void:
	if combat.running or route.state == "aftermath":
		return
	if index!=3 and route.visible_world and route.state=="travelling":
		session.sync_actor(route.actors[0],combat.priority,combat.retained)
		demo_before_diagnostics={"session":session.export_data(),"world":route.export_data()}
	diagnostic_mode=index!=3
	route.visible_world = index == 3
	if index==3 and not demo_before_diagnostics.is_empty():
		restore_checkpoint(demo_before_diagnostics)
		demo_before_diagnostics.clear()
		return
	if route.visible_world:
		route.preview()
	combat.actors.clear()
	combat.pending = {}
	combat.result = ""
	action_label.text = ""
	result_label.text = "Pulsa Recorrer para comenzar" if index == 3 else "Elige un encuentro y comienza"
	refresh()

func toggle_command(kind: String) -> void:
	if not combat.running:
		return
	var current: String = combat.priority if kind == "priority" else combat.retained
	combat.command(kind, "" if current == selected_skill else selected_skill)

func toggle_diagnostics() -> void:
	var surface: Control = diagnostic_surface()
	surface.visible = not surface.visible
	diagnostic_button.text = "Cerrar [F3]" if surface.visible else "Pruebas [F3]"
	refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: int = event.keycode
	if not combat.running and key==KEY_E and route.at_refuge() and not editor.visible:
		route.rest(); get_viewport().set_input_as_handled(); return
	if not combat.running and key in [KEY_B,KEY_C]:
		open_build(key==KEY_C)
		get_viewport().set_input_as_handled()
		return
	if not combat.running and key != KEY_F3:
		return
	if key >= KEY_1 and key <= KEY_4:
		select_skill(equipped_skills()[key - KEY_1].id)
	elif key == KEY_P:
		toggle_command("priority")
	elif key == KEY_R:
		toggle_command("retain")
	elif key == KEY_X:
		copy_selected()
	elif key == KEY_F3:
		toggle_diagnostics()
	else:
		return
	get_viewport().set_input_as_handled()

func on_action(action: Dictionary) -> void:
	arena.show_action(action)
	var actor: Dictionary = combat.actor_by_id(action.actor_id)
	action_label.text = "%s · %s" % [actor.name, "Esperar" if action.skill.is_empty() else action.skill.name]

func on_finished(outcome: String) -> void:
	matrix.sync(false,[])
	parry_remaining=0;parry_notice.text=" "
	action_label.text = outcome
	if route.visible_world:
		if outcome=="Derrota":
			copy_notice="Derrota · regreso al refugio · "+(combat.copy_service.message if combat.copy_service.message.begins_with("Copia fallida") else "colección conservada")
			copy_notice_seconds=8.0
		result_label.text = "Victoria · recuperando el movimiento" if outcome == "Victoria" else "La bestia ha caído"
		if copy_notice_seconds>0: result_label.text=copy_notice
	else:
		result_label.text = "Encuentro terminado · puedes repetir o cambiar de escenario"

func add_message(value: String) -> void:
	log_lines.push_front(value)
	if log_lines.size() > 5:
		log_lines.resize(5)
	log_label.text = "\n".join(log_lines)

func refresh() -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	refresh_body()
	if stamp != 0:
		profile.record("ui/combat_screen.gd:refresh", Time.get_ticks_usec() - stamp)

func refresh_body() -> void:
	matrix.sync(combat.running,combat.actors)
	var active: bool = combat.running or route.state == "aftermath"
	session.combat_locked = active
	build_button.disabled = active or not route.visible_world
	collection_button.disabled = build_button.disabled
	atb_strip.visible = combat.running
	intervention_strip.visible = combat.running
	exploration_help.visible = route.visible_world and not combat.running
	if not combat.running:
		parry_remaining=0;parry_notice.text=" "
	diagnostic_button.text="Cerrar [F3]" if diagnostic_surface().visible else "Pruebas [F3]"
	diagnostic_button.visible = true
	selection.disabled = active
	start_button.disabled = active
	if route.visible_world:
		start_button.text = "Explorar" if route.state == "ready" else "Descansar [E]"
		start_button.disabled=active or (route.state!="ready" and not route.at_refuge()) or editor.visible
	else:
		start_button.text = "Repetir" if not combat.actors.is_empty() else "Comenzar"
	if combat.running:
		result_label.text = ""
		if combat.pending.is_empty():
			action_label.text = ""
			arena.reset_feedback()
	if diagnostic_surface().visible:
		queue_label.text = "Orden ATB: " + " → ".join(combat.upcoming(4))
	if route.visible_world and not combat.running:
		queue_label.text = "Recorrido: %d / %d encuentros superados" % [route.cleared,route.zones.size()]
		if route.state == "travelling":
			action_label.text = ""
		elif route.state == "complete":
			action_label.text = "Recorrido completado"
		elif route.state == "failed":
			action_label.text = "Recorrido detenido"
	refresh_copy()
	layout_hud()
	var skills := equipped_skills()
	if selected_skill not in skills.map(func(skill):return skill.id): selected_skill=skills[0].id
	for index in skill_buttons.size():
		var skill: Dictionary = skills[index]
		var marks: Array[String] = []
		if combat.priority == skill.id:
			marks.append("Prioridad")
		if combat.retained == skill.id:
			marks.append("Retenida")
		var item := skill_buttons[index]
		item.text = "%d  %s" % [index + 1, skill.name]
		if not marks.is_empty():
			item.text += "\n" + " · ".join(marks)
		item.tooltip_text=skill.name+" · "+(" / ".join(marks) if not marks.is_empty() else "Sin marcas")
		item.set_pressed_no_signal(skill.id == selected_skill)
		item.add_theme_color_override("font_color", GOLD if skill.id == selected_skill else INK)
	priority_button.text = "Quitar prioridad  [P]" if combat.priority == selected_skill else "Priorizar  [P]"
	retain_button.text = "Liberar  [R]" if combat.retained == selected_skill else "Retener  [R]"
	priority_button.disabled = not combat.running
	retain_button.disabled = not combat.running
	var selected := selected_data()
	var effect: String = "%d daño" % selected.damage if selected.damage > 0 else "Protege el próximo impacto"
	if selected.get("status","")=="dot": effect += " · residuo cada 4 s"
	if selected.get("status","")=="slow": effect += " · ralentiza ATB"
	var availability := ""
	if combat.running:
		var actor: Dictionary = combat.actor_by_id("main")
		availability = AI.blocked_reason(actor, selected, combat.actors, combat.retained, actor.turns + 1)
		if not combat.resolved and not combat.pending.is_empty() and not combat.pending.skill.is_empty() and combat.pending.actor_id == "main" and combat.pending.skill.id == selected_skill and selected.cooldown > 0 and availability.is_empty():
			availability = "En curso; reutilización después"
	detail_label.text = effect + (" · " + availability if not availability.is_empty() else "")
	detail_label.tooltip_text = "%s · alcance %d · reutilización %d elecciones" % [effect, selected.range, selected.cooldown]
	if not intention_context_id.is_empty():
		var context_text: String=arena.intention_detail(intention_context_id)
		if context_text!="": detail_label.text=arena.intention_brief(intention_context_id);detail_label.tooltip_text=context_text
		else: intention_context_id=""
	arena.queue_redraw()

func _process(delta: float) -> void:
	var stamp: int = Time.get_ticks_usec() if profile != null and profile.active else 0
	_process_body(delta)
	if stamp != 0:
		profile.record("ui/combat_screen.gd:_process", Time.get_ticks_usec() - stamp)

func _process_body(delta: float) -> void:
	if parry_remaining>0:
		parry_remaining=maxf(0,parry_remaining-delta)
		if parry_remaining==0: parry_notice.text=" "
	copy_notice_seconds=maxf(0.0,copy_notice_seconds-delta)
	if combat != null and combat.running:
		if not combat.copy_service.process.is_empty():
			var percent: int = int(combat.copy_service.snapshot(combat.combat_clock).progress*100)
			copy_label.text="Copiando · %d %% · mantener vivo"%percent
		var phase := "Cargando ATB" if combat.pending.is_empty() else "Recuperación"
		if not combat.resolved:
			phase = "Anticipación" if combat.elapsed < combat.resolve_seconds * 0.64 else "Ejecución"
		if result_label.text != phase:
			result_label.text = phase
	elif route != null and route.visible_world:
		if route.state == "travelling":
			result_label.text = copy_notice if copy_notice_seconds>0 else route.confrontation
			exploration_help.text="WASD / flechas · explorar   B · build   C · bestias"+("   E · descansar" if route.at_refuge() else "")
			start_button.disabled=not route.at_refuge() or editor.visible
			if session.objectives.completed: result_label.text="Demo completada · el mundo sigue abierto"
		elif route.state == "complete":
			result_label.text = "Tres encuentros superados · Reiniciar para repetir"
		elif route.state == "failed":
			result_label.text = "La bestia ha caído · pulsa Reiniciar para repetir"

func snapshot() -> Dictionary:
	var report: Dictionary = combat.snapshot()
	report["matrix"]=matrix.snapshot()
	report["session"] = session.export_data()
	report["save"] = {"status":save_service.status,"confirmed":save_service.confirmed,"requested":save_service.sequence,"last_write_usec":save_service.last_write_usec,"diagnostic_profile":diagnostic_mode}
	report["editor"] = {"visible":editor.visible,"exploration_paused":route.menu_paused,"draft":editor.draft.duplicate(true)}
	report["visual_assets"] = {"registered":arena.visuals.entries.size(),"issues":arena.visuals.issues.duplicate()}
	report["world"] = route.snapshot()
	report["forecast"] = combat.forecast(7)
	report["performance"] = {"fps": Performance.get_monitor(Performance.TIME_FPS), "process_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, "forecast_updates": atb_strip.forecast_updates}
	report["combat_hud_visible"] = intervention_strip.visible
	report["exploration_help_visible"] = exploration_help.visible
	report["scene_instance"] = get_tree().current_scene.get_instance_id()
	report["combat_instance"] = combat.get_instance_id()
	report["presentation_cache"] = {"active_popups": arena.popups.size(), "free_popups": arena.popup_pool.size(), "peak_popups": arena.popup_peak, "text_widths": arena.text_widths.size(), "text_width_limit": 256, "free_popup_limit": 8}
	return report

func run_rule_checks() -> Dictionary:
	return {"passed": false, "status": "HISTORICAL_SUITE", "reason": "La suite anterior asume iniciativa virtual; requiere adaptación explícita a ATB antes de ejecutarse."}

func run_demo_checks() -> Dictionary:
	return preload("res://tests/demo_rules.gd").new().run()

func run_combat_demo_checks() -> Dictionary:
	return preload("res://tests/combat_demo.gd").new().run()

func run_copy_demo_checks() -> Dictionary:
	return preload("res://tests/copy_demo.gd").new().run()

func run_save_demo_checks() -> Dictionary:
	return preload("res://tests/save_demo.gd").new().run()

func run_journey_checks() -> Dictionary:
	return preload("res://tests/demo_journey.gd").new().run()

func run_edge_checks() -> Dictionary:
	return preload("res://tests/demo_edges.gd").new().run()

func run_assembly_checks() -> Dictionary:
	return preload("res://tests/assembly_checks.gd").new().run()

func matrix_performance() -> void:
	var previous:=get_node_or_null("MatrixPerformance")
	if previous!=null: previous.free()
	var driver:=preload("res://tests/combat_matrix_runtime.gd").new()
	driver.name="MatrixPerformance";add_child(driver);driver.start(self)

func matrix_ui_validation() -> void:
	if get_node_or_null("BuildIntentsDiagnostics")==null:
		build_intents_diagnostics("combat")
	var previous:=get_node_or_null("MatrixValidation")
	if previous!=null: previous.free()
	var driver:=preload("res://tests/combat_matrix_ui_validation.gd").new()
	driver.name="MatrixValidation";add_child(driver);driver.run(self)

func build_intents_diagnostics(mode: String) -> void:
	var driver:=get_node_or_null("BuildIntentsDiagnostics")
	if driver==null:
		driver=preload("res://tests/build_intents_runtime.gd").new()
		driver.name="BuildIntentsDiagnostics";add_child(driver);driver.begin(self)
	match mode:
		"combat": driver.combat_view()
		"finish": driver.finish();driver.queue_free()
		"cycles": driver.cycles()

func assembly_diagnostics(mode: String) -> void:
	var previous:=get_node_or_null("AssemblyDiagnostics")
	if previous!=null: previous.free()
	var driver:=preload("res://tests/assembly_runtime.gd").new()
	driver.name="AssemblyDiagnostics";add_child(driver)
	match mode:
		"begin": driver.begin(self)
		"cycles": driver.cycles(self)
		"presentation": driver.presentation(self)
		"editor": driver.editor_contract(self)
		"compare": driver.compare_legacy(self)
		"effects": driver.effects_profile(self)

func start_runtime_cycles() -> void:
	var previous := get_node_or_null("RuntimeCycles")
	if previous!=null: previous.free()
	var driver := preload("res://tests/runtime_cycles.gd").new()
	driver.name="RuntimeCycles"
	add_child(driver)
	driver.run(self)

func benchmark_fixture(actions: bool) -> void:
	diagnostic_mode=true
	if editor.visible: editor.close()
	route.start()
	route.actors=preload("res://data/legacy_world_fixture.gd").populate()
	route.zones=preload("res://data/legacy_world_fixture.gd").locations()
	route.group_members.clear()
	for zone in route.zones:
		var members: Array[Dictionary]=[]
		for actor in route.actors:
			if actor.get("zone_id","")==zone.id: members.append(actor)
		route.group_members[zone.id]=members
	combat.actors.clear();combat.actors.append(route.actors[0])
	if actions:
		route.actors[0].position=Vector2(530,150)
		route.zone_index=0
		route.begin_encounter(route.group_for("zone_1"))
		combat.command("priority","guard")
	else: combat.running=false
	refresh()

func open_build(collection_mode: bool) -> void:
	if editor.visible: return
	if combat.running or route.state != "travelling" or not route.visible_world: return
	session.sync_actor(route.actors[0],combat.priority,combat.retained)
	route.menu_paused = true
	route.held_keys.clear()
	editor.open(session.principal_id,collection_mode)

func on_build_applied() -> void:
	var position: Vector2 = route.actors[0].position
	route.actors[0] = session.actor_at(position)
	combat.actors.clear()
	combat.actors.append(route.actors[0])
	combat.priority = session.principal().priority
	combat.retained = session.principal().retained
	arena.sync_visuals(true)
	create_checkpoint()
	refresh()

func copy_selected() -> void:
	if not combat.running: return
	if combat.copy_service.pending_id!="": combat.cancel_copy_request(); return
	if copy_targets.selected<0 or copy_targets.selected>=copy_target_ids.size(): return
	var result: Dictionary = combat.request_copy(copy_target_ids[copy_targets.selected])
	if not result.ok: copy_label.text=result.error
	refresh_copy()

func refresh_copy() -> void:
	if copy_targets==null: return
	var selected_id := copy_target_ids[copy_targets.selected] if copy_targets.selected>=0 and copy_targets.selected<copy_target_ids.size() else ""
	copy_targets.clear(); copy_target_ids.clear()
	var main: Dictionary = combat.principal_actor()
	for actor in combat.actors:
		if main.is_empty() or actor.team==main.team or actor.hp<=0 or actor.get("retired",false): continue
		copy_target_ids.append(actor.id)
		copy_targets.add_item(actor.name+" · %d PV"%actor.hp)
		if actor.id==selected_id: copy_targets.select(copy_target_ids.size()-1)
	var busy: bool = not combat.copy_service.process.is_empty()
	copy_button.text="Cancelar solicitud [X]" if combat.copy_service.pending_id!="" else "Copiar [X]"
	var reason := ""
	if copy_targets.selected>=0: reason=combat.copy_service.eligibility(combat.actor_by_id(copy_target_ids[copy_targets.selected]),main)
	copy_button.disabled=not combat.running or busy or (combat.copy_service.pending_id=="" and (copy_targets.selected<0 or reason!=""))
	copy_label.text=combat.copy_service.message if combat.copy_service.message!="" else reason
	copy_button.tooltip_text=copy_label.text
	matrix_button.disabled=not combat.running or copy_targets.selected<0
	matrix_button.tooltip_text="Matriz de diagnóstico del objetivo; sin efecto de combate"
	copy_label.visible=not narrow_hud and copy_label.text!=""

func create_checkpoint() -> Dictionary:
	if diagnostic_mode or save_service==null or not route.visible_world: return {"ok":false,"error":"Perfil de diagnóstico separado"}
	if combat.running: return {"ok":false,"error":"Se conserva el punto anterior al encuentro"}
	session.sync_actor(route.actors[0],combat.priority,combat.retained)
	var snapshot_data := {"session":session.export_data(),"world":route.export_data()}
	var validation := validate_snapshot(snapshot_data)
	if not validation.ok: save_label.text=validation.error; return validation
	var result: Dictionary=save_service.create_checkpoint(snapshot_data)
	save_label.text=save_service.status
	return result

func validate_snapshot(data: Dictionary) -> Dictionary:
	if not data.get("session") is Dictionary or not data.get("world") is Dictionary: return {"ok":false,"error":"Punto seguro incompleto"}
	var validation: Dictionary=session.validate_data(data.session)
	if not validation.ok: return validation
	return route.validate_data(data.world)

func restore_checkpoint(data: Dictionary) -> Dictionary:
	var validation := validate_snapshot(data)
	if not validation.ok: return validation
	copy_notice=""; copy_notice_seconds=0.0
	session.restore_data(data.session)
	route.restore_data(data.world)
	combat.priority=session.principal().priority
	combat.retained=session.principal().retained
	refresh()
	return {"ok":true}

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		if save_service!=null: save_service.flush()
		get_tree().quit()

func validate_exported_demo() -> void:
	# Explicit CLI verification of the distributed executable; never a player menu.
	diagnostic_mode=true
	var outcomes := {}
	var passed := not get_tree().root.has_node("MCPRuntimeServer")
	for method in ["run_demo_checks","run_combat_demo_checks","run_copy_demo_checks","run_save_demo_checks","run_journey_checks","run_edge_checks"]:
		var result: Dictionary=call(method)
		outcomes[method]=result
		passed=passed and result.passed
	save_service.flush()
	DirAccess.make_dir_recursive_absolute("user://tests")
	var report := {"passed":passed,"mcp_present":get_tree().root.has_node("MCPRuntimeServer"),"version":Engine.get_version_info(),"checks":outcomes,"world":route.state}
	var output := FileAccess.open("user://tests/export_validation.json",FileAccess.WRITE)
	if output==null: passed=false
	else: output.store_string(JSON.stringify(report)); output.close()
	print("EXPORT_VALIDATION "+JSON.stringify(report))
	get_tree().quit(0 if passed else 3)
