extends Node

var game_controller : GameController
var game_version = "1.3.0"

var settings: GameSettings = GameSettings.new()

signal version_bad

@export var prev_scene = ""
