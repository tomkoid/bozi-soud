extends Button


func _on_pressed() -> void:
	hide()
	get_tree().paused = false
	Global.game_controller.change_gui_scene("res://scenes/level.tscn")
