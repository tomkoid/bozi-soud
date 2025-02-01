extends Node2D


# Called when the node enters the scene tree for the first time.



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	pass # Replace with function body.





func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
	
func _on_quit_button_pressed():
	get_tree().quit()
