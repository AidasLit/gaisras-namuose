extends StaticBody3D
class_name ObstacleObjectBase

@onready var hurt_box: Area3D = $HurtBox
@onready var hit_box: Area3D = $Hitbox
@onready var fire: GPUParticles3D = $Fire
@onready var intensity_timer: Timer = $Intensity
@onready var damage_timer: Timer = $DamageArea
@onready var fire_sound: AudioStreamPlayer3D = $FireSound

### fire system
@export var burning = false : 
	set(value):
		if value != burning:
			if value:
				self.add_to_group("fire")
				_play_fire_sound()
				
			else:
				self.remove_from_group("fire")
				_stop_fire_sound()
			
			SignalBus.fire_update.emit()
		
		burning = value

# TODO rework this trash for easier level editing
@export var max_particles : int = 100
@export var intensity : float = 100 :
	set(value):
		# TODO this shouldnt be needed
		if not fire:
			return
		
		intensity = value
		if intensity > 10:
			fire.emitting = true
			
			burning = true
			
			### Handle fire intensity logic here. For now just adjusting fire particles
			fire.amount_ratio = intensity * 1.0 / 100
		else:
			fire.emitting = false
			burning = false

var was_recently_hit : bool = false
var close_bodies : Array[ObstacleObjectBase] = []

func _ready() -> void:
	intensity_timer.timeout.connect(on_intensity_timeout)
	damage_timer.timeout.connect(on_damage_timeout)
	
	hit_box.area_entered.connect(func(area):
		var temp = area.get_parent()
		if temp is ObstacleObjectBase:
			if temp == self:
				return
			else:
				temp.close_bodies.append(self)
		elif temp is RescueTarget:
			if burning:
				temp.dead()
	)
	
	if self.burning:
		fire.emitting = true

func _physics_process(delta: float) -> void:
	if burning:
		if not was_recently_hit:
			if intensity < 100:
				intensity += 5.0 * delta
	else:
		if damage_timer.time_left == 0:
			for item in close_bodies:
				if item.burning:
					ignite()
					break

func particle_hit():
	intensity = intensity - 3
	was_recently_hit = true
	intensity_timer.start(10.0)
	damage_timer.paused = true

func ignite():
	damage_timer.start(7.0)

func on_intensity_timeout():
	was_recently_hit = false
	damage_timer.paused = false

func on_damage_timeout():
	for item in close_bodies:
		if item.burning and not item.was_recently_hit:
			burning = true
			intensity = 20

func _play_fire_sound() -> void:
	if fire_sound and not fire_sound.playing:
		fire_sound.play()

func _stop_fire_sound() -> void:
	if fire_sound and fire_sound.playing:
		fire_sound.stop()
