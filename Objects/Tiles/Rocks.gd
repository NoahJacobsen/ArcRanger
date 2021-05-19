extends StaticBody2D

const TYPE = "rocks"

func hit():
	print("ROCKS: Crumble!")
	queue_free()


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()
