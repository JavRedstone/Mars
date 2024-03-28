extends RigidBody2D

var players_seeing = []

var destroy = false
var destroy_timer = 2.9 #slightly less bc glitchy

var friction_coefficient = 1

var original_position
var original_scale

func _ready():
	hide()
	rotation = randf() * 2 * PI
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	elif destroy:
		show()
	else:
		hide()
		
	if destroy:
		if destroy_timer > 0:
			destroy_timer -= delta
		else:
			remove_self()

func _integrate_forces(state):
	var friction_force = -linear_velocity * mass * get_parent().gravity * friction_coefficient
	apply_force(friction_force)
	
func set_children_scale(s):
	original_scale = s
	$ExplosionParticles.scale = s
	$AnimatedSprite2D.scale = s
	$CollisionShape2D.scale = s
	$LightOccluder2D.scale = s
	$LightOccluder2D.scale = s * 5
	
func destroy_self():
	destroy = true
	$AnimatedSprite2D.hide()
	$CollisionShape2D.disabled = true
	$LightOccluder2D.hide()
	$ExplosionParticles.emitting = true
	
	get_parent().rocks_destroyed.append([original_position, 360]) # 6 minute time delay before respawn

func remove_self():
	queue_free()
