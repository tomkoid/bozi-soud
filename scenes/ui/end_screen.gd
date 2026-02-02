extends Button


func _on_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()
