extends XRToolsPickable

@export var particles_path: NodePath = ^"Nozzle/SprayParticles"
@export var spray_area_path: NodePath = ^"Nozzle/SprayArea"
@export var spray_power_per_sec: float = 0.8   # how fast fire intensity drops (per second)

@onready var spray_particles: GPUParticles3D = get_node_or_null(particles_path)
@onready var spray_area: Area3D = get_node_or_null(spray_area_path)

func _physics_process(_delta: float) -> void:
	if spray_particles == null:
		return

	var controller := _resolve_controller()
	if controller == null:
		spray_particles.emitting = false
		return

	var pressed := _read_trigger_pressed(controller)
	spray_particles.emitting = pressed

	# While spraying, apply extinguish to anything in the spray volume
	if pressed and spray_area:
		_extinguish_in_area(_delta)

# --- Helpers you already had ---

func _resolve_controller() -> Node:
	var holder := get_picked_up_by()
	if holder == null:
		return null
	if holder is XRController3D:
		return holder
	if holder.has_method("get_controller"):
		var c: Node = holder.get_controller()
		if c is XRController3D:
			return c
	var n: Node = holder
	while n:
		if n is XRController3D:
			return n
		n = n.get_parent()
	return null

func _read_trigger_pressed(controller: Node) -> bool:
	if controller.has_method("get_input"):
		var data: Variant = controller.get_input("trigger")
		if typeof(data) == TYPE_DICTIONARY and data.has("value"):
			var val: float = float(data["value"])
			return val > 0.2
	if controller.has_method("get_float_action"):
		var v: Variant = controller.get_float_action("/input/trigger/value")
		if typeof(v) == TYPE_FLOAT:
			var val2: float = v
			return val2 > 0.2
	if controller.has_method("is_button_pressed"):
		if controller.is_button_pressed("trigger_click"):
			return true
	return false

# --- NEW: extinguish logic ---

func _extinguish_in_area(delta: float) -> void:
	# bodies and areas to be safe (depending on your fire’s root type)
	for n in spray_area.get_overlapping_bodies():
		_apply_if_fire(n, delta)
	for n in spray_area.get_overlapping_areas():
		_apply_if_fire(n, delta)

func _apply_if_fire(n: Node, delta: float) -> void:
	var fire := _find_fire_root(n)
	if fire and fire.has_method("apply_extinguish"):
		fire.apply_extinguish(spray_power_per_sec * delta)

func _find_fire_root(n: Node) -> Node:
	var cur: Node = n
	while cur:
		# prefer group match, fallback to method presence
		if cur.is_in_group("fire") or cur.has_method("apply_extinguish"):
			return cur
		cur = cur.get_parent()
	return null
