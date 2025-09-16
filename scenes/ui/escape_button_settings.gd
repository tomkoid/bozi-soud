extends TextureButton


@onready var pause_menu = get_node("../../Game/PauseMenu")

func _on_pressed():	
	get_node("..").hide()
	Global.settings.save()
