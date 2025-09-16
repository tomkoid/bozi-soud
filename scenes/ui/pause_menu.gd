extends CanvasLayer



func _on_continue_pressed():
	$".".hide()
	%UI.show()
	get_tree().paused = false
	

func _on_menu_pressed():
	$".".hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
	

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	


func _on_settings_pressed() -> void:
	$Settings.show()
