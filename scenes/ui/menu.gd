extends Node2D
var save_path = "user://game.save"
var game_data = {
	"best_score": 0
}

@onready var info_check = $InfoCheck
var info_api_url = "https://bs.tomkoid.cz/api/v1/info"

var levels_info = [
	{
		"name": "classic",
		"path": "background_paralax_1.png"
	},
	{
		"name": "hell",
		"path": "background_hell_onlyfortest.png"
	},
	{
		"name": "heaven",
		"path": "background_heavenl_onlyfortest.png"
	}
]

#var level_ids = ["background_paralax_1.png", "background_hell_onlyfortest.png"]
var current_level_id = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionScreen.transition()
	
	$GameVersion.text += Global.game_version
	$GameVersion.modulate.a = .7
	$InfoButton.text = "About the game"
	$InfoButton.uri = "https://codeberg.org/dystopia/final-trial"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		game_data = file.get_var(true)
	get_node("BestScoreLabel").text += str(game_data.best_score)
	$LevelLabel.text = levels_info[current_level_id].name
	recover_current_map()
	$CoinLabel.text += str(Global.coins)
	
	# check info api
	info_check.request_completed.connect(_on_info_check_request_completed)
	print("info: requesting..")
	info_check.request(info_api_url, ["User-Agent: BS (%s)" % Global.game_version])
	
var rotation_accel = 0.45
func _process(delta: float) -> void:
	var gt_rot = $GameTitle.rotation_degrees
	if gt_rot >= 1.5:
		rotation_accel = -rotation_accel
	elif gt_rot <= -2.5:
		rotation_accel = -rotation_accel
	$GameTitle.rotation_degrees += rotation_accel * delta

	
func _on_info_check_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("info: request done.")
	print("info: request body: ", body.get_string_from_utf8())
	var data = JSON.parse_string(body.get_string_from_utf8())
	
	if data != null and Global.game_version != data.version:
		_show_new_version_msg(data)

func _show_new_version_msg(data):
	$InfoButton.text = "New version " + data.version + " available!"
	$InfoButton.uri = data.redirect_url

func _on_button_pressed() -> void:
	Global.game_controller.change_gui_scene("res://scenes/level" + str(current_level_id) + ".tscn")
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished


func _on_settings_button_pressed():
	Global.game_controller.change_gui_scene("res://scenes/ui/settings_menu.tscn", false, true)
	
	


func recover_current_map():
	var current_level_id = Global.settings.s.current_map
	for i in range(len(levels_info)):
		if current_level_id == int(i):
			$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/" + levels_info[i].path)
			$LevelLabel.text = levels_info[i].name


func _on_switching_levels_button_right_pressed():
	current_level_id += 1
	if current_level_id > len(levels_info) - 1:
		current_level_id = 0
	Global.settings.s.current_map = current_level_id
	Global.settings.save()
	for i in range(len(levels_info)):
		if current_level_id == int(i):
			$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/" + levels_info[i].path)
			$LevelLabel.text = levels_info[i].name
			
			
	
	#if current_level_id == 2:
		#$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_heavenl_onlyfortest.png")
	#if current_level_id == 1:
		#$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_hell_onlyfortest.png")
	#elif current_level_id == 0:
		#$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_paralax_1.png")
	#elif current_level_id > len(level_ids) - 1:
		#current_level_id = 0
		#$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_paralax_1.png")
		
func _on_switching_levels_button_left_pressed():
	current_level_id -= 1
	if current_level_id < 0:
		current_level_id = len(levels_info) - 1
	Global.settings.s.current_map = current_level_id
	Global.settings.save()
	for i in range(len(levels_info)):
		if current_level_id == int(i):
			$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/" + levels_info[i].path)
			$LevelLabel.text = levels_info[i].name
			
	
	#if current_level_id == 2:
		#$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_heavenl_onlyfortest.png")
	#if current_level_id == 1:
		#$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_hell_onlyfortest.png")
	#elif current_level_id == 0:
		#$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_paralax_1.png")
	#elif current_level_id < 0:
		#current_level_id = len(level_ids) - 1
		#$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/" + level_ids[len(level_ids) - 1] + ".png")
		


func _on_shop_button_pressed():
	Global.game_controller.change_gui_scene("res://scenes/ui/shop.tscn", false, true)
	
