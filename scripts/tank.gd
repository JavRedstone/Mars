extends RigidBody2D

var players_seeing = []

var is_player_inside = false
var player_inside

var acceleration = 5000
var max_velocity = 1000
var angular_acceleration = 10
var max_angular_velocity = 2
var multiplier = 1000
var friction_coefficient = 0.8

var battery = 100
var charging = false

var in_habitations = []
var in_oxygen_areas = []

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()

	if is_player_inside:
		player_inside.position = position
		player_inside.rotation = rotation
	elif !is_player_inside and player_inside != null:
		player_inside.is_in_vehicle = false
		player_inside.position = position + Vector2(0, -200).rotated(rotation)
		player_inside.vehicle = null
		player_inside = null
	
	if get_parent().is_night and battery > 0:
		$LeftHeadlight.enabled = true
		$RightHeadlight.enabled = true
		battery -= 0.5 * delta
	else:
		$LeftHeadlight.enabled = false
		$RightHeadlight.enabled = false
		$LeftTailLight.enabled = false
		$RightTailLight.enabled = false
	
	if charging:
		battery += 5 * delta
	
	if battery < 0:
		battery = 0
	elif battery > 100:
		battery = 100

func _integrate_forces(state):
	wasd_movement()

func get_in_vehicle(player):
	if !is_player_inside:
		player_inside = player
		is_player_inside = true
		player_inside.is_in_vehicle = true
		player_inside.vehicle = self

func get_out_vehicle(player):
	if is_player_inside and player_inside == player:
		is_player_inside = false
		return true
	return false

func wasd_movement():
	if is_player_inside and battery > 0:
		if Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			$LeftParticleEmitter.emitting = true
			$RightParticleEmitter.emitting = true
			$AnimatedSprite2D.play("moving")
			$LeftTailLight.enabled = false
			$RightTailLight.enabled = false
			battery -= 0.025
		else:
			$LeftParticleEmitter.emitting = false
			$RightParticleEmitter.emitting = false
			$AnimatedSprite2D.play("default")
			if get_parent().is_night:
				$LeftTailLight.enabled = true
				$RightTailLight.enabled = true
				battery -= 0.005
		if Input.is_action_pressed("up"):
			apply_force(Vector2.UP.rotated(rotation) * acceleration * multiplier)
		if Input.is_action_pressed("down"):
			apply_force(Vector2.DOWN.rotated(rotation) * acceleration * multiplier)
		if Input.is_action_pressed("left"):
			apply_torque(-mass * angular_acceleration * multiplier)
		if Input.is_action_pressed("right"):
			apply_torque(mass * angular_acceleration * multiplier)
	else:
		$LeftParticleEmitter.emitting = false
		$RightParticleEmitter.emitting = false
		$AnimatedSprite2D.play("default")
		
	if !get_parent().is_night: # i have to do it here so that the rover can't just keep moving
		battery += 0.005 # passive charging due to solar
	
	if battery < 0:
		battery = 0
	elif battery > 100:
		battery = 100
	
	if in_habitations.size() > 0:
		$LeftParticleEmitter.emitting = false
		$RightParticleEmitter.emitting = false
		
	var friction_torque = -angular_velocity * mass * get_parent().gravity * multiplier * friction_coefficient
	apply_torque(friction_torque)
	
	var friction_force = -linear_velocity * mass * get_parent().gravity * friction_coefficient
	apply_force(friction_force)
	
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
	var clamped_av = clamp(angular_velocity, -max_angular_velocity, max_angular_velocity)
	if angular_velocity != clamped_av:
		angular_velocity = clamped_av

func destroy_self():
	queue_free()
