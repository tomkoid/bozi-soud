extends TextureButton

func _on_pressed() -> void:
	get_node("../..").hide()
	get_node("../../../PauseMenu").show()
	get_tree().paused = true

var master_bus = AudioServer.get_bus_index("Master")

func _on_sound_mute_toggle_pressed() -> void:
	AudioServer.set_bus_mute(master_bus, not AudioServer.is_bus_mute(master_bus))
