extends MeshInstance3D

var intensity = 0.0
var rate = 0.1

var fires_counter = 0

func _process(delta: float) -> void:
	fires_counter = clamp(fires_counter, 0, 100)
	if fires_counter > 0:
		intensity += delta * 2 * rate * fires_counter
	intensity -= delta * rate
	
	intensity = clamp(intensity, 0.0, 1.0)
	get_surface_override_material(0).set_shader_parameter("strength", intensity)
	
	if intensity >= 1:
		SignalBus.level_failed.emit()
