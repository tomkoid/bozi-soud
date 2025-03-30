extends Node

var game_controller : GameController
var game_version = "1.4.1"

var settings: GameSettings = GameSettings.new()

enum INPUT_SCHEMES {MOUSE, KEYBOARD, CONTROLLER}
var input_method: INPUT_SCHEMES = INPUT_SCHEMES.CONTROLLER

signal emit_player_particles

signal version_bad

@export var prev_scene = ""
