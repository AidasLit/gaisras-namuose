@tool
extends XRToolsSceneBase

@onready var left_pickup: XRToolsFunctionPickup = $XROrigin3D/LeftHand/XRToolsFunctionPickup
@onready var right_pickup: XRToolsFunctionPickup = $XROrigin3D/RightHand/XRToolsFunctionPickup
@onready var left_hand_menu: XRToolsViewport2DIn3D = $XROrigin3D/LeftHand/Viewport2Din3D

var held_items : Array[XRToolsPickable] = [null, null]

func _ready() -> void:
	super._ready()
	
	left_pickup.has_picked_up.connect(item_pickup.bind(0))
	right_pickup.has_picked_up.connect(item_pickup.bind(1))
	
	left_pickup.has_dropped.connect(item_drop.bind(0))
	right_pickup.has_dropped.connect(item_drop.bind(1))

func item_pickup(item : XRToolsPickable, hand : int):
	held_items[hand] = item
	
	if item is WaterHose:
		var menu : WristControl = left_hand_menu.get_scene_instance()
		menu.water_container = item
		menu.update_water_container()

func item_drop(hand : int):
	var item = held_items[hand]
	
	if item is WaterHose:
		var menu : WristControl = left_hand_menu.get_scene_instance()
		menu.water_container = null
		menu.update_water_container()
	
	held_items[hand] = null
