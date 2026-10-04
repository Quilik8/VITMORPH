extends Resource
class_name VitmorphVisualAsset
## Presentation only. IDs refer to catalog definitions, never mutable owned state.
@export_enum("beast","skill","modifier") var kind := "modifier"
@export var definition_id := ""
@export var revision := ""
@export var source_note := ""
@export var approval := "POR DEFINIR"
@export var icon: Texture2D
@export var body: Texture2D
@export var world_body: Texture2D
@export var mounted_layer: Texture2D
@export var editor_anchors: Array[Vector2] = []
@export var world_anchors: Array[Vector2] = []
@export var anchor_scales: Array[float] = []
@export var anchor_rotations: Array[float] = []
@export var anchor_z: Array[int] = []
@export var mounted_size := Vector2(0.20,0.20)
@export var equip_effect: PackedScene
@export var persistent_effect: PackedScene
@export var execution_effect: PackedScene
@export var impact_effect: PackedScene
@export_range(0.1,10.0) var effect_seconds := 1.0
