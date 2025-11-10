extends RigidBody3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	var rand_rotation = randf_range(0, PI)
	mesh_instance_3d.set_instance_shader_parameter("rotate_by", rand_rotation)
