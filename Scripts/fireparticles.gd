extends Node3D
class_name Fire

@export var hitbox : CollisionShape3D
@export var intensity: float = 1.0 : 
	set(value):
		intensity = value

@onready var p1: GPUParticles3D = $GPUParticles3D
@onready var p2: GPUParticles3D = $GPUParticles3D2
@onready var steam: GPUParticles3D = $Steam   # continuous steam while spraying
@onready var collision_shape_3d: CollisionShape3D = $FireHit/CollisionShape3D
@onready var fire_sound: AudioStreamPlayer3D = $FireSound


func _ready() -> void:
	assert(p1.process_material.emission_point_texture, "Emission point texture not set for the fire")
	assert(hitbox, "No hitbox selected for fire")
	
	collision_shape_3d.shape = hitbox.shape
	
	if intensity > 0.0:
		fire_sound.play()
	
	_apply_visuals()


# Called each frame the extinguisher hits this fire (amount is delta-scaled)
func apply_extinguish(amount: float) -> void:
	if intensity <= 0.0:
		return

	# turn steam ON while being sprayed
	if steam and not steam.emitting:
		steam.emitting = true

	intensity = max(0.0, intensity - amount)

	# if fire is out, stop steam + sound
	if intensity <= 0.0:
		if steam and steam.emitting:
			steam.emitting = false
		if fire_sound.playing:
			fire_sound.stop()

	_apply_visuals()


func _apply_visuals() -> void:
	var on := intensity > 0.0
	if p1: p1.emitting = on
	if p2: p2.emitting = on
