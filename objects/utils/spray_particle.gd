class_name SprayParticle
extends RigidBody3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var timer: Timer = $Timer
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var hit_box: Area3D = $HitBox

@export var spread_velocity = 0.2
@export var forward_velocity = 10.0

func _ready() -> void:
	var rand_rotation = randf_range(0, PI)
	mesh_instance_3d.set_instance_shader_parameter("rotate_by", rand_rotation)
	
	timer.timeout.connect(func(): queue_free())
	self.body_entered.connect(_on_body_entered)
	hit_box.area_entered.connect(_on_area_entered)

func set_velocity(direction : Vector3):
	linear_velocity = direction * forward_velocity

func _on_body_entered(body):
	if not body.is_in_group("fire"):
		queue_free()

func _on_area_entered(area):
	if area.get_parent().is_in_group("fire"):
		on_fire_collide()
		area.get_parent().particle_hit()
	else:
		queue_free()

func on_fire_collide():
	timer.start(timer.time_left + 3.0)
	
	collision_shape_3d.free()
	mesh_instance_3d.free()
	hit_box.queue_free()
	
	gpu_particles_3d.global_position = self.global_position
	gpu_particles_3d.emitting = true
