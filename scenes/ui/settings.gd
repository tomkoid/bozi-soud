extends CanvasLayer

@onready var pause_menu = get_node("../Game/PauseMenu")

@onready var master_vol_slider = $SoundRightCol/MasterVolumeSlider
@onready var music_vol_slider = $SoundRightCol/MusicVolumeSlider
@onready var sfx_vol_slider = $SoundRightCol/SoundEffectVolumeSlider

var ready_finished = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if pause_menu:
		pause_menu.hide()
		
	$VsyncButton.text = check_vsync_mode(DisplayServer.window_get_vsync_mode())
	$FullscreenButton.button_pressed = is_fullscreen(DisplayServer.window_get_mode())

	ready_finished = true
	
	master_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sfx_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))

	# update value of display in settings
	_on_display_type_pressed()

	
func _physics_process(_delta):
	if Input.is_action_just_pressed("escape"):
		if pause_menu:
			pause_menu.show()
		Global.game_controller.change_gui_prev()
		
func check_vsync_mode(mode: int) -> String:
	if mode == DisplayServer.VSYNC_DISABLED:
		return "VSYNC: vypnuto"
	if mode == DisplayServer.VSYNC_ENABLED:
		return "VSYNC: zapnuto"
	if mode == DisplayServer.VSYNC_ADAPTIVE:
		return "VSYNC: adaptivní"

	return "VSYNC: neznámý"

func is_fullscreen(mode: int) -> bool:
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		return true

	return false

var vsync_index = 1

func _on_vsync_button_pressed() -> void:
	vsync_index += 1

	# reset vsync_index
	if vsync_index == 3:
		vsync_index = 0
	
	$VsyncButton.text = check_vsync_mode(vsync_index)
	DisplayServer.window_set_vsync_mode(vsync_index)
	pass # Replace with function body.

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	# dont change until ready
	if not ready_finished:
		return

	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_escape_button_pressed():
	pass # Replace with function body.


func _on_display_type_pressed():
	var current_content_scale_aspect = get_tree().root.content_scale_aspect
	if current_content_scale_aspect == Window.CONTENT_SCALE_ASPECT_KEEP:
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
		$DisplayType.text = "Roztažení obrazovky: ANO"
	elif current_content_scale_aspect == Window.CONTENT_SCALE_ASPECT_IGNORE:
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		$DisplayType.text = "Roztažení obrazovky: NE (doporučeno)"


func change_bus_vol(val_changed: bool, bus: int, slider: Slider):
	if not val_changed:
		return
	AudioServer.set_bus_volume_db(bus, linear_to_db(slider.value))

func _on_master_volume_slider_drag_ended(value_changed: bool) -> void:
	change_bus_vol(value_changed, 0, master_vol_slider)

func _on_music_volume_slider_drag_ended(value_changed: bool) -> void:
	change_bus_vol(value_changed, 1, music_vol_slider)

func _on_sound_effect_volume_slider_drag_ended(value_changed: bool) -> void:
	change_bus_vol(value_changed, 2, sfx_vol_slider)
