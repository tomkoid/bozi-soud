extends Button


func _on_pressed() -> void:
	hide()
	get_tree().paused = false
	Global.game_controller.reload_current_scene()
