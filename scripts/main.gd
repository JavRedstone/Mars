extends Node2D

# mutliplayer stuff
#var peer = ENetMultiplayerPeer.new()
#var port = 4201
#var ip = "127.0.0.1"

# world stuff
var gravity = 3.71
var spawn_range = 25000
var player_spawn_range = 15000

# rock stuff
var asteroid_noise
var rock_spawn_dist = 300
var rock_noise_threshold = 0.325
var rock_noise_scale_multiplier = 0.6
var rock_noise_mass_multiplier = 1000
var rock_pos_change_max = 150
var rock_factor_change_min = 0.25
var rocks_destroyed = []

# scene stuff
@export var player_scene: PackedScene
var players = []
@export var rock_scene: PackedScene
var rocks = []
@export var rover_scene: PackedScene
var rovers = []
@export var drone_scene: PackedScene
var drones = []
@export var hab_scene: PackedScene
var habs = []

var max_time = 60 * 60 * 24.6
var time = max_time / 4 # start at day
var time_step = 4 # 6.15 minutes each full cycle (period)
var max_sun_energy = 0.75
var night_threshold = max_time / 2

var is_night = false

func _ready():
	spawn_player()
#	_spawn_player()
	$Map.texture.noise.seed = randi()
	spawn_objects()

#func setup_server():
#	multiplayer.multiplayer_peer.close()
#	peer.create_server(port)
#	multiplayer.multiplayer_peer = peer
#	multiplayer.peer_connected.connect(_spawn_player)
#	_spawn_player()
#	$Map.texture.noise.seed = randi()
#	spawn_objects()

#func _spawn_player(id = 1):
#	var player = player_scene.instantiate()
#	player.name = str(id)
#	player.position = Vector2(randf_range(-player_spawn_range, player_spawn_range), randf_range(-player_spawn_range, player_spawn_range))
#	players.append(player)
#	add_child(player)
	
func spawn_player():
	var player = player_scene.instantiate()
	player.position = Vector2(randf_range(-player_spawn_range, player_spawn_range), randf_range(-player_spawn_range, player_spawn_range))
	players.append(player)
	add_child(player)
	
func spawn_objects():
	spawn_rocks()
	
func spawn_rocks():
	# Instantiate
	asteroid_noise = FastNoiseLite.new()

	# Configure
	asteroid_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	asteroid_noise.seed = randi()
	asteroid_noise.frequency = 0.001
	for y in range(-spawn_range, spawn_range, rock_spawn_dist):
		for x in range(-spawn_range, spawn_range, rock_spawn_dist):
			spawn_rock(x, y)

func spawn_rock(x, y):
	var noise2D = abs(asteroid_noise.get_noise_2d(x + 1, y + 1))
	if noise2D > rock_noise_threshold:
		var rock = rock_scene.instantiate()
		rock.original_position = Vector2(x, y)
		var neg_pos = round(randf())
		if neg_pos == 0:
			neg_pos = -1
		var rand_pos = randf_range(0, rock_pos_change_max)
		var random_pos = rand_pos * neg_pos
		rock.position = Vector2(x + random_pos, y + random_pos)
		var random_factor = randf_range(rock_factor_change_min, 1)
		rock.set_children_scale(Vector2.ONE * noise2D * rock_noise_scale_multiplier * random_factor)
		rock.mass = noise2D * rock_noise_mass_multiplier * random_factor
		rocks.append(rock)
		add_child(rock)

func _physics_process(delta):
	var destroyed_rocks = []
	for rock_pos in rocks_destroyed: # timing
		rock_pos[1] -= delta
		if rock_pos[1] <= 0:
			destroyed_rocks.append(rock_pos)
	for rock_pos in destroyed_rocks: # creation
		spawn_rock(rock_pos[0].x, rock_pos[0].y)
		rocks_destroyed.erase(rock_pos)
	destroyed_rocks.clear()
	
	if time < 60 * 60 * 24:
		time += time_step
	else:
		time = 0
	
	var brightness = sin(float(1)/float(60*60*12.3) * PI * time) * 0.45 + 0.55
	$Sun.energy = brightness
	
	if time > night_threshold: # includes sunset and sunrise since its sin
		is_night = true
	else:
		is_night = false

#func _on_join_button_pressed():
#	peer.create_client(ip, port)
#	multiplayer.multiplayer_peer = peer
#
#func _on_host_button_pressed():
#	setup_server()
