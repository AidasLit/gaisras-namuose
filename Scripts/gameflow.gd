extends Node

enum LevelType{
	None,
	ClearFire,
	SaveObject
}

enum LevelState{
	None,
	InProgress,
	Finished,
}

@export var type : LevelType = LevelType.None
@export var world_objects : Node

var state = LevelState.None

func _ready() -> void:
	#assert(world_objects)
	
	match type:
		LevelType.None:
			state = LevelState.None
		LevelType.ClearFire:
			state = LevelState.InProgress
			SignalBus.fire_extinguished.connect(check_win_condition)
		_:
			state = LevelState.InProgress

func check_win_condition():
	match type:
		LevelType.ClearFire:
			if get_tree().get_nodes_in_group("fire").is_empty():
				change_state(LevelState.Finished)

func change_state(new_state: LevelState):
	match new_state:
		LevelState.None:
			pass
		LevelState.InProgress:
			pass
		LevelState.Finished:
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			if not scene_base:
				push_error("Failed to find scene base")
			
			await get_tree().create_timer(5.0).timeout
			
			# Request loading the next scene
			scene_base.load_scene("res://scenes/home.tscn")
