extends Area3D

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D):
	if body is RescueTarget and body.is_in_group("rescue_targets"):
		body.remove_from_group("rescue_targets")
		
		var timer = get_tree().create_timer(3)
		await timer.timeout
		
		SignalBus.object_rescued.emit()
		body.queue_free()
