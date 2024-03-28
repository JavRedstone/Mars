extends StaticBody2D

var players_seeing = []

var grid_taken = Vector2.ZERO
var grid_orientation = Vector2.UP

var battery_loss_rate = 0
var oxygen_loss_rate = 0

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()
		
	if get_parent().battery > 0:
		$PointLight2D.enabled = true
		$AnimatedSprite2D.play("default")
		battery_loss_rate = 0.5
		oxygen_loss_rate = -2.5
	else:
		$PointLight2D.enabled = false
		$AnimatedSprite2D.play("dead")
		battery_loss_rate = 0
		oxygen_loss_rate = 0
