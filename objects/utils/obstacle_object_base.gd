extends StaticBody3D

@onready var hurt_box: Area3D = $HurtBox
@onready var hit_box: Area3D = $Hitbox
@onready var fire: GPUParticles3D = $Fire

### fire system
@export_group("Fire")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var burnable = false

@export var burning = false : 
	set(value):
		burning = value
		if value:
			self.add_to_group("fire")
		else:
			self.remove_from_group("fire")
			SignalBus.fire_extinguished.emit()

# TODO rework this trash for easier level editing
@export var max_particles : int = 100
@export var intensity : int = 100 :
	set(value):
		### TODO this shouldnt be needed
		if not fire:
			return
		
		intensity = value
		if intensity > 0:
			fire.emitting = true
			
			burning = true
			
			### Handle fire intensity logic here. For now just adjusting fire particles
			fire.amount_ratio = intensity * 1.0 / 100
		else:
			fire.emitting = false
			burning = false

### breaking system

@export_group("Breaking")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var breakable = false

var broken : bool = false
@export var durability = 3 :
	set(value):
		durability = value
		
		if durability == 0:
			broken = true
			breakable = false

func _ready() -> void:
	if self.burning:
		fire.emitting = true

func particle_hit():
	intensity = intensity - 1

func axe_hit():
	durability = durability - 1
