extends Node3D
class_name Fire

@export var intensity: float = 1.0   # 1..0
@onready var p1: GPUParticles3D = $GPUParticles3D
@onready var p2: GPUParticles3D = $GPUParticles3D2
@onready var steam: GPUParticles3D = $Steam   # continuous steam while spraying

func _ready() -> void:
	add_to_group("Fire")
	_apply_visuals()

# Called each frame the extinguisher hits this fire (amount is delta-scaled)
func apply_extinguish(amount: float) -> void:
	if intensity <= 0.0:
		return

	# turn steam ON while being sprayed
	if steam and not steam.emitting:
		steam.emitting = true

	intensity = max(0.0, intensity - amount)

	# if fire is out, stop steam
	if intensity <= 0.0 and steam and steam.emitting:
		steam.emitting = false

	_apply_visuals()

func _apply_visuals() -> void:
	var on := intensity > 0.0
	if p1: p1.emitting = on
	if p2: p2.emitting = on
