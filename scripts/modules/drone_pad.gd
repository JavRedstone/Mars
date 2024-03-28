extends Area2D

var players_seeing = []

var grid_taken = Vector2.ZERO
var grid_orientation = null

var battery_loss_rate = 0
var oxygen_loss_rate = 0

var drones_charging = []

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()
		
	if get_parent().get_parent().is_night and get_parent().battery > 0:
		battery_loss_rate = 0.15
	else:
		battery_loss_rate = 0

	for drone in drones_charging:
		if get_parent().battery > 0:
			drone.charging = true
		else:
			drone.charging = false
		if drone.charging and drone.battery < 100:
			battery_loss_rate += 0.5 # its less because its a percentage
		else:
			drone.charging = false
	
	if get_parent().battery > 0:
		if drones_charging.size() > 0:
			$AnimatedSprite2D.play("charging")
			if get_parent().get_parent().is_night:
				$NormalLight.enabled = false
				$ChargingLight.enabled = true
		else:
			$AnimatedSprite2D.play("default")
			if get_parent().get_parent().is_night:
				$NormalLight.enabled = true
				$ChargingLight.enabled = false
	else:
		$AnimatedSprite2D.play("default")
		$NormalLight.enabled = false
		$ChargingLight.enabled = false
	if !get_parent().get_parent().is_night:
		$NormalLight.enabled = false
		$ChargingLight.enabled = false

func _on_body_entered(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.append(self)
		if body.is_in_group("drones"):
			drones_charging.append(body)

func _on_body_exited(body):
	if body.is_in_group("drones") or body.is_in_group("vehicles"):
		body.in_habitations.erase(self)
		if body.is_in_group("drones"):
			drones_charging.erase(body)
			body.charging = false
