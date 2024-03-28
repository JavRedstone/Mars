extends StaticBody2D

var players_seeing = []

var grid_taken = Vector2.ZERO
var grid_orientation = null

var battery_loss_rate = -5
var oxygen_loss_rate = 0

func _ready():
	hide()
	$PointLight2D.enabled = true
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()

func _on_rtg_area_body_entered(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.append(self)

func _on_rtg_area_body_exited(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.erase(self)
