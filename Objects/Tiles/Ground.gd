extends Sprite

signal screen_exited


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	emit_signal("screen_exited")
	queue_free()
