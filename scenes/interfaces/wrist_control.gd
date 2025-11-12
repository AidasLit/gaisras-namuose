extends PanelContainer
class_name WristControl

@onready var quit_button: Button = %quit
@onready var home_button: Button = %home
@onready var water_control: MarginContainer = $"VBoxContainer/Water control"
@onready var water_bar: ProgressBar = $"VBoxContainer/Water control/ProgressBar"
@onready var home_scene: String = "uid://dr3kqc5vp636u"

var water_container : WaterHose

func _ready() -> void:
	quit_button.pressed.connect(quit)
	home_button.pressed.connect(home)
	
	update_water_container()

func quit():
	get_tree().quit()

func update_water_container():
	if water_container:
		water_container.water_emitted.connect(update_water)
		water_bar.max_value = water_container.max_capacity
		update_water()
		water_control.show()
	else:
		water_control.hide()

func update_water():
	water_bar.value = water_container.current_capacity

func home():
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return

	# Request loading the next scene
	scene_base.load_scene(home_scene)
