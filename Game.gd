extends Node

const GROUND_SIZE = Vector2(5, 2)
const GROUND_Y_CLAMP = 125
const GROUND_TILE_SIZE = 512
const SPAWN_MARGIN = 10
const SPAWN_OUT_BOUND = 128

export (int) var x_clamp = 125
export (int) var y_clamp = 150
export (int) var y_clamp_margin = 25
export (int) var y_start = 300
export (int) var player_acceleration = 50
export (int) var player_max_speed = 700
export (float) var timer_static_min = 5.0
export (float) var timer_static_max = 10.0
export (float) var timer_rock_min = 3.0
export (float) var timer_rock_max = 7.0
export (float) var timer_divet_min = 4.0
export (float) var timer_divet_max = 10.0

onready var ground_tile = preload("res://Objects/Tiles/Ground.tscn")
onready var static_field = preload("res://Objects/Tiles/Static.tscn")
onready var spawn_loc = $YSort/Moving/SpawnPath/SpawnLocation

var screen_size
var game_active = false
var ground_gen_pos = Vector2()
var player_speed = 100

func _ready():
	randomize()
	screen_size = $YSort/Moving/Camera2D.get_viewport_rect().size
	$YSort/Moving/Player.position.y = y_start
	generate_ground()
	start_game()
	
func _process(delta):
	if game_active:
		if (player_speed < player_max_speed):
			player_speed += player_acceleration * delta
		var velocity = Vector2(player_speed, 0)
		$YSort/Moving.position += velocity * delta
		move_spawn_path($YSort/Moving.position)
		$YSort/Moving/GUI.update_speed(player_speed)

func start_game():
	game_active = true
	set_timer_duration($StaticTimer, timer_static_min, timer_static_max)

func move_spawn_path(pos):
	var curve = $YSort/Moving/SpawnPath.get_curve()
	var point_pos = Vector2()
	pos.x += screen_size.x + SPAWN_OUT_BOUND
	pos.y = y_clamp + SPAWN_MARGIN
	curve.set_point_position(0, pos)
	pos.y = screen_size.y - y_clamp_margin - SPAWN_MARGIN
	curve.set_point_position(1, pos)
	$YSort/Moving/SpawnPath.set_curve(curve)

func generate_ground():
	ground_gen_pos.y = GROUND_Y_CLAMP
	if not game_active:
		for y in GROUND_SIZE.y:
			for x in GROUND_SIZE.x:
				var tile = ground_tile.instance()
				var ret = tile.connect("screen_exited", self, "generate_ground")
				tile.position = ground_gen_pos
				ground_gen_pos.x += GROUND_TILE_SIZE
				$Tiles.add_child(tile)
			ground_gen_pos.x = 0
			ground_gen_pos.y += GROUND_TILE_SIZE
	else:
		for y in GROUND_SIZE.y:
			var tile = ground_tile.instance()
			var ret = tile.connect("screen_exited", self, "generate_ground")
			tile.position = ground_gen_pos
			ground_gen_pos.y += GROUND_TILE_SIZE
			$Tiles.add_child(tile)
		ground_gen_pos.x += GROUND_TILE_SIZE

func set_timer_duration(timer, min_time, max_time):
	var duration = rand_range(min_time, max_time)
	#print("Set ", timer.name, " duration to ", duration)
	timer.wait_time = duration
	timer.start()

func _on_StaticTimer_timeout():
	#print("Spawning static...")
	spawn_loc.offset = randi()
	var field = static_field.instance()
	field.position = spawn_loc.position
	$YSort.add_child(field)
	set_timer_duration($StaticTimer, timer_static_min, timer_static_max)
