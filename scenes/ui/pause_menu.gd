extends CanvasLayer



func _on_continue_pressed():
	$".".hide()
	%UI.show()
	get_tree().paused = false
	

func _on_menu_pressed():
	$".".hide()
	get_tree().paused = false
	Global.game_controller.change_gui_scene("res://scenes/ui/menu.tscn")
	

func _on_restart_pressed():
	get_tree().paused = false
	Global.game_controller.reload_current_scene()
	
