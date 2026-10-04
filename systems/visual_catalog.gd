extends RefCounted
const Asset=preload("res://data/visual_asset.gd")
const Library=preload("res://data/visual_library.tres")
var entries: Dictionary={}
var issues: Array[String]=[]

func _init(source: Resource=Library) -> void:
	for item in source.entries:
		if not item is Asset:
			issues.append("Entrada visual de tipo incompatible");continue
		var key: String=item.kind+":"+item.definition_id
		if item.definition_id.is_empty() or entries.has(key):
			issues.append("ID visual vacío o duplicado: "+key);continue
		var rules:=preload("res://data/catalog.gd").new()
		if rules.get_value(key).is_empty(): issues.append("Definición visual desconocida: "+key);continue
		for scene in [item.equip_effect,item.persistent_effect,item.execution_effect,item.impact_effect]:
			if scene!=null:
				var state: SceneState=scene.get_state()
				if state.get_node_count()==0 or not ClassDB.is_parent_class(state.get_node_type(0),"Node2D"):
					issues.append("Efecto requiere raíz Node2D: "+key)
		for sizes in [item.anchor_scales,item.anchor_rotations,item.anchor_z]:
			if not sizes.is_empty() and sizes.size()!=10: issues.append("Transformaciones requieren diez valores: "+key)
		var valid_transforms:=true
		for factor in item.anchor_scales:
			valid_transforms=valid_transforms and is_finite(factor) and factor>0
		for angle in item.anchor_rotations: valid_transforms=valid_transforms and is_finite(angle)
		if not valid_transforms: issues.append("Transformaciones no finitas o escala inválida: "+key);continue
		if not is_finite(item.effect_seconds) or item.effect_seconds<=0:
			issues.append("Duración visual inválida: "+key);continue
		var valid_textures:=true
		for texture in [item.icon,item.body,item.world_body,item.mounted_layer]:
			if texture!=null: valid_textures=valid_textures and texture.get_width()>0 and texture.get_height()>0
		if not valid_textures: issues.append("Textura sin dimensiones válidas: "+key);continue
		if not item.mounted_size.is_finite() or item.mounted_size.x<=0 or item.mounted_size.y<=0:
			issues.append("Tamaño de capa inválido: "+key);continue
		if item.kind=="beast":
			for anchors in [item.editor_anchors,item.world_anchors]:
				if not anchors.is_empty() and anchors.size()!=10: issues.append("Se requieren diez anclajes: "+key)
				for p in anchors:
					if not p.is_finite() or p.x<0 or p.y<0 or p.x>1 or p.y>1: issues.append("Anclaje fuera del cuerpo: "+key)
		entries[key]=item

func get_asset(kind: String, id: String) -> Resource:
	return entries.get(kind+":"+id)

func icon(kind: String, id: String) -> Texture2D:
	var item: Resource=get_asset(kind,id)
	return item.icon if item!=null else null

func anchors(id: String, world := false) -> Array[Vector2]:
	var item: Resource=get_asset("beast",id)
	if item!=null:
		var configured: Array[Vector2]=item.world_anchors if world else item.editor_anchors
		if configured.size()==10:
			var valid:=true
			for p in configured: valid=valid and p.is_finite() and p.x>=0 and p.x<=1 and p.y>=0 and p.y<=1
			if valid: return configured.duplicate()
	# Explicit provisional mount sites, not anatomy or final species art.
	return [Vector2(.38,.16),Vector2(.62,.16),Vector2(.25,.35),Vector2(.75,.35),Vector2(.25,.65),Vector2(.75,.65),Vector2(.38,.85),Vector2(.62,.85),Vector2(.50,.40),Vector2(.50,.66)]
