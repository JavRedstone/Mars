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
	
	battery_loss_rate = 0
	if get_parent().battery > 0: # hab is parent, main is hab's parent
		battery_loss_rate = 0.1 # use power always because its an airlock
		if get_parent().get_parent().is_night:
			$PointLight2D.enabled = true
			battery_loss_rate += 0.1
		else:
			$PointLight2D.enabled = false
	else:
		$PointLight2D.enabled = false
		battery_loss_rate = 0
		
func _on_airlock_area_body_entered(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.append(self)
		body.in_oxygen_areas.append(self)

func _on_airlock_area_body_exited(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.erase(self)
		body.in_oxygen_areas.erase(self)
