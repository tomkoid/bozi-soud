extends Node2D


# Called when the node enters the scene tree for the first time.



func _on_button_pressed() -> void:
	Global.game_controller.change_gui_scene("res://scenes/level.tscn")
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished


func _on_settings_button_pressed():
	Global.game_controller.change_gui_scene("res://scenes/ui/settings.tscn", false, true)
	
	
func _on_quit_button_pressed():
	get_tree().quit()
