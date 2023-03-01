extends StaticBody2D

const TYPE = "static"

func hit():
	print("STATIC: Lightning!")
	queue_free()


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()
