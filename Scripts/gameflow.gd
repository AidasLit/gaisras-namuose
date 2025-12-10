extends Node
class_name GameFlow

const home_scene : String = "uid://dr3kqc5vp636u"

enum LevelType{
	None = 0,
	ClearFire = 1,
	SaveObject = 2
}

enum LevelState{
	None,
	InProgress,
	Finished,
	Failed
}

const objectives = [
	"Objective complete",
	"Extinguish all fires",
	"Retrieve objects: ",
	"Level failed"
]

@export var type : LevelType = LevelType.None

var state = LevelState.None
var objective : String
var stasis_fires : int = 0

func _ready() -> void:
	#Performance.add_custom_monitor("test", func() -> int: return stasis_fires)
	
	SignalBus.level_failed.connect(func():
		change_state(LevelState.Failed)
	)
	match type:
		LevelType.None:
			objective = ""
			state = LevelState.None
		LevelType.ClearFire:
			objective = objectives[1]
			state = LevelState.InProgress
			SignalBus.fire_update.connect(fires_update)
			fires_update()
		LevelType.SaveObject:
			objective = objectives[2]
			state = LevelState.InProgress
			SignalBus.object_rescued.connect(objects_update)
			objects_update()

func fires_update():
	var fires = get_tree().get_nodes_in_group("fire")
	#stasis_fires = fires.filter(func(item): return item.was_recently_hit).size()
	if fires.is_empty():
		change_state(LevelState.Finished)
	else:
		objective = objectives[1] + "\nFires left: " + str(fires.size())
	SignalBus.flow_update.emit()

func objects_update():
	var objects = get_tree().get_nodes_in_group("rescue_targets")
	if objects.is_empty():
		change_state(LevelState.Finished)
	else:
		objective = objectives[2]
		for item in objects:
			assert(item.target_name, "target object has no name")
			objective += "\n" + str(item.target_name)
	
	SignalBus.flow_update.emit()

func change_state(new_state: LevelState):
	SignalBus.state_change.emit()
	
	match new_state:
		LevelState.None:
			pass
		LevelState.InProgress:
			pass
		LevelState.Finished:
			objective = objectives[0]
			SignalBus.flow_update.emit()
			
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			if not scene_base:
				push_error("Failed to find scene base")
			
			await get_tree().create_timer(5.0).timeout
			
			scene_base.load_scene(home_scene)
		LevelState.Failed:
			objective = objectives[3]
			SignalBus.flow_update.emit()
			
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			if not scene_base:
				push_error("Failed to find scene base")
			
			await get_tree().create_timer(5.0).timeout
			
			scene_base.load_scene(home_scene)
