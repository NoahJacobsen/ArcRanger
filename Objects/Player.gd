extends KinematicBody2D


export (int) var max_speed = 375  # Acceleration dicates true max; round up to nearest multiple of acceleration
export (float) var acceleration = 0.08

onready var game_controller = get_tree().get_nodes_in_group("game_controller")[0]

var screen_size
var x_clamp
var y_clamp
var y_clamp_margin

var current_speed = 0

func _ready():
	x_clamp = game_controller.x_clamp
	y_clamp = game_controller.y_clamp
	y_clamp_margin = game_controller.y_clamp_margin
	screen_size = get_viewport_rect().size
	position.x = x_clamp


func _physics_process(_delta):
	var dir = false
	var game_active = game_controller.game_active
	if (Input.is_action_pressed("ui_up") && game_active):
		current_speed = lerp(current_speed, -max_speed, acceleration)
		dir = true
	if (Input.is_action_pressed("ui_down") && game_active):
		current_speed = lerp(current_speed, max_speed, acceleration)
		dir = true
	if not dir:
		current_speed = lerp(current_speed, 0, acceleration)
	var _ret = move_and_slide(Vector2(0, current_speed))
	position.y = clamp(position.y, y_clamp, screen_size.y - y_clamp_margin)
	


func _on_LanceArea_body_entered(body):
	if (body.TYPE == "static"):
		print("Hit static!")
		body.hit()
		game_controller.collect_static()



func _on_BikeArea_body_entered(body):
	if (body.TYPE == "rocks"):
		print("Hit rocks!")
		body.hit()
		game_controller.hit_rocks()
	elif (body.TYPE == "divet"):
		print("Hit divet!")
		body.hit()
		game_controller.hit_divet()
