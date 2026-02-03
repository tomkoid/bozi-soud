extends Node

var game_controller : GameController
var game_version = "1.5.0"

var settings: GameSettings = GameSettings.new()

enum INPUT_SCHEMES {TOUCH_SCREEN, KEYBOARD, CONTROLLER}
var input_method: INPUT_SCHEMES = INPUT_SCHEMES.TOUCH_SCREEN
var mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

# Game speed multiplier for collectibles (1.0 = normal speed)
var game_speed_multiplier: float = 1.0

signal changed_input_method
signal emit_player_particles

signal version_bad

@export var prev_scene = ""

func _input(event: InputEvent) -> void:
	var prev_input_method = input_method
	var prev_mouse_mode = mouse_mode 
	if event is InputEventMouse:
		input_method = INPUT_SCHEMES.TOUCH_SCREEN
		mouse_mode = Input.MOUSE_MODE_VISIBLE
		# print("mouse move detected, set input method to touch screen")
	elif event is InputEventKey:
		input_method = INPUT_SCHEMES.KEYBOARD
		mouse_mode = Input.MOUSE_MODE_VISIBLE
		# print("keyboard key detected, set input method to keyboard")
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		input_method = INPUT_SCHEMES.CONTROLLER
		mouse_mode = Input.MOUSE_MODE_HIDDEN
		# print("controller button detected, set input method to controller")
	
	if input_method != prev_input_method:
		changed_input_method.emit()

	if mouse_mode != prev_mouse_mode:
		Input.set_mouse_mode(mouse_mode)
