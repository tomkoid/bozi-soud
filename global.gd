extends Node

var game_controller : GameController
var game_version = "1.2"

signal version_bad

@export var prev_scene = ""

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#DiscordRPC.app_id = 1335673296359915610 # Application ID
	#DiscordRPC.details = "Religious game about the day of judgement."
	#DiscordRPC.state = "Playing"
#
	#DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	## DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"
#
	#DiscordRPC.refresh() # Always refresh after changing the values!
