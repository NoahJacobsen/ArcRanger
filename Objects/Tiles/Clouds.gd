extends AnimatedSprite

signal cloud_exited

onready var game_controller = get_tree().get_nodes_in_group("game_controller")[0]


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	emit_signal("cloud_exited", self)
