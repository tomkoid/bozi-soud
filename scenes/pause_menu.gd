extends Control



func _on_continue_pressed():
	$".".hide()
	get_tree().paused = false


func _on_settings_pressed():
	$".".hide()
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_menu_pressed():
	$".".hide()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
