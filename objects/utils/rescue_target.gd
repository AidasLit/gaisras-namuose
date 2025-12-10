extends XRToolsPickable
class_name RescueTarget

@export var target_name : String

func dead():
	enabled = false
	drop()
	SignalBus.level_failed.emit()
