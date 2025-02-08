class_name GameController extends Node2D

@export var world : Node2D
@export var gui : Control

var current_world
var current_gui
var current_gui_path


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	change_gui_scene("res://scenes/ui/menu.tscn")

func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui != null:
		if delete:
			current_gui.queue_free()  # Removes node entirely
		elif keep_running:
			current_gui.visible = false  # Keeps in memory and running
		else:
			gui.remove_child(current_gui)  # Keeps in memory, does not run
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui = new
	current_gui_path = new_scene

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
	current_gui.queue_free()
	var new = load(current_gui_path).instantiate()
	gui.add_child(new)
	current_gui = new

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
