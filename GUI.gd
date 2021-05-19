extends MarginContainer

func update_speed(new_speed):
	$VBoxContainer/HBoxContainer/SpeedCounter/Value.text = str(round(new_speed))

func update_health(new_health):
	$VBoxContainer/HBoxContainer/HealthCounter/Value.text = str(new_health)

func update_points(new_points):
	$VBoxContainer/HBoxContainer/PointCounter/Value.text = str(new_points)

func show_message(text):
	$VBoxContainer/Message.text = text
	$VBoxContainer/Message.show()

func hide_message():
	$VBoxContainer/Message.hide()
