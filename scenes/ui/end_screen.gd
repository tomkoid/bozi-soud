extends Button


func _on_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
