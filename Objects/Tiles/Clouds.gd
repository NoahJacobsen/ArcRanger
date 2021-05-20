extends AnimatedSprite

signal screen_exited


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	emit_signal("screen_exited", self)
