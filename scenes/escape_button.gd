extends TextureButton

func _on_pressed() -> void:
	get_node("../..").hide()
	get_node("../../../PauseMenu").show()
	get_tree().paused = true
