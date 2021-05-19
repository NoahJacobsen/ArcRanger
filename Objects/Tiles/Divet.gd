extends StaticBody2D

const TYPE = "divet"

func hit():
	print("DIVET: Particles!")


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
