extends Skeleton3D

func _ready() -> void:
	# This is the ONLY correct way to start ragdoll simulation in Godot 4
	physical_bones_start_simulation()
