extends Area2D

var players_seeing = []

var grid_taken = Vector2.ZERO
var grid_orientation = null

var battery_loss_rate = 0
var oxygen_loss_rate = 0

var suits_supplying = []

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()
	
	battery_loss_rate = 0
	oxygen_loss_rate = 0
	
	for suit in suits_supplying:
		if get_parent().battery > 0:
			suit.charging = true
		else:
			suit.charging = false
		if get_parent().oxygen_level > 0:
			suit.oxygen_replenishing = true
		else:
			suit.oxygen_replenishing = false
		if suit.charging and suit.battery < 100:
			battery_loss_rate += 0.5 # its less because its a percentage
		else:
			suit.charging = false
		if suit.oxygen_replenishing and suit.oxygen_level < 100:
			oxygen_loss_rate += 0.25
		else:
			suit.oxygen_replenishing = false
	
	if get_parent().battery > 0:
		if suits_supplying.size() > 0:
			$AnimatedSprite2D.play("charging")
		else:
			$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("default")

func _on_body_entered(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.append(self)
	if body.is_in_group("suits"):
		suits_supplying.append(body)

func _on_body_exited(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.erase(self)
	if body.is_in_group("suits"):
		suits_supplying.erase(body)
