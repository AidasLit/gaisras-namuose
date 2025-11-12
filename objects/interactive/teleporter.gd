extends Node3D

## Zone scene file
@export_file('*.tscn') var zone_scene : String = ""

@export var display_name : String = ""

## If true the zone switcher is enabled
@export var enabled : bool = true

## Name of the spawn-point node name in the target scene
@export var spawn_node_name : String = "Spawn"

@onready var area_3d: Area3D = $Area3D
@onready var label_3d: Label3D = $Label3D

# Called when the node enters the scene tree for the first time.
func _ready():
	area_3d.body_entered.connect(_on_body_entered)
	label_3d.text = display_name

# Called when a body enters this area
func _on_body_entered(body : Node3D):
	# Ignore if not enabled
	if not enabled:
		return

	# Skip if it wasn't the player entering
	if not body.is_in_group("player_body"):
		return

	# Find our scene base
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return

	# Fire the load_scene signal
	if zone_scene == "":
		scene_base.reset_scene(spawn_node_name)
	else:
		scene_base.load_scene(zone_scene, spawn_node_name)
