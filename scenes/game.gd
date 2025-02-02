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
	
	if fail_count == 3:
		%UI.hide()
		get_node("EndScreen/ScoreLabel").text += str(count)
		get_node("EndScreen").show()
		get_tree().paused = true
	
	if Input.is_action_just_pressed("escape"):
		%UI.hide()
		get_node("PauseMenu").show()
		get_tree().paused = true

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
		instance.position.y = 270
	# bad guy
	elif guy_type == 1:
		instance = bad_guy_scene.instantiate()
		instance.set_meta("type", "bad")
		instance.position.y = 260
		
	if guy_spawn_pos == 0:
		instance.position.x = randi_range(-150,0)
		instance.dir = 1
	elif guy_spawn_pos == 1:
		instance.position.x = randi_range(1300,1500)
		instance.dir = -1
		instance.get_node("AnimatedSprite2D").flip_h = true
	
	$Guys.add_child(instance)


func _on_game_harderer_timer_timeout() -> void:
	if %GameTimer.wait_time <= 0.3:
		return
		
	$TimerLabel.text = str(%GameTimer.wait_time)
	%GameTimer.wait_time = %GameTimer.wait_time - 0.1
	%GameHardererTimer.wait_time = %GameHardererTimer.wait_time + 0.25

func killzone(body: CharacterBody2D, good_type: String):
	if body.get_meta("type") == good_type:
		count += randi_range(100, 110)
	else:
		$Angel.play("cry")
		
		count -= randi_range(400, 550)
		fail_count += 1
	
	get_node("UI/Control/VBOX/Control2/MoneyLabel").text = str(count)
	get_node("UI/Control/VBOX/Control/FailCount").text = str(fail_count)
	body.queue_free()

func _on_bottom_count_zone_body_entered(body):
	killzone(body, "bad")

func _on_top_count_zone_body_entered(body):
	killzone(body, "good")

func _on_game_reset_fail_timeout() -> void:
	fail_count = 0
	

func _on_angel_animation_finished():
	$Angel.play("idle")
	
