extends Node2D

var count = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimerLabel.text = str(%GameTimer.wait_time)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var fall_guy_scene = load("res://scenes/fall_guy.tscn")
var bad_guy_scene = load("res://scenes/bad_guy.tscn")

func _on_game_timer_timeout() -> void:
	print("hey")
	var fg_instance = fall_guy_scene.instantiate()
	var bg_instance = bad_guy_scene.instantiate()
	var guys = [fg_instance, bg_instance]
	fg_instance.position.x = randi_range(-150,0)
	fg_instance.position.y = 180
	bg_instance.position.x = randi_range(-150,0)
	bg_instance.position.y = 170
	$Guys.add_child(guys[randi() % guys.size()])


func _on_game_harderer_timer_timeout() -> void:
	if %GameTimer.wait_time <= 0.5:
		return
		
	$TimerLabel.text = str(%GameTimer.wait_time)
	%GameTimer.wait_time = %GameTimer.wait_time - 0.2


func _on_area_2d_area_entered(area):
	count += randi_range(100, 110)
	$count_label.text = str(count)
	
