extends PanelContainer

@onready var quit_button: Button = $MarginContainer/HBoxContainer/MarginContainer/quit
@onready var home_button: Button = $MarginContainer/HBoxContainer/MarginContainer2/home

func _ready() -> void:
	quit_button.pressed.connect(quit)
	home_button.pressed.connect(home)

func quit():
	get_tree().quit()

func home():
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return

	# Request loading the next scene
	scene_base.load_scene("res://scenes/home.tscn")
