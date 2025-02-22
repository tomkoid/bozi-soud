extends Node2D
var save_path = "user://game.save"
var game_data = {
	"best_score": 0
}

@onready var info_check = $InfoCheck
var info_api_url = "https://bs.tomkoid.cz/api/v1/info"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InfoButton.text = "O projektu"
	$InfoButton.uri = "https://codeberg.org/dictator/bozi-soud"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		game_data = file.get_var(true)
	get_node("BestScoreLabel").text += str(game_data.best_score)
	
	# check info api
	info_check.request_completed.connect(_on_info_check_request_completed)
	print("info: requesting..")
	info_check.request(info_api_url)
	
func _on_info_check_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("info: request done.")
	print("info: request body: ", body.get_string_from_utf8())
	var data = JSON.parse_string(body.get_string_from_utf8())
	
	if data != null and Global.game_version != data.version:
		_show_new_version_msg(data)

func _show_new_version_msg(data):
	$InfoButton.text = "Stáhnout novou verzi hry " + data.version
	$InfoButton.uri = data.redirect_url

func _on_button_pressed() -> void:
	Global.game_controller.change_gui_scene("res://scenes/level.tscn")
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished


func _on_settings_button_pressed():
	Global.game_controller.change_gui_scene("res://scenes/ui/settings.tscn", false, true)
	
	
func _on_quit_button_pressed():
	get_tree().quit()
