class_name GameController extends Node2D

@export var world : Node2D
@export var gui : Control

var current_world
var prev_gui_scene
var current_gui
var current_gui_path

@onready var info_check = $InfoCheck

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	change_gui_scene("res://scenes/ui/menu.tscn")
	
	info_check.request_completed.connect(_on_info_check_request_completed)
	info_check.request("https://bs.tomkoid.cz/api/v1/info")
	
func _on_info_check_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var data = JSON.parse_string(body.get_string_from_utf8())
	print(data.version)
	
	if data.version != null and Global.game_version != data.version:
		Global.version_bad.emit(data)

func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui != null:
		if delete:
			current_gui.queue_free()  # Removes node entirely
		elif keep_running:
			current_gui.visible = false  # Keeps in memory and running
			prev_gui_scene = current_gui
		else:
			gui.remove_child(current_gui)  # Keeps in memory, does not run
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui = new
	current_gui_path = new_scene
	
func change_gui_prev():
	print("previous scene:", prev_gui_scene.name)
	prev_gui_scene.visible = true
	gui.remove_child(current_gui)
	print("current scene:", current_gui.name)
	current_gui = prev_gui_scene
	current_gui_path = current_gui.scene_file_path

func change_world_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_world != null:
		if delete:
			current_gui.queue_free()  # Removes node entirely
		elif keep_running:
			current_gui.visible = false  # Keeps in memory and running
		else:
			gui.remove_child(current_gui)  # Keeps in memory, does not run
	
	var new = load(new_scene).instantiate()
	world.add_child(new)
	current_world = new

func reload_current_scene():
	var scene_name = current_gui.name
	print(scene_name)
	gui.remove_child(current_gui)
	var new = load(current_gui_path).instantiate()
	new.name = scene_name
	gui.add_child(new)
	current_gui = new
