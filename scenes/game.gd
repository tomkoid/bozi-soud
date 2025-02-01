extends Node2D

var count = 0
var fail_count = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimerLabel.text = str(%GameTimer.wait_time)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("reload"):
		get_tree().reload_current_scene()
	
	if fail_count == 10:
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

var fall_guy_scene = load("res://scenes/fall_guy.tscn")
var bad_guy_scene = load("res://scenes/bad_guy.tscn")

func _on_game_timer_timeout() -> void:
	var instance
	var guy_type = randi_range(0,1)
	var guy_spawn_pos = randi_range(0,1) # left, right
	
	# good guy
	if guy_type == 0:
		instance = fall_guy_scene.instantiate()
		instance.set_meta("type", "good")
		instance.position.y = 150
	# bad guy
	elif guy_type == 1:
		instance = bad_guy_scene.instantiate()
		instance.set_meta("type", "bad")
		instance.position.y = 150
		
	if guy_spawn_pos == 0:
		instance.position.x = randi_range(-150,0)
		instance.dir = 1
	elif guy_spawn_pos == 1:
		instance.position.x = randi_range(1200,1300)
		instance.dir = -1
		instance.get_node("AnimatedSprite2D").flip_h = true
#	
	$Guys.add_child(instance)


func _on_game_harderer_timer_timeout() -> void:
	if %GameTimer.wait_time <= 0.5:
		return
		
	$TimerLabel.text = str(%GameTimer.wait_time)
	%GameTimer.wait_time = %GameTimer.wait_time - 0.2



func _on_bottom_count_zone_body_entered(body):
	if body.get_meta("type") == "bad":
		count += randi_range(100, 110)
	else:
		count -= randi_range(400, 550)
		fail_count += 1
		
	$CountLabel.text = str(count)
	$FailCount.text = str(fail_count)
	body.queue_free()


func _on_top_count_zone_body_entered(body):
	if body.get_meta("type") == "good":
		count += randi_range(100, 110)
	else:
		count -= randi_range(400, 550)
		fail_count += 1
	$CountLabel.text = str(count)
	$FailCount.text = str(fail_count)
	body.queue_free()


	
