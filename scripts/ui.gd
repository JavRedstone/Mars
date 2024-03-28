extends Node2D

@export var hab_scene: PackedScene
@export var suit_scene: PackedScene

var inventory_labels = ["Martian Soil", "Martian Rocks", "Martian Metal"]

var actions_vehicle
var actions_suit
var actions_rock

var actions_module_addition
var actions_module_addition_labels = [
	"Habitation Module",
	
	"Airlock",
	"Rover Dock",
	"Oxygenator",
	
	"Solar Panel",
	"Rock Grinder",
	"Radioisotope Thermoelectric Generator",
	"Drone Pad",
	
	"Farm",
	"Suit Supplier"
]
var actions_module_addition_costs = [
	[150, 75, 50], # soil, rock, metal
	
	[5, 2, 0],
	[10, 5, 2],
	[15, 5, 2],
	
	[10, 5, 0],
	[10, 5, 0],
	[500, 250, 250],
	[25, 10, 0],
	
	[20, 15, 0],
	[10, 5, 2]
]

func show_drive_vehicle_button(vehicle):
	$Actions/Vehicle/DriveVehicleButton.show()
	actions_vehicle = vehicle
func hide_drive_vehicle_button():
	$Actions/Vehicle/DriveVehicleButton.hide()

func show_exit_vehicle_button():
	$Actions/Vehicle/ExitVehicleButton.show()
func hide_exit_vehicle_button():
	$Actions/Vehicle/ExitVehicleButton.hide()
	
func show_wear_suit_button(suit):
	$Actions/Suit/WearSuitButton.show()
	actions_suit = suit
func hide_wear_suit_button():
	$Actions/Suit/WearSuitButton.hide()
func show_take_off_suit_button():
	$Actions/Suit/TakeOffSuitButton.show()
func hide_take_off_suit_button():
	$Actions/Suit/TakeOffSuitButton.hide()
	
func show_destroy_rock_button(rock):
	$Actions/DestroyRockButton.show()
	actions_rock = rock
func hide_destroy_rock_button():
	$Actions/DestroyRockButton.hide()

func show_module_addition_button(module_adding, needed):
	$Actions/ModuleAdditionButton.get_popup().clear()
	$Actions/ModuleAdditionButton.show()
	actions_module_addition = module_adding
	var idx = 0
	for id in needed:
		$Actions/ModuleAdditionButton.get_popup().add_item(actions_module_addition_labels[id] + ": Soil - " + str(actions_module_addition_costs[id][0]) + " | Rock - " + str(actions_module_addition_costs[id][1]) + " | Metal - " + str(actions_module_addition_costs[id][2]), id)
		for slot in range(get_parent().inventory.size()):
			if actions_module_addition_costs[id][slot] > get_parent().inventory[slot]:
				$Actions/ModuleAdditionButton.get_popup().set_item_disabled(idx, true)
		idx += 1
	$Actions/ModuleAdditionButton.get_popup().add_item("Cancel", 1000)
func hide_module_addition_button():
	$Actions/ModuleAdditionButton.hide()
	get_parent().freeze_rotation = false
	
func show_starter_addition_button():
	$Actions/StarterAdditionButton.show()
func hide_starter_addition_button():
	$Actions/StarterAdditionButton.hide()

func _ready():
	$Actions/ModuleAdditionButton.get_popup().id_pressed.connect(_on_item_pressed)

func _physics_process(delta):
	$Info/Player.show()
	$Info/Player/BatteryProgressBar.value = get_parent().battery
	$Info/Player/OxygenLevelProgressBar.value = get_parent().oxygen_level
		
	if get_parent().hab != null:
		$Info/Hab.show()
		$Info/Hab/BatteryProgressBar.value = get_parent().hab.battery
		$Info/Hab/OxygenLevelProgressBar.value = get_parent().hab.oxygen_level
	else:
		$Info/Hab.hide()
	
	if get_parent().vehicle != null:
		$Info/Vehicle.show()
		$Info/Vehicle/BatteryProgressBar.value = get_parent().vehicle.battery
	else:
		$Info/Vehicle.hide()
		
	$Inventory/InventoryList.clear()
	$Inventory/InventoryList.add_item("Inventory", null, false)
	var idx = 1
	for amount in get_parent().inventory:
		$Inventory/InventoryList.add_item(inventory_labels[idx - 1] + " | " + str(amount), null, false)
		$Inventory/InventoryList.set_item_disabled(idx, true)
		idx += 1
	
	if get_parent().hab == null and (abs(get_parent().position.x - 0) < 18000 or abs(get_parent().position.y - 0) < 18000):
		show_starter_addition_button()
	else:
		hide_starter_addition_button()

func _on_drive_vehicle_button_pressed():
	if !actions_vehicle.is_player_inside:
		actions_vehicle.get_in_vehicle(get_parent())
		hide_drive_vehicle_button()
		show_exit_vehicle_button()

func _on_exit_vehicle_button_pressed():
	if actions_vehicle.is_player_inside:
		var success = actions_vehicle.get_out_vehicle(get_parent())
		if success:
			get_parent().is_in_vehicle = false
			get_parent().vehicle = null
			actions_vehicle = null
		hide_exit_vehicle_button()

func _on_wear_suit_button_pressed():
	if is_instance_valid(actions_suit):
		get_parent().oxygen_level = actions_suit.oxygen_level
		get_parent().battery = actions_suit.battery
		get_parent().has_suit = true
		get_parent().suit = actions_suit
		actions_suit.destroy_self()
		show_take_off_suit_button()
	hide_wear_suit_button()

func _on_take_off_suit_button_pressed():
	if get_parent().has_suit:
		get_parent().has_suit = false
		var suit = suit_scene.instantiate()
		suit.position = get_parent().position + Vector2(0, -75).rotated(get_parent().rotation)
		suit.oxygen_level = get_parent().oxygen_level
		suit.battery = get_parent().battery
		if get_parent().oxygen_level > 0:
			suit.oxygen_level -= 1
			get_parent().oxygen_level = 100
		get_parent().battery = 0
		get_parent().get_parent().add_child(suit)
	hide_take_off_suit_button()

func _on_module_addition_button_pressed():
	get_parent().freeze_rotation = true
	
func _on_item_pressed(id):
	if id != 1000: # cancel
		for slot in range(get_parent().inventory.size()):
			get_parent().inventory[slot] -= actions_module_addition_costs[id][slot]
		
		actions_module_addition.get_parent().get_parent().add_module(id, actions_module_addition.get_parent(), actions_module_addition.name)
	hide_module_addition_button()

func _on_starter_addition_button_pressed():
	var hab = hab_scene.instantiate()
	var pos = snap_to_nearest_720(get_parent().position, hab)
	get_parent().hab = hab
	get_parent().get_parent().add_child(hab)
	hab.create_hab(pos);
	hide_starter_addition_button()

func snap_to_nearest_720(p, hab):
	var pos = Vector2.ZERO
	pos.x = 720 / hab.scale.x * round(p.x / 720) # need to test hab scales, since hab modules are based off of this scale as they are hab children
	pos.y = 720 / hab.scale.x * round(p.y / 720)
	return pos

func _on_destroy_rock_button_pressed():
	if actions_rock != null and is_instance_valid(actions_rock):
		if actions_rock.original_scale < Vector2.ONE * 0.1:
			get_parent().inventory[0] += 1
		else:
			get_parent().inventory[0] += 2
			get_parent().inventory[1] += 1
		actions_rock.destroy_self()
