extends Area2D

var players_seeing = []

var grid_taken = Vector2.ZERO
var grid_orientation = null

var battery_loss_rate = 0
var oxygen_loss_rate = 0.05

var max_grow_time = 180 # 3 minutes
var max_kill_time = 15 # 15 seconds
var grow_time = 0
var kill_time = 0
var state = "empty"

func _ready():
	hide()
	
	rotation = randf() * 2 * PI

func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()
	if get_parent().oxygen_level > 0:
		kill_time = 0
		if state == "empty" or state == "wilted":
			if grow_time >= max_grow_time:
				grow_time = 0
				state = "full"
			else:
				grow_time += delta
	else:
		grow_time = 0
		if state == "full" or state == "wilted":
			if kill_time >= max_kill_time:
				kill_time = 0
				if state == "full":
					state = "wilted"
				else:
					state = "empty"
			else:
				kill_time += delta
	$AnimatedSprite2D.play(state)
	
func _on_body_entered(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.append(self)

func _on_body_exited(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.erase(self)
