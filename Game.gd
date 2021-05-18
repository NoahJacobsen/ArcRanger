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
export (int) var player_acceleration = 75
export (int) var player_stun_deceleration = 400
export (int) var player_max_speed = 900
export (int) var player_min_speed = 150
export (float) var stun_wait = .7
export (float) var timer_static_min = 1.5
export (float) var timer_static_max = 2.5
export (float) var timer_rocks_min = 0.7
export (float) var timer_rocks_max = 1.2
export (float) var timer_divet_min = 2.0
export (float) var timer_divet_max = 4.0
export(int) var static_value = 10

onready var ground_tile = preload("res://Objects/Tiles/Ground.tscn")
onready var static_field = preload("res://Objects/Tiles/Static.tscn")
onready var rocks_tile = preload("res://Objects/Tiles/Rocks.tscn")
onready var spawn_loc = $YSort/Moving/SpawnPath/SpawnLocation
onready var gui = $YSort/Moving/GUI

var screen_size
var game_active = false
var ground_gen_pos = Vector2()
var player_speed = 150
var stunned = false

var health = 3
var points = 0

func _ready():
	randomize()
	screen_size = $YSort/Moving/Camera2D.get_viewport_rect().size
	$YSort/Moving/Player.position.y = y_start
	generate_ground()
	start_game()
	
func _process(delta):
	if game_active:
		if stunned:
			if (player_speed > player_min_speed):
				player_speed -= player_stun_deceleration * delta
		else:
			if (player_speed < player_max_speed):
				player_speed += player_acceleration * delta
		var velocity = Vector2(player_speed, 0)
		$YSort/Moving.position += velocity * delta
		move_spawn_path($YSort/Moving.position)
		gui.update_speed(player_speed)

func stun():
	$StunTimer.wait_time = stun_wait
	$StunTimer.start()
	print("STUNNED!")
	stunned = true

func _on_StunTimer_timeout():
	print("Stun over")
	stunned = false


func start_game():
	game_active = true
	set_timer_duration($StaticTimer, timer_static_min, timer_static_max)
	set_timer_duration($RocksTimer, timer_rocks_min, timer_rocks_max)
	points = 0
	health = 3
	gui.update_points(points)
	gui.update_health(health)

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

func spawn_object(instance, timer, timer_min, timer_max):
	spawn_loc.offset = randi()
	#var field = static_field.instance()
	instance.position = spawn_loc.position
	$YSort.add_child(instance)
	set_timer_duration(timer, timer_min, timer_max)

func set_timer_duration(timer, min_time, max_time):
	var duration = rand_range(min_time, max_time)
	timer.wait_time = duration
	timer.start()

func _on_StaticTimer_timeout():
	spawn_object(static_field.instance(), $StaticTimer, timer_static_min, timer_static_max)
	
func _on_RocksTimer_timeout():
	spawn_object(rocks_tile.instance(), $RocksTimer, timer_rocks_min, timer_rocks_max)

### Collision functions

func collect_static():
	points += static_value
	gui.update_points(points)
	
func hit_rocks():
	health -= 1
	gui.update_health(health)
	stun()




