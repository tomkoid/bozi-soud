class_name GameSettings extends Node

var s = {
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	
	"fullscreen": false,
	"content_scale": Window.CONTENT_SCALE_ASPECT_KEEP,
	
	"master_muted": false
}

var settings_save_path = "user://settings.save"

func save():
	var file = FileAccess.open(settings_save_path, FileAccess.WRITE)
	file.store_var(s)
	
func save_load():
	if FileAccess.file_exists(settings_save_path):
		var file = FileAccess.open(settings_save_path, FileAccess.READ)
		s = file.get_var(true)
		print("settings: loaded from save file")
	else:
		print("settings: no save file, using default")
	
	# load audio buses
	AudioServer.set_bus_volume_db(0, linear_to_db(s.master_volume))
	AudioServer.set_bus_volume_db(1, linear_to_db(s.music_volume))
	AudioServer.set_bus_volume_db(2, linear_to_db(s.sfx_volume))

	# load window status
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if not s.fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
	# DisplayServer.window_set_content_scale(s.content_scale)


func init() -> void:
	save_load()
