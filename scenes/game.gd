extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var fall_guy_scene = load("res://scenes/fall_guy.tscn")

func _on_game_timer_timeout() -> void:
	print("hey")
	var fg_instance = fall_guy_scene.instantiate()
	fg_instance.position.x = randi_range(-150,0)
	fg_instance.position.y = 180
	$Guys.add_child(fg_instance)
