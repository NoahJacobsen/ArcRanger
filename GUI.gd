extends MarginContainer

func update_speed(new_speed):
	$HBoxContainer/SpeedCounter/Value.text = str(round(new_speed))

func update_health(new_health):
	$HBoxContainer/HealthCounter/Value.text = str(new_health)

func update_points(new_points):
	$HBoxContainer/PointCounter/Value.text = str(new_points)

func game_over():
	pass
