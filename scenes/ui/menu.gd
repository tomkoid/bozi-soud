extends Node2D
var save_path = "user://game.save"
var game_data = {
	"best_score": 0
}
var level_ids = ["background_paralax_1.png", "background_hell_onlyfortest", "background_heavenl_onlyfortest"]
var current_level_id = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		game_data = file.get_var(true)
	get_node("BestScoreLabel").text += str(game_data.best_score)
	Global.connect("version_bad", _test)

func _test():
	print("LETS FUCKING GO")

func _on_button_pressed() -> void:
	Global.game_controller.change_gui_scene("res://scenes/level" + str(current_level_id) + ".tscn")
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished


func _on_settings_button_pressed():
	Global.game_controller.change_gui_scene("res://scenes/ui/settings.tscn", false, true)
	
	
func _on_quit_button_pressed():
	get_tree().quit()


func _on_switching_levels_button_right_pressed():
	current_level_id += 1
	if current_level_id == 2:
		$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_heavenl_onlyfortest.png")
	if current_level_id == 1:
		$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_hell_onlyfortest.png")
	elif current_level_id == 0:
		$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_paralax_1.png")
	elif current_level_id > len(level_ids) - 1:
		current_level_id = 0
		$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_paralax_1.png")
		
func _on_switching_levels_button_left_pressed():
	current_level_id -= 1
	if current_level_id == 2:
		$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_heavenl_onlyfortest.png")
	if current_level_id == 1:
		$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_hell_onlyfortest.png")
	elif current_level_id == 0:
		$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/background_paralax_1.png")
	elif current_level_id < 0:
		current_level_id = len(level_ids) - 1
		$MiniBackground.texture = ResourceLoader.load("res://assets/sprites/" + level_ids[len(level_ids) - 1] + ".png")
		
