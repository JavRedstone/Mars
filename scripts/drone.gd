extends RigidBody2D

var players_seeing = []

var is_player_inside = false
var player_inside
var is_flying = false

var acceleration = 5000
var ground_friction_coefficient = 0.8
var air_friction_coefficient = 0.4
var max_velocity = 1000
var turning_speed = 10

var battery = 100
var charging = false

var in_habitations = []
var in_oxygen_areas = []

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	elif is_player_inside: # otherwise collision shape disabled will make my thing hide
		show()
	else:
		hide()
		
	if is_flying:
		scale = Vector2.ONE * 0.5
		collision_mask = 2
		collision_layer = 2
		$LightOccluder2D.occluder_light_mask = 4
		$AnimatedSprite2D.play("moving")
	else:
		scale = Vector2.ONE * 0.25
		collision_mask = 1
		collision_layer = 1
		$LightOccluder2D.occluder_light_mask = 3
		$AnimatedSprite2D.play("default")

	$CollisionPolygon2D.scale = scale
	
	if is_player_inside:
		player_inside.position = position
		player_inside.rotation = 0
		player_inside.z_index = 1001
	elif !is_player_inside and player_inside != null:
		player_inside.z_index = 2
		player_inside.is_in_vehicle = false
		player_inside.position = position + Vector2(0, -100).rotated(rotation)
		player_inside.vehicle = null
		player_inside = null

	if charging:
		battery += 7.5 * delta

	if battery < 0:
		battery = 0
	elif battery > 100:
		battery = 100

func _integrate_forces(state):
	wasd_movement()

func get_in_vehicle(player):
	if !is_player_inside:
		is_flying = true
		player_inside = player
		is_player_inside = true
		player_inside.is_in_vehicle = true
		player_inside.vehicle = self

func get_out_vehicle(player):
	if is_player_inside and player_inside == player:
		is_flying = false
		is_player_inside = false
		return true
	return false

func wasd_movement():
	if is_player_inside and battery > 0:
		is_flying = true
		battery -= 0.025
		var input_direction = Input.get_vector("left", "right", "up", "down")
		apply_force(input_direction * mass * acceleration)
		
		if linear_velocity.length() > max_velocity:
			linear_velocity = linear_velocity.normalized() * max_velocity
	else:
		is_flying = false
		$AnimatedSprite2D.play("default")
	
	if battery < 0:
		battery = 0
	elif battery > 100:
		battery = 100
	
	var friction_coefficient = ground_friction_coefficient
	if is_flying:
		friction_coefficient = air_friction_coefficient
	
	
	var friction_force = -linear_velocity * mass * get_parent().gravity * friction_coefficient
	apply_force(friction_force)
	
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
