extends Sprite

signal screen_exited


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	print("Exited")
	emit_signal("screen_exited", self)
