extends KinematicBody2D


const ANIMATION_THRESHOLD = {
	"straight": 5,
	"turn_up": -10,
	"turn_down": 10
}

export (int) var max_speed = 375  # Acceleration dicates true max; round up to nearest multiple of acceleration
export (float) var acceleration = 0.08

onready var game_controller = get_tree().get_nodes_in_group("game_controller")[0]

var screen_size
var x_clamp
var y_clamp
var y_clamp_margin
var y_restriction_margin

var current_speed = 0
var stunned = false

func _ready():
	x_clamp = game_controller.x_clamp
	y_clamp = game_controller.y_clamp
	y_clamp_margin = game_controller.y_clamp_margin
	y_restriction_margin = game_controller.y_restriction_margin
	screen_size = get_viewport_rect().size
	position.x = x_clamp

func _physics_process(_delta):
	var dir = false
	var game_active = game_controller.game_active
	if (Input.is_action_pressed("ui_up") && game_active && !stunned && (position.y > y_clamp + y_restriction_margin)):
		current_speed = lerp(current_speed, -max_speed, acceleration)
		dir = true
	if (Input.is_action_pressed("ui_down") && game_active && !stunned && (position.y < screen_size.y - y_clamp_margin - y_restriction_margin)):
		current_speed = lerp(current_speed, max_speed, acceleration)
		dir = true
	if not dir:
		current_speed = lerp(current_speed, 0, acceleration)
		if ($Sprite.animation != "straight"):
			$Sprite.play("", true)
	var _ret = move_and_slide(Vector2(0, current_speed))
	set_animation()

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
		stunned = true
		$Sprite.play("stun")
	elif (body.TYPE == "divet"):
		print("Hit divet!")
		body.hit()
		game_controller.hit_divet()
		stunned = true
		$Sprite.play("stun")

func set_animation():
	if (stunned):
		return
	elif (current_speed < ANIMATION_THRESHOLD["turn_up"] && $Sprite.animation != "turn_up"):
		$Sprite.play("turn_up")
	elif (current_speed > ANIMATION_THRESHOLD["turn_down"] && $Sprite.animation != "turn_down"):
		$Sprite.play("turn_down")
	elif (current_speed > ANIMATION_THRESHOLD["turn_up"] &&
			current_speed < ANIMATION_THRESHOLD["turn_down"] &&
			$Sprite.animation != "straight"):
		$Sprite.play("straight")
