extends RigidBody2D

var acceleration = 1500
var friction_coefficient = 0.8
var max_velocity = 250
var turning_speed = 10

var initial_camera_zoom = Vector2(0.5, 0.5)
var initial_viewport_size = Vector2(960, 540)
var camera_zoom = initial_camera_zoom

var is_in_vehicle = false
var vehicles = []
var vehicle

var freeze_rotation = false

var team = 0
var hab = null
var in_habitations = []
var in_oxygen_areas = []

var has_suit = true
var suits = []
var suit

var module_addition_areas = []

var destroyable_rocks = []

var inventory = [0, 0, 0] # soil, rock, metal

var battery = 100
var battery_loss_rate = 0

var oxygen_level = 100
var oxygen_loss_rate = 0
var self_oxygen_loss_rate = 10
var suit_oxygen_loss_rate = 0.5
var oxygen_gain_rate = -10
var hab_oxygen_loss_rate = 0.05

@export var ui_scene: PackedScene
var ui

#func _enter_tree():
#	set_multiplayer_authority(name.to_int())

func _ready():
#	if is_multiplayer_authority():
#		$Camera2D.make_current()
	ui = ui_scene.instantiate()
	add_child(ui)
	
	if has_suit:
		ui.show_take_off_suit_button()

func _physics_process(delta):
#	if is_multiplayer_authority():
		$Camera2D.zoom = camera_zoom * get_viewport_rect().size.length() / initial_viewport_size.length()
		$RenderArea/CollisionShape2D.scale = Vector2.ONE / camera_zoom
		$RenderArea/CollisionShape2D.global_rotation = 0
		
		if module_addition_areas.size() > 0:
			var area = module_addition_areas[0]
			var needed = area.get_parent().get_parent().can_add_module(area)
			if needed.size() > 0:
				ui.show_module_addition_button(area, needed)
		else:
			ui.hide_module_addition_button()
		
		if destroyable_rocks.size() > 0:
			ui.show_destroy_rock_button(destroyable_rocks[0])
		else:
			ui.hide_destroy_rock_button()
		
		if !is_in_vehicle:
			if vehicles.size() == 0:
				ui.hide_drive_vehicle_button()
			else:
				ui.show_drive_vehicle_button(vehicles[0])
			$CollisionPolygon2D.disabled = false
			$Camera2D.ignore_rotation = true
			$RenderArea.global_rotation = 0
			camera_zoom = initial_camera_zoom
		else:
			$CollisionPolygon2D.disabled = true
			$WalkingParticleEmitter.emitting = false
			$Camera2D.ignore_rotation = false
			$RenderArea.global_rotation = rotation
			camera_zoom = initial_camera_zoom / 2
		
		if has_suit:
			$AnimatedSprite2D.play("suited")
			mass = 120
		else:
			$AnimatedSprite2D.play("default")
			mass = 80
			if suits.size() == 0:
				ui.hide_wear_suit_button()
			else:
				ui.show_wear_suit_button(suits[0])
			
		if get_parent().is_night:
			if has_suit and !is_in_vehicle and battery > 0:
				$PointLight2D.enabled = true
				battery_loss_rate = 0.25
			else:
				$PointLight2D.enabled = false
		else:
			$PointLight2D.enabled = false
			
		if in_oxygen_areas.size() > 0 or (vehicle != null and vehicle.is_in_group("rovers") and vehicle.in_habitations.size() > 0):
			if has_suit:
				oxygen_loss_rate = suit_oxygen_loss_rate
			else:
				if hab.oxygen_level > 5 and oxygen_level < 100:
					hab.oxygen_level -= hab_oxygen_loss_rate * delta
					oxygen_loss_rate = oxygen_gain_rate
				else:
					oxygen_loss_rate = self_oxygen_loss_rate
		else:
			if has_suit:
				oxygen_loss_rate = suit_oxygen_loss_rate
			else:
				oxygen_loss_rate = self_oxygen_loss_rate

		battery -= battery_loss_rate * delta

		if battery < 0:
			battery = 0
		elif battery > 100:
			battery = 100
		
		oxygen_level -= oxygen_loss_rate * delta
		
		if oxygen_level < 0:
			oxygen_level = 0
		elif oxygen_level > 100:
			oxygen_level = 100

func _integrate_forces(state):
#	if is_multiplayer_authority():
		if !is_in_vehicle:
			if !freeze_rotation:
				rotate_face_mouse()
			else:
				set_angular_velocity(0)
			wasd_movement()
		else:
			linear_velocity = Vector2.ZERO
			angular_velocity = 0

func rotate_face_mouse():
	set_angular_velocity((get_angle_to(get_global_mouse_position()) + PI / 2) * -((get_angle_to(get_global_mouse_position())) - PI) * turning_speed)
#	rotation = get_angle_to(get_global_mouse_position()) + PI / 2

func wasd_movement():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	apply_force(input_direction * mass * acceleration)
	
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
		
	var friction_force = -linear_velocity * mass * get_parent().gravity * friction_coefficient
	if input_direction.length() == 0:
		apply_force(friction_force)
		$WalkingParticleEmitter.emitting = false
	else:
		$WalkingParticleEmitter.emitting = true
	if in_habitations.size() > 0:
		$WalkingParticleEmitter.emitting = false

func _on_action_area_body_entered(body):
	if body.is_in_group("vehicles"):
		if !body.is_player_inside:
			vehicles.append(body)
	if body.is_in_group("suits"):
		suits.append(body)
	if body.is_in_group("rocks"):
		destroyable_rocks.append(body)

func _on_action_area_body_exited(body):
	if body.is_in_group("vehicles") or body.is_in_group("suits"):
		vehicles.erase(body)
	if body.is_in_group("suits"):
		suits.erase(body)
	if body.is_in_group("rocks"):
		destroyable_rocks.erase(body)
		
func _on_action_area_area_entered(area):
	if area.is_in_group("module_addition_areas"):
		module_addition_areas.append(area)

func _on_action_area_area_exited(area):
	if area.is_in_group("module_addition_areas"):
		module_addition_areas.erase(area)
		
func _on_render_area_body_entered(body):
	if body.is_in_group("rocks") or body.is_in_group("vehicles") or body.is_in_group("habs") or body.is_in_group("suits"):
		body.players_seeing.append(self)

func _on_render_area_body_exited(body):
	if body.is_in_group("rocks") or body.is_in_group("vehicles") or body.is_in_group("habs") or body.is_in_group("suits"):
		body.players_seeing.erase(self)

func _on_render_area_area_entered(area):
	if area.is_in_group("habs"):
		area.players_seeing.append(self)

func _on_render_area_area_exited(area):
	if area.is_in_group("habs"):
		area.players_seeing.erase(self)

func destroy_self():
	queue_free()
