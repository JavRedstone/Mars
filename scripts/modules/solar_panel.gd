extends Area2D

var players_seeing = []

var grid_taken = Vector2.ZERO
var grid_orientation = null

var battery_loss_rate = 0
var oxygen_loss_rate = 0

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()

	if get_parent().get_parent().is_night: # hab is parent, main is hab's parent
		battery_loss_rate = 0
	else:
		battery_loss_rate = -1
		#TODO: need to add no battery due to dust storms later

func _on_body_entered(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.append(self)

func _on_body_exited(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.erase(self)
