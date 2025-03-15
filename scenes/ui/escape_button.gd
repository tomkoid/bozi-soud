extends TextureButton

# TODO: refactor this code, split it correctly

func _ready():
	if Global.settings.s.master_muted:
		set_pressed_no_signal(true)
		if not AudioServer.is_bus_mute(master_bus):
			toggle_master_mute()

func _physics_process(delta: float) -> void:
	if Global.settings.s.master_muted and AudioServer.is_bus_mute(master_bus) and not button_pressed:
		set_pressed_no_signal(true)
	elif not Global.settings.s.master_muted and not AudioServer.is_bus_mute(master_bus) and button_pressed:
		set_pressed_no_signal(false)
		

func _on_pressed() -> void:
	get_node("../..").hide()
	get_node("../../../PauseMenu").show()
	get_tree().paused = true
	Global.settings.save()

var master_bus = AudioServer.get_bus_index("Master")

func _on_sound_mute_toggle_pressed() -> void:
	toggle_master_mute()
	Global.settings.s.master_muted = AudioServer.is_bus_mute(master_bus)

	Global.settings.save()

func toggle_master_mute():
	AudioServer.set_bus_mute(master_bus, not AudioServer.is_bus_mute(master_bus))
