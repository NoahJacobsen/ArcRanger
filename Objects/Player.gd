extends KinematicBody2D

const Y_CLAMP_MARGIN = 25

export (int) var speed = 225
export (int) var acceleration = 25

onready var game_controller = get_tree().get_nodes_in_group("game_controller")[0]

var screen_size
var x_clamp
var y_clamp

var current_speed = 0

func _ready():
	x_clamp = game_controller.x_clamp
	y_clamp = game_controller.y_clamp
	screen_size = get_viewport_rect().size
	position.x = x_clamp

func _process(delta):
	var direction = Vector2()
	if (Input.is_action_pressed("ui_up")):
		direction.y -= 1
	if (Input.is_action_pressed("ui_down")):
		direction.y += 1
	if (direction.length() > 0):
		if (current_speed < speed && current_speed > -speed):
			current_speed += direction.y * acceleration
		#direction = direction.normalized() * speed
		# Animate sprite
	else:
		var swerving = false
		if (current_speed > 0):
			current_speed -= acceleration
		if (current_speed < 0):
			current_speed += acceleration
			if swerving:
				current_speed = 0
	
	position += Vector2(0, current_speed) * delta
	position.y = clamp(position.y, y_clamp, screen_size.y - Y_CLAMP_MARGIN)
