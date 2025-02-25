extends Node

var game_controller : GameController
var game_version = "1.2.1"

var settings: GameSettings = GameSettings.new()

signal version_bad

@export var prev_scene = ""
