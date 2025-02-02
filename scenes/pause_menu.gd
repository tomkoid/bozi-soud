extends Control



func _on_continue_pressed():
	$".".hide()
	%UI.show()
	get_tree().paused = false


func _on_settings_pressed():
	$".".hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
	


func _on_menu_pressed():
	$".".hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
