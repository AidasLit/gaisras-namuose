extends PanelContainer
class_name WristControl

@onready var quit_button: Button = %quit
@onready var home_button: Button = %home

@onready var water_control: MarginContainer = $"VBoxContainer/Water control"
@onready var water_bar: ProgressBar = $"VBoxContainer/Water control/ProgressBar"

@onready var text_control: PanelContainer = $VBoxContainer/TextControl
@onready var label: Label = $VBoxContainer/TextControl/Label

@onready var home_scene: String = "uid://dr3kqc5vp636u"

var gameflow : GameFlow
var water_container : WaterHose

### TODO text size doesnt change

func _ready() -> void:
	quit_button.pressed.connect(quit)
	home_button.pressed.connect(home)
	SignalBus.flow_update.connect(update_game_flow)
	
	update_water_container()
	update_game_flow()

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

func update_game_flow():
	if gameflow:
		match gameflow.state:
			gameflow.LevelState.InProgress:
				update_objective(gameflow.objective)
				text_control.show()
			gameflow.LevelState.Finished:
				update_objective("Level done!")
				text_control.show()
			_:
				text_control.hide()

func update_objective(objective : String):
	label.text = "Current objective:\n" + objective

func home():
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return

	# Request loading the next scene
	scene_base.load_scene(home_scene)
