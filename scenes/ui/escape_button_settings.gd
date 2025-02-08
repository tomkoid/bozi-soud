extends TextureButton


@onready var pause_menu = get_node("../../Game/PauseMenu")

func _on_pressed():
	if pause_menu:
		pause_menu.show()
	Global.game_controller.change_gui_prev()
