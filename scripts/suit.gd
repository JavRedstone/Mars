extends RigidBody2D

var players_seeing = []

var friction_coefficient = 0.8

var battery = 100
var oxygen_level = 100

var charging = false
var oxygen_replenishing = false

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()
	
	if charging:
		battery += 5 * delta
	if oxygen_replenishing:
		oxygen_level += 2.5 * delta

	if battery < 0:
		battery = 0
	elif battery > 100:
		battery = 100
	
	if oxygen_level < 0:
		oxygen_level = 0
	elif oxygen_level > 100:
		oxygen_level = 100

func _integrate_forces(state):
	var friction_force = -linear_velocity * mass * get_parent().gravity * friction_coefficient
	apply_force(friction_force)

func destroy_self():
	queue_free()
