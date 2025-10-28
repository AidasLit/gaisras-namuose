extends XRToolsPickable

@export var particles_path: NodePath = ^"Nozzle/SprayParticles"
@onready var spray_particles: GPUParticles3D = get_node_or_null(particles_path)

func _physics_process(_delta: float) -> void:
	if spray_particles == null:
		return

	var controller := _resolve_controller()
	if controller == null:
		spray_particles.emitting = false
		return

	var pressed := _read_trigger_pressed(controller)
	spray_particles.emitting = pressed


# --- Helpers ---

func _resolve_controller() -> Node:
	# Get whichever XRController3D is holding this object
	var holder := get_picked_up_by()
	if holder == null:
		return null

	# Case A: holder is the controller itself
	if holder is XRController3D:
		return holder

	# Case B: try common XRTools wrapper with get_controller()
	if holder.has_method("get_controller"):
		var c: Node = holder.get_controller()
		if c is XRController3D:
			return c

	# Case C: climb up parent nodes to find the XRController3D
	var n: Node = holder
	while n:
		if n is XRController3D:
			return n
		n = n.get_parent()

	return null


func _read_trigger_pressed(controller: Node) -> bool:
	# Try several API paths for compatibility

	# 1️⃣ XRController3D.get_input("trigger") → { "value": float }
	if controller.has_method("get_input"):
		var data: Variant = controller.get_input("trigger")
		if typeof(data) == TYPE_DICTIONARY and data.has("value"):
			var val: float = float(data["value"])
			return val > 0.2

	# 2️⃣ XRController3D.get_float_action("/input/trigger/value") → float
	if controller.has_method("get_float_action"):
		var v: Variant = controller.get_float_action("/input/trigger/value")
		if typeof(v) == TYPE_FLOAT:
			var val2: float = v
			return val2 > 0.2

	# 3️⃣ XRController3D.is_button_pressed("trigger_click")
	if controller.has_method("is_button_pressed"):
		if controller.is_button_pressed("trigger_click"):
			return true

	# If none matched, assume not pressed
	return false
