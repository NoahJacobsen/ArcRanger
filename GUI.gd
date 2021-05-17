extends MarginContainer

func update_speed(new_speed):
	$HBoxContainer/SpeedCounter/Value.text = str(round(new_speed))
