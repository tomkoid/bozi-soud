extends CanvasLayer

@onready var slider_folder = "LeftCol/"
@onready var master_vol_slider = get_node(slider_folder + "MasterVolumeContainer/MasterVolumeSlider")
@onready var master_mute_btn = get_node(slider_folder + "MasterVolumeContainer/Control/MasterVolumeMute")
@onready var music_vol_slider = get_node(slider_folder + "MusicVolumeContainer/MusicVolumeSlider")
@onready var sfx_vol_slider = get_node(slider_folder + "SoundEffectVolumeContainer/SoundEffectVolumeSlider")

@onready var display_type_btn = $RightCol/DisplayType

var ready_finished = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pause_menu = get_node("../Game/PauseMenu")
	if pause_menu:
		pause_menu.hide()
	
	$RightCol/ParticlesButton.button_pressed = Global.settings.s["particles"]
	$RightCol/VsyncButton.text = check_vsync_mode(DisplayServer.window_get_vsync_mode())
	$RightCol/FullscreenButton.button_pressed = is_fullscreen(DisplayServer.window_get_mode())

	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		$RightCol/FullscreenButton.hide()

	ready_finished = true
	
	master_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sfx_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	master_mute_btn.set_pressed_no_signal(AudioServer.is_bus_mute(0))
	manage_master_vol_slider()
	

	# update value of display in settings
	_on_display_type_pressed(get_tree().root.content_scale_aspect) # don't change aspect, just update the button text

	
func _physics_process(_delta):
	if Input.is_action_just_pressed("escape"):
		var pause_menu = get_node("../Game/PauseMenu")
		if pause_menu:
			pause_menu.show()
		Global.game_controller.change_gui_prev()
		Global.settings.save()
		
func check_vsync_mode(mode: int) -> String:
	if mode == DisplayServer.VSYNC_DISABLED:
		return "VSYNC: off"
	if mode == DisplayServer.VSYNC_ENABLED:
		return "VSYNC: on"
	if mode == DisplayServer.VSYNC_ADAPTIVE:
		return "VSYNC: adaptive"

	return "VSYNC: unknown"

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
	
	$RightCol/VsyncButton.text = check_vsync_mode(vsync_index)
	DisplayServer.window_set_vsync_mode(vsync_index)
	pass # Replace with function body.

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	# dont change until ready
	if not ready_finished:
		return

	var apply_mode
	if toggled_on:
		apply_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	else:
		apply_mode = DisplayServer.WINDOW_MODE_WINDOWED

	DisplayServer.window_set_mode(apply_mode)
	Global.settings.s.fullscreen = toggled_on


func _on_escape_button_pressed():
	pass # Replace with function body.

# -1 = toggle between
func _on_display_type_pressed(aspect: int = -1):
	var current_content_scale_aspect = get_tree().root.content_scale_aspect
		
	var aspect_keep = Window.CONTENT_SCALE_ASPECT_KEEP
	var aspect_ignore = Window.CONTENT_SCALE_ASPECT_IGNORE
	
	var aspect_keep_msg = "Stretch screen: off (recommended)"
	var aspect_ignore_msg = "Strech screen: on"
	
	var apply_aspect: int
	if aspect == -1:
		if current_content_scale_aspect == aspect_keep:
			apply_aspect = aspect_ignore
			display_type_btn.text = aspect_ignore_msg
		elif current_content_scale_aspect == aspect_ignore:
			apply_aspect = aspect_keep
			display_type_btn.text = aspect_keep_msg
	else:
		if aspect == aspect_keep:
			apply_aspect = aspect_keep
			display_type_btn.text = aspect_keep_msg
		elif aspect == aspect_ignore:
			apply_aspect = aspect_ignore
			display_type_btn.text = aspect_ignore_msg
		
	get_tree().root.content_scale_aspect = apply_aspect
	Global.settings.s.content_scale = apply_aspect

func change_bus_vol(settings_property: String, val_changed: bool, bus: int, slider: Slider):
	if not val_changed:
		return
	AudioServer.set_bus_volume_db(bus, linear_to_db(slider.value))
	Global.settings.s[settings_property] = float(slider.value)
	Global.settings.save()

func _on_master_volume_slider_drag_ended(value_changed: bool) -> void:
	change_bus_vol("master_volume", value_changed, 0, master_vol_slider)

func _on_music_volume_slider_drag_ended(value_changed: bool) -> void:
	change_bus_vol("music_volume", value_changed, 1, music_vol_slider)

func _on_sound_effect_volume_slider_drag_ended(value_changed: bool) -> void:
	change_bus_vol("sfx_volume", value_changed, 2, sfx_vol_slider)


func _on_particles_button_toggled(toggled_on: bool) -> void:
	Global.settings.s["particles"] = toggled_on


func _on_rtx_button_toggled(toggled_on: bool) -> void:
	print("setting to: ", toggled_on)
	Global.settings.s["rtx"] = toggled_on
	Global.settings.save()

func manage_master_vol_slider():
	if not AudioServer.is_bus_mute(0):
		master_vol_slider.editable = true
	else:
		master_vol_slider.editable = false

func _on_master_volume_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
	Global.settings.s["master_muted"] = toggled_on
	Global.settings.save()
	manage_master_vol_slider()
