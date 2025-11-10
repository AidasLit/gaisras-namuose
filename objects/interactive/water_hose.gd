extends XRToolsPickable

@onready var water_particle : PackedScene = preload("res://objects/utils/spray_particle.tscn")
@onready var nozzle: Marker3D = $Nozzle

var time_counter = 0.0

func _on_ready():
	pass

func _input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("spray"):
		time_counter += 50 * delta
		print(" s ")
	
	while(time_counter >= 1):
		time_counter -= 1;
		var new_particle : SprayParticle = water_particle.instantiate()
		
		### TODO Figure out how to rotate this shit
		new_particle.global_transform = nozzle.global_transform
		new_particle.set_velocity()
		
		get_tree().root.add_child(new_particle)
		tween(new_particle)

func tween(particle: SprayParticle):
	var size_tween = create_tween()
	size_tween.set_parallel()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	
	size_tween.tween_property(particle.collision_shape_3d, "scale", Vector3.ONE * 5.0, particle.timer.wait_time) \
		.from(Vector3.ONE * 0.5)
	size_tween.tween_property(particle.mesh_instance_3d, "scale", Vector3.ONE * 5.0, particle.timer.wait_time) \
		.from(Vector3.ONE * 0.5)
	size_tween.tween_property(particle.hit_box, "scale", Vector3.ONE * 5.0, particle.timer.wait_time) \
		.from(Vector3.ONE * 0.5)
