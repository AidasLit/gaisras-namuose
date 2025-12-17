extends XRToolsPickable
class_name RescueTarget

@export var target_name: String
@onready var pickUp_sound: AudioStreamPlayer3D = $PickUpSound
@onready var die_sound: AudioStreamPlayer3D = $DieSound

# NEW: track pickup state
var _was_picked_up := false

func _physics_process(_delta: float) -> void:
	# Detect pickup transition (works for both hands)
	var is_picked := get_picked_up_by() != null
	if is_picked and not _was_picked_up:
		if pickUp_sound and not pickUp_sound.playing:
			pickUp_sound.play()
	_was_picked_up = is_picked

func dead():
	if not enabled:
		return
	
	enabled = false
	drop()
	die_sound.play()
	await die_sound.finished
	SignalBus.level_failed.emit()
