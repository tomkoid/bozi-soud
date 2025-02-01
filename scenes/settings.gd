extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VsyncButton.text = check_vsync_mode(DisplayServer.window_get_vsync_mode())

	pass # Replace with function body.

func check_vsync_mode(mode: int) -> String:
	if mode == DisplayServer.VSYNC_DISABLED:
		return "VSYNC: vypnuto"
	if mode == DisplayServer.VSYNC_ENABLED:
		return "VSYNC: zapnuto"
	if mode == DisplayServer.VSYNC_ADAPTIVE:
		return "VSYNC: adaptivní"

	return "VSYNC: neznámý"



var vsync_index = 1

func _on_vsync_button_pressed() -> void:
	vsync_index += 1

	# reset vsync_index
	if vsync_index == 3:
		vsync_index = 0
	
	$VsyncButton.text = check_vsync_mode(vsync_index)
	DisplayServer.window_set_vsync_mode(vsync_index)
	pass # Replace with function body.
