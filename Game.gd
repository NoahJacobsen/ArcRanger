extends Node

const GROUND_SIZE = Vector2(5, 1)
const GROUND_Y_CLAMP = 125
const GROUND_TILE_SIZE = 512
const SPAWN_MARGIN = 10
const SPAWN_OUT_BOUND = 128

export (int) var x_clamp = 125
export (int) var y_clamp = 150
export (int) var y_clamp_margin = 25
export (int) var y_restriction_margin = 90
export (int) var y_start = 300
export (int) var player_acceleration = 75
export (int) var player_stun_deceleration = 500
export (int) var player_max_speed = 900
export (int) var player_min_speed = 150
export (float) var stun_wait = .7
export (float) var timer_static_min = 1.5
export (float) var timer_static_max = 2.5
export (float) var timer_rocks_min = 0.7
export (float) var timer_rocks_max = 1.2
export (float) var timer_divet_min = 3.0
export (float) var timer_divet_max = 7.5
export(int) var static_value = 10

onready var ground_tile = preload("res://Objects/Tiles/Ground.tscn")
onready var static_field = preload("res://Objects/Tiles/Static.tscn")
onready var rocks_tile = preload("res://Objects/Tiles/Rocks.tscn")
onready var divet_tile = preload("res://Objects/Tiles/Divet.tscn")
onready var spawn_loc = $YSort/Moving/SpawnPath/SpawnLocation
onready var gui = $GUILayer/GUI
onready var player = $YSort/Moving/Player

var screen_size
var game_active = false
var ground_gen_pos = Vector2()
var player_speed = 150
var stunned = false

var health = 3
var points = 0

func _ready():
	randomize()
	gui.show_message("ARC RANGER")
	gui.show_buttons()
	screen_size = $YSort/Moving/Camera2D.get_viewport_rect().size
	$YSort/Moving/Player.position.y = y_start
	generate_ground(null, true)


### Movement
func _process(delta):
	if stunned or not game_active:
		if (player_speed > player_min_speed):
			player_speed -= player_stun_deceleration * delta
	else:
		if (player_speed < player_max_speed):
			player_speed += player_acceleration * delta
	if player_speed > player_max_speed:
		player_speed = player_max_speed
	elif player_speed < player_min_speed:
		player_speed = player_min_speed
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
	player.stunned = false


### Game Mechanics
func start_game():
	if game_active:
		return
	game_active = true
	set_timer_duration($StaticTimer, timer_static_min, timer_static_max)
	set_timer_duration($RocksTimer, timer_rocks_min, timer_rocks_max)
	set_timer_duration($DivetTimer, timer_divet_min, timer_divet_max)
	points = 0
	health = 3
	gui.update_points(points)
	gui.update_health(health)
	gui.show_stats()
	gui.hide_message()
	gui.hide_buttons()
	gui.hide_credits()
	player.stunned = false
	
func game_over():
	print("GAME OVER")
	game_active = false
	gui.show_message("GAME OVER")
	gui.show_buttons()
	$StaticTimer.stop()
	$RocksTimer.stop()
	$DivetTimer.stop()
	
func quit_game():
	get_tree().quit()

func move_spawn_path(pos):
	var curve = $YSort/Moving/SpawnPath.get_curve()
	pos.x += screen_size.x + SPAWN_OUT_BOUND
	pos.y = y_clamp + SPAWN_MARGIN
	curve.set_point_position(0, pos)
	pos.y = screen_size.y - y_clamp_margin - SPAWN_MARGIN
	curve.set_point_position(1, pos)
	$YSort/Moving/SpawnPath.set_curve(curve)

func generate_ground(body, start=false):
	ground_gen_pos.y = GROUND_Y_CLAMP
	if start:
		# Triggers at game launch; generates tiles to GROUND_SIZE dimentions
		for y in GROUND_SIZE.y:
			ground_gen_pos.x = 0
			for x in GROUND_SIZE.x:
				var tile = ground_tile.instance()
				var _ret = tile.connect("screen_exited", self, "generate_ground")
				tile.position = ground_gen_pos
				ground_gen_pos.x += GROUND_TILE_SIZE
				$Tiles.add_child(tile)
			ground_gen_pos.y += GROUND_TILE_SIZE
	else:
		# Triggers when tile leaves viewport; sets tile x to current gen pos x
		body.position.x = ground_gen_pos.x
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

func _on_DivetTimer_timeout():
	spawn_object(divet_tile.instance(), $DivetTimer, timer_divet_min, timer_divet_max)


### Collision functions
func collect_static():
	if game_active:
		points += static_value
		gui.update_points(points)
	
func hit_rocks():
	if game_active:
		health -= 1
		gui.update_health(health)
		if (health == 0):
			game_over()
		else:
			stun()
	
func hit_divet():
	if game_active:
		stun()





