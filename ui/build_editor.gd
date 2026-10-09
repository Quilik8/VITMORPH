extends Control
signal closed
signal applied
signal main_selected
const Palette=preload("res://ui/demo_theme.gd")
const Item=preload("res://ui/assembly_item.gd")
var session: RefCounted
var controller: RefCounted
var visuals:=preload("res://systems/visual_catalog.gd").new()
var draft: Dictionary={}
var owned_id := ""
var collection_mode := false
var section := "mods"
var selected := -1
var selected_kind := "normal"
var selection: Dictionary={}
var drag_active := false
var target_armed := false
var pending_action: Dictionary={}
var heading: Label
var subtitle: Label
var message: Label
var body: BoxContainer
var equipment: VBoxContainer
var context: VBoxContainer
var selector: HBoxContainer
var mounts: Array[Button]=[]
var preview: Control
var beast_visual: Node2D
var skills: GridContainer
var library: GridContainer
var detail: VBoxContainer
var detail_labels: Array[Label] = []
var detail_cursor := 0
var detail_remove: Button
var apply_button: Button
var discard_button: Button
var principal_button: Button
var decision: VBoxContainer
var native_drag_count := 0
var suppress_render := false
var selector_signature := ""
var skills_signature := ""
var library_signature := ""
var skill_tab: Button
var mod_tab: Button

func text(value: String, font_size := 16, color := Palette.INK) -> Label:
	var label:=Label.new();label.text=value
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	return label

func choice(value: String, callback: Callable) -> Button:
	var button:=Button.new();button.text=value;button.custom_minimum_size.y=40
	button.pressed.connect(callback);return button

func clear(container: Node) -> void:
	for child in container.get_children(): container.remove_child(child);child.queue_free()

func _ready() -> void:
	name="BuildEditor";set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	controller=preload("res://systems/build_draft.gd").new(session)
	controller.changed.connect(render)
	var veil:=ColorRect.new();veil.color=Palette.ASSEMBLY_BACKGROUND;veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(veil)
	var margin:=MarginContainer.new();margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,28)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,20)
	add_child(margin)
	var layout:=VBoxContainer.new();margin.add_child(layout)
	var header:=HBoxContainer.new();layout.add_child(header)
	heading=text("Ensamblaje",30,Palette.INK);heading.size_flags_horizontal=SIZE_EXPAND_FILL;header.add_child(heading)
	header.add_child(choice("Volver [Esc]",close))
	subtitle=text("",13,Palette.MUTED);layout.add_child(subtitle)
	var collection_scroll:=ScrollContainer.new();collection_scroll.follow_focus=true;collection_scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;collection_scroll.custom_minimum_size.y=76;layout.add_child(collection_scroll)
	selector=HBoxContainer.new();collection_scroll.add_child(selector)
	var scroll:=ScrollContainer.new();scroll.follow_focus=true;scroll.size_flags_vertical=SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;layout.add_child(scroll)
	body=BoxContainer.new();body.size_flags_horizontal=SIZE_EXPAND_FILL;scroll.add_child(body)
	equipment=VBoxContainer.new();equipment.size_flags_horizontal=SIZE_EXPAND_FILL;equipment.size_flags_stretch_ratio=1.65;body.add_child(equipment)
	preview=preload("res://ui/assembly_stage.gd").new();preview.custom_minimum_size.y=340;preview.mouse_filter=MOUSE_FILTER_IGNORE;equipment.add_child(preview)
	beast_visual=preload("res://ui/beast_visual.gd").new();beast_visual.visuals=visuals;beast_visual.catalog=session.catalog;preview.add_child(beast_visual)
	for index in 10:
		var slot:=index
		var point:=Item.new();point.editor=self;point.target_kind="normal" if index<8 else "special";point.target_index=index if index<8 else index-8
		point.custom_minimum_size=Vector2(44,44);point.size=Vector2(44,44)
		point.pressed.connect(func():choose_target("normal",slot))
		point.disabled=index>=8;point.tooltip_text="Especial reservada" if index>=8 else "Montaje %d"%(index+1)
		preview.add_child(point);mounts.append(point)
	preview.resized.connect(position_mounts)
	equipment.add_child(text("HABILIDADES EQUIPADAS",12,Palette.MUTED))
	skills=GridContainer.new();skills.columns=4;skills.add_theme_constant_override("h_separation",8);equipment.add_child(skills)
	context=VBoxContainer.new();context.size_flags_horizontal=SIZE_EXPAND_FILL;body.add_child(context)
	var tabs:=HBoxContainer.new();context.add_child(tabs)
	skill_tab=choice("Habilidades",func():set_section("skills"));tabs.add_child(skill_tab)
	mod_tab=choice("Mods",func():set_section("mods"));tabs.add_child(mod_tab)
	library=GridContainer.new();library.columns=2;library.add_theme_constant_override("h_separation",12);library.add_theme_constant_override("v_separation",12);context.add_child(library)
	detail=VBoxContainer.new();context.add_child(detail)
	decision=VBoxContainer.new();layout.add_child(decision);decision.hide()
	message=text("",13,Palette.TEAL);layout.add_child(message)
	var footer:=HFlowContainer.new();footer.alignment=FlowContainer.ALIGNMENT_END;layout.add_child(footer)
	principal_button=choice("Elegir como principal",func():request_action({"kind":"principal"}));footer.add_child(principal_button)
	discard_button=choice("Descartar",discard);footer.add_child(discard_button)
	apply_button=choice("Aplicar a esta bestia",apply);footer.add_child(apply_button)
	apply_button.add_theme_stylebox_override("normal",Palette.tile(Palette.GOLD,Color("493329")))
	resized.connect(reflow);hide()

func open(id: String, as_collection := false) -> void:
	collection_mode=as_collection;selection.clear();selected=-1;target_armed=false;pending_action.clear();decision.hide()
	suppress_render=true;controller.select_copy(id);suppress_render=false;show();render()
	if selector.get_child_count()>0: selector.get_child(0).grab_focus()

func set_section(value: String) -> void:
	section=value;selection.clear();target_armed=false;selected=-1;render()

func reflow() -> void:
	if body==null: return
	body.vertical=size.x<900
	context.custom_minimum_size.x=0 if body.vertical else 350
	preview.custom_minimum_size.y=270 if body.vertical else 340
	skills.columns=2 if size.x<1050 else 4
	library.columns=3 if body.vertical else 2
	position_mounts()

func position_mounts() -> void:
	if owned_id.is_empty() or preview==null: return
	var dimensions:=Vector2(minf(preview.size.x-56,420),240 if body.vertical else 310)
	beast_visual.position=preview.size*.5
	beast_visual.configure(session.owned(owned_id).definition_id,draft,session.inventory,dimensions)
	for index in mounts.size(): mounts[index].position=beast_visual.position+beast_visual.mount_point(index)-Vector2(22,22)

func item_button(caption: String, data: Dictionary, kind := "", index := -1) -> Button:
	var button:=Item.new();button.editor=self;button.text="\n\n"+caption;button.custom_minimum_size=Vector2(132,108)
	button.glyph="M" if data.get("kind","")=="normal" else "H"
	button.add_theme_font_size_override("font_size",14)
	for state in ["normal","hover","pressed","focus","disabled"]:
		button.add_theme_stylebox_override(state,Palette.tile(Palette.GOLD if state in ["hover","pressed"] else (Palette.INK if state=="focus" else Palette.LINE),Palette.SURFACE))
	button.payload=data;button.target_kind=kind;button.target_index=index
	button.size_flags_horizontal=SIZE_EXPAND_FILL
	button.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	var asset_kind: String="modifier" if data.get("kind","")=="normal" else "skill"
	var definition: String=session.inventory.get(data.get("id",""),"") if asset_kind=="modifier" else data.get("id","")
	button.glyph=definition.left(1).to_upper()
	button.piece_icon=visuals.icon(asset_kind,definition)
	button.tooltip_text=caption
	return button

func render() -> void:
	if suppress_render: return
	if controller.owned_id.is_empty(): return
	restore_highlights()
	var focus:=get_viewport().gui_get_focus_owner()
	var focus_name: String=focus.name if focus!=null and is_ancestor_of(focus) else ""
	owned_id=controller.owned_id;draft=controller.build
	var beast: Dictionary=session.owned(owned_id)
	detail_cursor=0
	if detail_remove!=null: detail_remove.hide()
	heading.text=beast.name
	subtitle.text="ENSAMBLAJE  /  Copia %s  /  %s"%[owned_id.trim_prefix("copy_"),"Principal" if owned_id==session.principal_id else "Colección"]
	refresh_selector()
	for index in 10:
		var button: Button=mounts[index]
		var instance: String=draft.normal[index] if index<8 else ""
		button.text=str(index+1) if index<8 and instance=="" else ("◆" if index<8 else "E%d"%(index-7))
		button.payload=controller.payload("normal",instance,index) if instance!="" else {}
		button.icon=visuals.icon("modifier",session.inventory.get(instance,""));button.expand_icon=true;button.add_theme_constant_override("icon_max_width",24)
		button.tooltip_text="Especial reservada · sin contenido definido" if index>=8 else "Montaje %d · %s"%[index+1,"Vacío" if instance=="" else mod_name(instance)]
		button.name="Mount_%d"%index
		button.modulate=Palette.GOLD if selected_kind=="normal" and index==selected else (Color.WHITE if instance!="" else Color(.8,.77,.8,.7))
		if index<8 and draft.normal[index]!=beast.build.normal[index]: button.text="+"+button.text;button.tooltip_text+=" · Cambio pendiente"
	refresh_skills(beast)
	for button in skills.get_children():
		if button is Item:
			var skill: Dictionary=session.catalog.skill(button.payload.get("id",""))
			var affected: bool=not selection.is_empty() and selection.get("kind","")=="normal" and session.builds.compatible(skill,selected_property())
			button.add_theme_color_override("font_color",Palette.TEAL if affected else Palette.INK)
			button.add_theme_color_override("font_disabled_color",Palette.TEAL if affected else Palette.MUTED)
	refresh_library()
	skill_tab.text="● Habilidades" if section=="skills" else "Habilidades"
	mod_tab.text="● Mods" if section=="mods" else "Mods"
	skill_tab.add_theme_color_override("font_color",Palette.GOLD if section=="skills" else Palette.MUTED)
	mod_tab.add_theme_color_override("font_color",Palette.GOLD if section=="mods" else Palette.MUTED)
	for button in library.get_children():
		if button is Item:
			var chosen: bool=not selection.is_empty() and button.payload.get("id","")==selection.get("id","")
			button.add_theme_stylebox_override("normal",Palette.tile(Palette.GOLD if chosen else Palette.LINE,Color("3b2d29") if chosen else Palette.SURFACE))
	show_detail()
	for index in range(detail_cursor,detail_labels.size()): detail_labels[index].hide()
	principal_button.disabled=owned_id==session.principal_id
	principal_button.text="Principal actual" if principal_button.disabled else "Elegir como principal"
	apply_button.disabled=not controller.dirty();discard_button.disabled=not controller.dirty()
	message.text=controller.last_error if controller.last_error!="" else ("VISTA PREVIA · Cambios sin aplicar" if controller.dirty() else "BUILD APLICADA · Exploración pausada")
	reflow()
	if focus_name!="":
		call_deferred("restore_focus",focus_name)

func restore_focus(focus_name: String) -> void:
	if not visible: return
	var target:=find_child(focus_name,true,false)
	if target is Control and target.is_inside_tree() and target.is_visible_in_tree(): target.grab_focus()

func refresh_selector() -> void:
	var key := str([owned_id,session.principal_id,session.collection.map(func(copy):return [copy.id,copy.name,copy.definition_id])])
	if key==selector_signature: return
	selector_signature=key;clear(selector)
	for copy in session.collection:
		var id: String=copy.id
		var label: String=("● " if id==owned_id else "")+copy.name+"\n#"+id.trim_prefix("copy_")+(" · Principal" if id==session.principal_id else "")
		var button:=choice(label,func():request_action({"kind":"copy","id":id}))
		button.name="Copy_"+id;button.icon=visuals.icon("beast",copy.definition_id);button.expand_icon=true;button.add_theme_constant_override("icon_max_width",36)
		button.add_theme_stylebox_override("normal",Palette.tile(Palette.GOLD if id==owned_id else Color.TRANSPARENT,Palette.SURFACE if id==owned_id else Color.TRANSPARENT));selector.add_child(button)

func refresh_skills(beast: Dictionary) -> void:
	var key:=str([owned_id,draft.modular,beast.build.modular])
	if key==skills_signature: return
	skills_signature=key;clear(skills)
	for fixed in session.catalog.beast(beast.definition_id).fixed:
		var fixed_item:=item_button(session.catalog.skill(fixed).name+"\nFija",{"id":fixed})
		fixed_item.disabled=true;skills.add_child(fixed_item)
	for index in 2:
		var slot:=index;var id: String=draft.modular[index]
		var state_text: String="M%d · Pendiente"%(index+1) if id!=beast.build.modular[index] else "Modular %d"%(index+1)
		var button:=item_button(session.catalog.skill(id).name+"\n"+state_text,controller.payload("modular",id,index),"modular",index)
		button.name="Modular_%d"%index;button.pressed.connect(func():choose_target("modular",slot));skills.add_child(button)

func refresh_library() -> void:
	var mounted: Array=draft.normal.duplicate();mounted.sort()
	var key:=str([owned_id,section,session.library,session.inventory,mounted,draft.modular,session.collection.map(func(copy):return [copy.id,copy.build.normal])])
	if key==library_signature: return
	library_signature=key;clear(library)
	if section=="skills":
		if session.library.is_empty(): library.add_child(text("Obtén una copia para desbloquear habilidades."))
		for id in session.library:
			var data: Dictionary=controller.payload("modular",id)
			var button:=item_button(session.catalog.skill(id).name+("\nEquipada" if id in draft.modular else "\nDisponible"),data)
			button.name="Library_"+id;button.pressed.connect(func():choose_item(data));library.add_child(button)
	else:
		if session.inventory.is_empty(): library.add_child(text("No hay modificadores disponibles."))
		for instance in session.inventory:
			var data: Dictionary=controller.payload("normal",instance)
			var owner: String=controller.owner_of(instance)
			var caption: String=mod_name(instance)
			if owner!="": caption+="\nEn "+session.owned(owner).name+" #"+owner.trim_prefix("copy_")
			elif instance in draft.normal: caption+="\nMontado"
			else: caption+="\nDisponible"
			var button:=item_button(caption,data);button.name="Library_"+instance;button.disabled=owner!="";button.tooltip_text=caption
			button.pressed.connect(func():choose_item(data));library.add_child(button)

func mod_name(instance: String) -> String:
	var mod: Dictionary=session.catalog.get_value("modifier:"+session.inventory.get(instance,""))
	return mod.get("name","Modificador")+" +%d %%"%roundi(mod.get("percent",0.0)*100)

func detail_line(value: String, font_size := 16, color := Palette.INK) -> Label:
	if detail_cursor>=detail_labels.size():
		var created:=text("",font_size,color)
		detail_labels.append(created);detail.add_child(created)
	var label: Label=detail_labels[detail_cursor]
	detail_cursor+=1
	if label.text!=value: label.text=value;label.tooltip_text=""
	if label.get_theme_font_size("font_size")!=font_size: label.add_theme_font_size_override("font_size",font_size)
	if label.get_theme_color("font_color")!=color: label.add_theme_color_override("font_color",color)
	label.show()
	return label

func show_detail() -> void:
	if selection.is_empty() and selected<0:
		detail_line("Selecciona una pieza",18,Palette.INK)
		detail_line("Elige una habilidad o un mod. Después selecciona su destino, o arrástralo hasta él.",14,Palette.MUTED)
		return
	detail_line("RESULTADO DEL ENSAMBLAJE",12,Palette.GOLD)
	if not selection.is_empty():
		if selection.kind=="normal": detail_line(mod_name(selection.id)+" · "+property_caption(selected_property()),14)
		else:
			var skill: Dictionary=session.catalog.skill(selection.id)
			detail_line("%s · %d daño · reutilización %d"%[skill.name,skill.damage,skill.cooldown],14)
			if skill.status!="": detail_line("Aplica "+("Residuo" if skill.status=="dot" else "ralentización ATB"),13,Palette.MUTED)
	elif selected>=0: detail_line("Destino: "+("montaje %d"%(selected+1) if selected_kind=="normal" else "modular %d"%(selected+1)),14)
	else: detail_line("Elige una mejora o un punto de montaje.",14,Palette.MUTED)
	var before: Dictionary=session.preview_build(owned_id,session.owned(owned_id).build)
	var after: Dictionary=controller.preview()
	var tentative := false
	if not selection.is_empty() and selection.kind=="normal" and selection.id not in draft.normal:
		var destination: int=selected if selected_kind=="normal" and selected>=0 else draft.normal.find("")
		if destination>=0:
			var result: Dictionary=controller.candidate(selection,"normal",destination)
			if result.ok:
				after=session.preview_build(owned_id,result.build);tentative=true
	if tentative: detail_line("Al montar el mod seleccionado · sin aplicar",12,Palette.TEAL)
	for row in after.changes:
		for property in row.properties:
			var values: Dictionary=row.properties[property]
			var original: float=values.base
			for previous in before.changes:
				if previous.id==row.id: original=previous.properties[property].result
			var chosen: bool=not selection.is_empty() and selection.kind=="normal" and property==selected_property()
			if not chosen and is_equal_approx(original,float(values.result)): continue
			var description: String=values.reason if not values.compatible else ("%s %.0f → %.0f%s"%[property_caption(property),original,values.result," s" if property=="status_duration" else ""])
			var label:=detail_line(("› " if chosen and values.compatible else "")+row.name+": "+description,13,Palette.TEAL if values.compatible else Palette.MUTED)
			label.tooltip_text="Base %s · contribuciones: %s · resultado %s"%[values.base,str(values.contributions),values.result]
	if selected_kind=="normal" and selected>=0 and selected<8 and draft.normal[selected]!="":
		if detail_remove==null:
			detail_remove=choice("",func():controller.remove(selected));detail.add_child(detail_remove)
		detail_remove.text="Retirar del montaje %d"%(selected+1);detail_remove.show();detail.move_child(detail_remove,-1)

func selected_property() -> String:
	return session.catalog.get_value("modifier:"+session.inventory.get(selection.get("id",""),"")).get("property","")

func property_caption(property: String) -> String:
	return {"range":"Alcance","damage":"Daño","status_duration":"Duración"}.get(property,property)

func choose_item(data: Dictionary) -> void:
	selection=data.duplicate()
	if target_armed and selected_kind==data.kind: receive_drop(data,selected_kind,selected)
	else:
		render();highlight_targets(data)
		if body.vertical:
			var destination: Control=mounts[0] if data.kind=="normal" else find_child("Modular_0",true,false)
			if destination!=null: destination.call_deferred("grab_focus")

func choose_target(kind: String, index: int) -> void:
	if index>=8: return
	selected_kind=kind;selected=index
	if not selection.is_empty() and selection.kind==kind: receive_drop(selection,kind,index)
	else:
		target_armed=true;section="skills" if kind=="modular" else "mods";render()
		if body.vertical and library.get_child_count()>0: library.get_child(0).call_deferred("grab_focus")

func receive_drop(data: Dictionary, kind: String, index: int) -> void:
	var mounted_id: String=str(data.get("id",""))
	suppress_render=true
	var result: Dictionary=controller.equip(data,kind,index)
	suppress_render=false
	selected_kind=kind;selected=index;drag_active=false;target_armed=false;selection.clear()
	render()
	if result.ok and result.modified and kind=="normal": beast_visual.play_mount(mounted_id,index)
	if not result.ok: message.text=result.error

func highlight_targets(data: Dictionary) -> void:
	for button in mounts:
		if button.target_kind=="normal": button.modulate=Palette.GOLD if controller.candidate(data,"normal",button.target_index).ok else Color(.6,.6,.6,.65)
	for button in skills.get_children():
		if not button is Item: continue
		if data.get("kind","")=="normal":
			button.modulate=Color.WHITE if session.builds.compatible(session.catalog.skill(button.payload.get("id","")),selected_property()) else Color(.8,.8,.8,.8)
		else: button.modulate=Palette.GOLD if controller.candidate(data,"modular",button.target_index).ok else Color(.6,.6,.6,.65)
	controller.last_error=""

func restore_highlights() -> void:
	for button in mounts: button.modulate=Color.WHITE
	for button in skills.get_children(): button.modulate=Color.WHITE

func apply() -> bool:
	var result: Dictionary=controller.apply()
	if result.ok: applied.emit();message.text="Build aplicada a esta copia";return true
	message.text=result.error;return false

func discard() -> void:
	selection.clear();target_armed=false;controller.discard()

func request_action(action: Dictionary) -> void:
	if controller.dirty():
		pending_action=action;clear(decision);decision.show()
		decision.add_child(text("Esta copia tiene cambios sin aplicar",16,Palette.GOLD))
		var actions:=HFlowContainer.new();decision.add_child(actions)
		actions.add_child(choice("Aplicar y continuar",func():if apply():finish_pending()))
		actions.add_child(choice("Descartar y continuar",func():discard();finish_pending()))
		actions.add_child(choice("Seguir editando",func():pending_action.clear();decision.hide()))
		actions.get_child(2).grab_focus()
	else: perform_action(action)

func finish_pending() -> void:
	var action: Dictionary=pending_action.duplicate();pending_action.clear();decision.hide();perform_action(action)

func perform_action(action: Dictionary) -> void:
	selection.clear();target_armed=false;selected=-1
	match action.get("kind",""):
		"copy": controller.select_copy(action.id)
		"close": hide();draft={};closed.emit()
		"principal":
			var result: Dictionary=session.select_principal(owned_id)
			if result.ok: main_selected.emit();render()
			else: message.text=result.error

func close() -> void:
	request_action({"kind":"close"})

func _input(event: InputEvent) -> void:
	if not visible or not event is InputEventKey or not event.pressed: return
	if event.keycode==KEY_ESCAPE:
		if drag_active:
			get_viewport().gui_cancel_drag();drag_active=false;selection.clear();restore_highlights()
		elif decision.visible: pending_action.clear();decision.hide()
		elif not selection.is_empty(): selection.clear();target_armed=false;render()
		else: close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:
		var focus:=get_viewport().gui_get_focus_owner()
		if focus!=null:
			var next:=focus.find_prev_valid_focus() if event.keycode in [KEY_LEFT,KEY_UP] else focus.find_next_valid_focus()
			if next!=null: next.grab_focus()
		get_viewport().set_input_as_handled()
