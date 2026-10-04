extends Node2D
## Same presentation component in assembly and arena. No game-rule decisions.
var visuals: RefCounted
var catalog: RefCounted
var beast_id := ""
var build: Dictionary={}
var inventory: Dictionary={}
var world_mode := false
var body_size := Vector2(300,340)
var layers: Array[Node]=[]
var bursts: Array[Node]=[]
var signature := ""
var effects_started := 0
const EFFECT_LIMIT := 12

func configure(id: String, configuration: Dictionary, instances: Dictionary, dimensions: Vector2, world := false) -> void:
	var next:=str([id,configuration,instances,dimensions,world])
	if next==signature: return
	signature=next;beast_id=id;build=configuration.duplicate(true);inventory=instances.duplicate();body_size=dimensions;world_mode=world
	var body_asset: Resource=visuals.get_asset("beast",id)
	if body_asset!=null:
		var texture: Texture2D=body_asset.world_body if world and body_asset.world_body!=null else body_asset.body
		if texture!=null: body_size=texture.get_size()*minf(dimensions.x/texture.get_width(),dimensions.y/texture.get_height())
	for layer in layers: layer.free()
	layers.clear()
	for burst in bursts:
		if is_instance_valid(burst): burst.queue_free()
	bursts.clear()
	for kind in ["normal","special"]:
		for index in build.get(kind,[]).size():
			var instance: String=build[kind][index]
			if not inventory.has(instance): continue
			var item: Resource=visuals.get_asset("modifier",inventory[instance])
			if item==null: continue
			var anchor_index: int=index+(8 if kind=="special" else 0)
			var position_in_body: Vector2=mount_point(anchor_index)
			var beast: Resource=visuals.get_asset("beast",beast_id)
			var depth: int=beast.anchor_z[anchor_index] if beast!=null and beast.anchor_z.size()==10 else 1
			var scale_factor: float=beast.anchor_scales[anchor_index] if beast!=null and beast.anchor_scales.size()==10 else 1.0
			var angle: float=beast.anchor_rotations[anchor_index] if beast!=null and beast.anchor_rotations.size()==10 else 0.0
			if item.mounted_layer!=null:
				var sprite:=Sprite2D.new()
				sprite.texture=item.mounted_layer;sprite.position=position_in_body;sprite.z_index=depth
				sprite.scale=body_size*item.mounted_size/sprite.texture.get_size()*scale_factor
				sprite.rotation=angle
				add_child(sprite);layers.append(sprite)
			if item.persistent_effect!=null:
				var effect:=instance_effect(item.persistent_effect,position_in_body,false,item.effect_seconds)
				if effect!=null: effect.z_index=depth;effect.scale*=scale_factor;effect.rotation=angle;layers.append(effect)
	queue_redraw()

func mount_point(index: int) -> Vector2:
	var points: Array[Vector2]=visuals.anchors(beast_id,world_mode)
	return (points[index]-Vector2(.5,.5))*body_size

func _draw() -> void:
	var item: Resource=visuals.get_asset("beast",beast_id)
	var texture: Texture2D=null
	if item!=null: texture=item.world_body if world_mode and item.world_body!=null else item.body
	if texture!=null:
		var scale_factor: float=minf(body_size.x/texture.get_width(),body_size.y/texture.get_height())
		var dimensions:=texture.get_size()*scale_factor
		draw_texture_rect(texture,Rect2(-dimensions*.5,dimensions),false)
	elif not world_mode:
		var points:=PackedVector2Array([Vector2(-.13,-.47),Vector2(.13,-.47),Vector2(.30,-.24),Vector2(.25,.08),Vector2(.36,.32),Vector2(.23,.45),Vector2(.07,.25),Vector2(-.07,.25),Vector2(-.23,.45),Vector2(-.36,.32),Vector2(-.25,.08),Vector2(-.30,-.24)])
		for index in points.size(): points[index]*=body_size
		draw_colored_polygon(points,Color("34483c"))
		points.append(points[0]);draw_polyline(points,Color("83937c"),2.0,true)

func instance_effect(scene: PackedScene, at: Vector2, transient: bool, seconds: float) -> Node2D:
	if transient and bursts.size()>=EFFECT_LIMIT: return null
	var state: SceneState=scene.get_state()
	if state.get_node_count()==0 or not ClassDB.is_parent_class(state.get_node_type(0),"Node2D"): return null
	var node:=scene.instantiate()
	if not node is Node2D: node.free();return null
	add_child(node);node.position=at
	if transient:
		effects_started+=1
		bursts.append(node)
		get_tree().create_timer(seconds).timeout.connect(func():
			bursts.erase(node)
			if is_instance_valid(node): node.queue_free())
	return node

func play_mount(instance: String, index: int) -> void:
	var item: Resource=visuals.get_asset("modifier",inventory.get(instance,""))
	if item!=null and item.equip_effect!=null: instance_effect(item.equip_effect,mount_point(index),true,item.effect_seconds)

func play_skill(id: String, impact := false, at := Vector2.ZERO) -> void:
	var item: Resource=visuals.get_asset("skill",id)
	if item!=null:
		var scene: PackedScene=item.impact_effect if impact else item.execution_effect
		if scene!=null: instance_effect(scene,at,true,item.effect_seconds)
	var skill: Dictionary=catalog.skill(id)
	if skill.is_empty() or skill.range<=0 or skill.shield>0: return
	for instance in build.get("normal",[]):
		var mod: Resource=visuals.get_asset("modifier",inventory.get(instance,""))
		if mod==null: continue
		var scene: PackedScene=mod.impact_effect if impact else mod.execution_effect
		if scene!=null: instance_effect(scene,at,true,mod.effect_seconds)

func has_body() -> bool:
	var item: Resource=visuals.get_asset("beast",beast_id)
	return item!=null and (item.body!=null or (world_mode and item.world_body!=null))
