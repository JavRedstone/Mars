extends StaticBody2D

var players_seeing = []

var grid_taken = Vector2.ZERO
var grid_orientation = null

var battery_loss_rate = 0
var hab_port_oxygen_loss_rate = 5
var oxygen_loss_rate = 0

func _ready():
	hide()
	
func _physics_process(delta):
	if players_seeing.size() > 0:
		show()
	else:
		hide()

	if get_parent().get_parent().is_night and get_parent().battery > 0:
		$PointLight2D.enabled = true
		battery_loss_rate = 0.5
	else:
		$PointLight2D.enabled = false
		battery_loss_rate = 0
	
	do_air_testing()

func do_air_testing():
	oxygen_loss_rate = 0
	
	var top_modules = get_parent().get_modules_in_grid(grid_taken + Vector2.UP * get_parent().grid_spacing)
	var right_modules = get_parent().get_modules_in_grid(grid_taken + Vector2.RIGHT * get_parent().grid_spacing)
	var bottom_modules = get_parent().get_modules_in_grid(grid_taken + Vector2.DOWN * get_parent().grid_spacing)
	var left_modules = get_parent().get_modules_in_grid(grid_taken + Vector2.LEFT * get_parent().grid_spacing)
	
	# do oxygenator tests
	do_module_testing(top_modules, Vector2.UP)
	do_module_testing(right_modules, Vector2.RIGHT)
	do_module_testing(bottom_modules, Vector2.DOWN)
	do_module_testing(left_modules, Vector2.LEFT)
	
	if !do_module_testing(top_modules, Vector2.UP) and get_parent().oxygen_level > 0:
		oxygen_loss_rate += hab_port_oxygen_loss_rate
		$TopAirParticleEmitter.emitting = true
	else: $TopAirParticleEmitter.emitting = false
	
	if !do_module_testing(right_modules, Vector2.RIGHT) and get_parent().oxygen_level > 0:
		oxygen_loss_rate += hab_port_oxygen_loss_rate
		$RightAirParticleEmitter.emitting = true
	else: $RightAirParticleEmitter.emitting = false
	
	if !do_module_testing(bottom_modules, Vector2.DOWN) and get_parent().oxygen_level > 0:
		oxygen_loss_rate += hab_port_oxygen_loss_rate
		$BottomAirParticleEmitter.emitting = true
	else: $BottomAirParticleEmitter.emitting = false
	
	if !do_module_testing(left_modules, Vector2.LEFT) and get_parent().oxygen_level > 0:
		oxygen_loss_rate += hab_port_oxygen_loss_rate
		$LeftAirParticleEmitter.emitting = true
	else: $LeftAirParticleEmitter.emitting = false
	
func do_module_testing(modules, orientation):
	for module in modules:
		if module != null:
			if module.grid_orientation == null: return true
			if module.grid_orientation == orientation:
				return true
		else: return false
	return false

func _on_habitation_module_area_body_entered(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.append(self)
		body.in_oxygen_areas.append(self)

func _on_habitation_module_area_body_exited(body):
	if body.is_in_group("players") or body.is_in_group("vehicles"):
		body.in_habitations.erase(self)
		body.in_oxygen_areas.erase(self)
