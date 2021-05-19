extends MarginContainer

signal start_game
signal quit_game

func update_speed(new_speed):
	$Rows/Stats/SpeedCounter/Value.text = str(round(new_speed))

func update_health(new_health):
	$Rows/Stats/HealthCounter/Value.text = str(new_health)

func update_points(new_points):
	$Rows/Stats/PointCounter/Value.text = str(new_points)

func show_message(text):
	$Rows/Message.text = text
	$Rows/Message.show()

func hide_message():
	$Rows/Message.hide()

func show_stats():
	$Rows/Stats.show()
	
func hide_stats():
	$Rows/Stats.hide()

func show_buttons():
	$Rows/Start.show()
	$Rows/Quit.show()

func hide_buttons():
	$Rows/Start.hide()
	$Rows/Quit.hide()

func hide_credits():
	$Rows/Credits.hide()

func _on_Start_pressed():
	emit_signal("start_game")
	
func _on_Quit_pressed():
	emit_signal("quit_game")
