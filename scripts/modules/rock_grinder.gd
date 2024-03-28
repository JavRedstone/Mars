extends StaticBody2D

var players_seeing = []

var grid_taken = Vector2.ZERO
var grid_orientation = null

var battery_loss_rate = 0
var oxygen_loss_rate = 0

var rock_queue = []

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()
		
	if get_parent().battery > 0:
		$AnimatedSprite2D.play("default")
		battery_loss_rate = 0.15
		for rock in rock_queue:
			for player in get_parent().get_parent().players:
				if player.team == get_parent().team:
					if rock.original_scale < Vector2.ONE * 0.1:
						player.inventory[0] += 1
						player.inventory[2] += 1
					else:
						player.inventory[0] += 4
						player.inventory[1] += 2
						player.inventory[2] += 2
			rock.destroy_self()
	else:
		$AnimatedSprite2D.play("dead")
		battery_loss_rate = 0

func _on_rock_grinder_area_body_entered(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.append(self)
	if body.is_in_group("rocks"):
		rock_queue.append(body)

func _on_rock_grinder_area_body_exited(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.erase(self)
	if body.is_in_group("rocks"):
		rock_queue.erase(body)
