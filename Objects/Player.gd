extends KinematicBody2D


export (int) var max_speed = 225  # Acceleration dicates true max; round up to nearest multiple of acceleration
export (int) var acceleration = 20

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

func _process(delta):
	var direction = Vector2()
	if (Input.is_action_pressed("ui_up")):
		direction.y -= 1
	if (Input.is_action_pressed("ui_down")):
		direction.y += 1
	if (direction.length() > 0):
		if (current_speed < max_speed && current_speed > -max_speed):
			current_speed += direction.y * acceleration
	else:
		if (current_speed > 0):
			current_speed -= acceleration
		if (current_speed < 0):
			current_speed += acceleration
	position += Vector2(0, current_speed) * delta
	# NOTE: Clamping instead of decelerating might cause an animation problem
	position.y = clamp(position.y, y_clamp, screen_size.y - y_clamp_margin)
