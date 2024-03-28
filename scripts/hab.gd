extends Node2D

@export var habitation_module_scene: PackedScene

@export var airlock_scene: PackedScene
@export var rover_dock_scene: PackedScene
@export var oxygenator_scene: PackedScene

@export var solar_panel_scene: PackedScene
@export var rock_grinder_scene: PackedScene
@export var RTG_scene: PackedScene
@export var drone_pad_scene: PackedScene

@export var farm_scene: PackedScene
@export var suit_supplier_scene: PackedScene

@export var rover_scene: PackedScene

var team = 0
var modules = []
var battery = 100
var oxygen_level = 0

var grid_spacing = 720
var habitation_module_spacing = 720
var side_module_spacing = 415
var diagonal_module_spacing = 360 

var original_module
var max_distance = 3

func create_hab(p):
	var habitation_module = habitation_module_scene.instantiate()
	habitation_module.position = p
	habitation_module.grid_taken = habitation_module.position
	modules.append(habitation_module)
	original_module = habitation_module
	add_child(habitation_module)
	get_parent().habs.append(self)
	
	var rover = rover_scene.instantiate()
	rover.position = p * scale.x # reset this scale to be 1 not 1.25
	rover.team = team
	get_parent().rovers.append(rover)
	get_parent().add_child(rover)

func _physics_process(delta):
	for module in modules:
		battery -= module.battery_loss_rate * delta
		oxygen_level -= module.oxygen_loss_rate * delta
	if battery < 0:
		battery = 0
	elif battery > 100:
		battery = 100
	
	if oxygen_level < 0:
		oxygen_level = 0
	elif oxygen_level > 100:
		oxygen_level = 100

func add_module(id, module, addition_area):
	if id == 0:
		var habitation_module = habitation_module_scene.instantiate()
		if addition_area == "TopAdditionArea":
			habitation_module.position = module.position + Vector2.UP * habitation_module_spacing
			habitation_module.grid_taken = habitation_module.position
		elif addition_area == "RightAdditionArea":
			habitation_module.position = module.position + Vector2.RIGHT * habitation_module_spacing
			habitation_module.grid_taken = habitation_module.position
		elif addition_area == "BottomAdditionArea":
			habitation_module.position = module.position + Vector2.DOWN * habitation_module_spacing
			habitation_module.grid_taken = habitation_module.position
		else:
			habitation_module.position = module.position + Vector2.LEFT * habitation_module_spacing
			habitation_module.grid_taken = habitation_module.position
		modules.append(habitation_module)
		add_child(habitation_module)
	else:
		var side_module = null
		if id == 1:
			side_module = airlock_scene.instantiate()
		elif id == 2:
			side_module = rover_dock_scene.instantiate()
		elif id == 3:
			side_module = oxygenator_scene.instantiate()
		if addition_area == "TopAdditionArea":
			side_module.position = module.position + Vector2.UP * side_module_spacing
			side_module.rotation = -deg_to_rad(90)
			side_module.grid_taken = module.grid_taken + Vector2.UP * grid_spacing
			side_module.grid_orientation = Vector2.UP
		elif addition_area == "RightAdditionArea":
			side_module.position = module.position + Vector2.RIGHT * side_module_spacing
			side_module.rotation = deg_to_rad(0)
			side_module.grid_taken = module.grid_taken + Vector2.RIGHT * grid_spacing
			side_module.grid_orientation = Vector2.RIGHT
		elif addition_area == "BottomAdditionArea":
			side_module.position = module.position + Vector2.DOWN * side_module_spacing
			side_module.rotation = deg_to_rad(90)
			side_module.grid_taken = module.grid_taken + Vector2.DOWN * grid_spacing
			side_module.grid_orientation = Vector2.DOWN
		elif addition_area == "LeftAdditionArea":
			side_module.position = module.position + Vector2.LEFT * side_module_spacing
			side_module.rotation = deg_to_rad(180)
			side_module.grid_taken = module.grid_taken + Vector2.LEFT * grid_spacing
			side_module.grid_orientation = Vector2.LEFT
		if side_module != null:
			modules.append(side_module)
			add_child(side_module)
			
		var diagonal_module = null
		if id == 4:
			diagonal_module = solar_panel_scene.instantiate()
		elif id == 5:
			diagonal_module = rock_grinder_scene.instantiate()
		elif id == 6:
			diagonal_module = RTG_scene.instantiate()
		elif id == 7:
			diagonal_module = drone_pad_scene.instantiate()
		if addition_area == "LeftTopAdditionArea":
			diagonal_module.position = module.position + (Vector2.LEFT + Vector2.UP) * diagonal_module_spacing
			diagonal_module.grid_taken = module.grid_taken + (Vector2.LEFT + Vector2.UP) * grid_spacing / 2
		elif addition_area == "RightTopAdditionArea":
			diagonal_module.position = module.position + (Vector2.RIGHT + Vector2.UP) * diagonal_module_spacing
			diagonal_module.grid_taken = module.grid_taken + (Vector2.RIGHT + Vector2.UP) * grid_spacing / 2
		elif addition_area == "LeftBottomAdditionArea":
			diagonal_module.position = module.position + (Vector2.LEFT + Vector2.DOWN) * diagonal_module_spacing
			diagonal_module.grid_taken = module.grid_taken + (Vector2.LEFT + Vector2.DOWN) * grid_spacing / 2
		elif addition_area == "RightBottomAdditionArea":
			diagonal_module.position = module.position + (Vector2.RIGHT + Vector2.DOWN) * diagonal_module_spacing
			diagonal_module.grid_taken = module.grid_taken + (Vector2.RIGHT + Vector2.DOWN) * grid_spacing / 2
		if diagonal_module != null:
			modules.append(diagonal_module)
			add_child(diagonal_module)
			
		var center_module = null
		if id == 8:
			center_module = farm_scene.instantiate()
		elif id == 9:
			center_module = suit_supplier_scene.instantiate()
		if addition_area == "CenterAdditionArea":
			center_module.position = module.position
			center_module.grid_taken = module.grid_taken + Vector2.ONE # offset
		if center_module != null:
			modules.append(center_module)
			add_child(center_module)
		
func get_modules_in_grid(grid_taken):
	var modules_in_grid = []
	for module in modules:
		if module.grid_taken == grid_taken:
			modules_in_grid.append(module)
	return modules_in_grid
	
func can_add_module(area):
	var m = area.get_parent()
	
	var grid_taken = Vector2.ZERO
	var grid_orientation = Vector2.UP
	
	var diagonal = false
	var center = false
	
	if area.name == "TopAdditionArea":
		grid_taken = m.grid_taken + Vector2.UP * grid_spacing
		grid_orientation = Vector2.UP
	elif area.name == "RightAdditionArea":
		grid_taken = m.grid_taken + Vector2.RIGHT * grid_spacing
		grid_orientation = Vector2.RIGHT
	elif area.name == "BottomAdditionArea":
		grid_taken = m.grid_taken + Vector2.DOWN * grid_spacing
		grid_orientation = Vector2.DOWN
	elif area.name == "LeftAdditionArea":
		grid_taken = m.grid_taken + Vector2.LEFT * grid_spacing
		grid_orientation = Vector2.LEFT
	elif area.name == "LeftTopAdditionArea":
		grid_taken = m.grid_taken + (Vector2.LEFT + Vector2.UP) * grid_spacing / 2
		diagonal = true
	elif area.name == "RightTopAdditionArea":
		grid_taken = m.grid_taken + (Vector2.RIGHT + Vector2.UP) * grid_spacing / 2
		diagonal = true
	elif area.name == "LeftBottomAdditionArea":
		grid_taken = m.grid_taken + (Vector2.LEFT + Vector2.DOWN) * grid_spacing / 2
		diagonal = true
	elif area.name == "RightBottomAdditionArea":
		grid_taken = m.grid_taken + (Vector2.RIGHT + Vector2.DOWN) * grid_spacing / 2
		diagonal = true
	elif area.name == "CenterAdditionArea":
		grid_taken = m.grid_taken + Vector2.ONE # we have to offset it compared to the normal modules
		center = true
	
	if abs(grid_taken.x - original_module.grid_taken.x) > max_distance * grid_spacing or abs(grid_taken.y - original_module.grid_taken.y) > max_distance * grid_spacing:
		return []
	
	var modules_in_grid = get_modules_in_grid(grid_taken)
	if modules_in_grid.size() == 0:
		if diagonal:
			return [4, 5, 6, 7]
		elif center:
			return [8, 9]
		else:
			return [0, 1, 2, 3]
	else:
		for module in modules_in_grid:
			if module.grid_orientation == null:
				return [] #both can't be placed
			else:
				if module.grid_orientation == grid_orientation:
					return [] #only airlock and rover dock
		return [1, 2, 3] # if they didnt find an airlock or rover dock with the same orientation
	return []
