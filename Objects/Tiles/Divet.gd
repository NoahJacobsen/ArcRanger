extends StaticBody2D

const TYPE = "divet"

func hit():
	print("DIVET: Particles!")


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()
