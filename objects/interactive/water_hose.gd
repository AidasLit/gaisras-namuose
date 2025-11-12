extends XRToolsPickable
class_name WaterHose

@onready var water_particle : PackedScene = preload("res://objects/utils/spray_particle.tscn")
@onready var nozzle_from: Marker3D = $"Nozzle from"
@onready var nozzle_to: Marker3D = $"Nozzle to"

var max_capacity : int = 2000
var current_capacity : int = max_capacity

var time_counter = 0.0
var spray_direction = Vector3.ZERO
# not an actual angle, rather an offset in space at a 1m. distance from origin
var spray_angle = 0.2
const particle_scale = [Vector3.ONE * 0.1, Vector3.ONE * 1.0]

signal water_emitted

func _ready():
	super._ready()
	
	current_capacity = max_capacity

func _input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("spray"):
		if current_capacity > 0:
			time_counter += 200  * delta
	
	while(time_counter >= 1):
		time_counter -= 1;
		randomise_direction()
		
		var new_particle : SprayParticle = water_particle.instantiate()
		get_tree().root.add_child(new_particle)
		
		new_particle.global_position = nozzle_from.global_position
		new_particle.set_velocity(spray_direction)
		
		tween(new_particle)
		
		current_capacity = current_capacity - 1;
		water_emitted.emit()

func tween(particle: SprayParticle):
	var size_tween = create_tween()
	size_tween.set_parallel()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	
	size_tween.tween_property(particle.collision_shape_3d, "scale", particle_scale[1], particle.timer.wait_time) \
		.from(particle_scale[0])
	size_tween.tween_property(particle.mesh_instance_3d, "scale", particle_scale[1], particle.timer.wait_time) \
		.from(particle_scale[0])
	size_tween.tween_property(particle.hit_box, "scale", particle_scale[1], particle.timer.wait_time) \
		.from(particle_scale[0])

func randomise_direction():
	var randomisation_vector = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * spray_angle
	nozzle_to.position.x = nozzle_from.position.x + randomisation_vector.x
	nozzle_to.position.y = nozzle_from.position.y + randomisation_vector.y
	nozzle_to.position.z = nozzle_from.position.z + 1.0
	spray_direction = (nozzle_to.global_position - nozzle_from.global_position).normalized()
