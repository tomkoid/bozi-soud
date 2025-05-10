extends Node2D

var LIVES_COUNT = 3

@export var stats: Stats

var save_path = "user://game.save"

var game_data = {
	"best_score": 0
}

var global_delta: float

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(game_data)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# reset stats
	stats.lives = LIVES_COUNT
	stats.score = 0
	stats.score = 0
	
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		game_data = file.get_var(true)
		
	refresh_fail_count()
	
	_on_game_timer_timeout() # spawn first enemy right away


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(%GameTimer.wait_time)
	$TimerLabel.text = str(%GameTimer.wait_time)
	global_delta = _delta
	if Input.is_action_pressed("reload"):
		Global.game_controller.reload_currrent_scene()


	if stats.lives == 1:
		if Global.input_method == Global.INPUT_SCHEMES.CONTROLLER and Input.get_joy_vibration_duration(0) == 0.0:
			Input.start_joy_vibration(0, 1.0, 1.0, 5)


	if stats.lives <= 0:
		if game_data.best_score < stats.score or game_data.best_score == 0:
			game_data.best_score = stats.score
			save()


		if Global.input_method == Global.INPUT_SCHEMES.CONTROLLER:
			Input.stop_joy_vibration(0)
			Input.start_joy_vibration(0, 1.0, 1.0, 0.7)
			
		%UI.hide()
		get_node("EndScreen/ScoreContainer/ScoreLabel").text += str(stats.score)
		get_node("EndScreen/ScoreContainer/BestScoreLabel").text += str(game_data.best_score)
		get_node("EndScreen").show()
		get_tree().paused = true

		stats.lives = LIVES_COUNT
		stats.score = 0
	
	if Input.is_action_just_pressed("escape"):
		%UI.hide()
		get_node("PauseMenu").show()
		get_tree().paused = true
	
	var until_reset_node = get_node("UI/Control/VBOX/Control/UntilReset")
	if $GameResetFail.time_left != 0:
		until_reset_node.show()
		until_reset_node.text = "next reset: " + str(roundi($GameResetFail.time_left)) + "s"
	else:
		until_reset_node.hide()


var fall_guy_scene = load("res://scenes/entities/fall_guy.tscn")
var bad_guy_scene = load("res://scenes/entities/bad_guy.tscn")

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
		instance.get_node("TypeMarker").position.x *= -1
	
	# enable fall guy tilt
	instance.tilt = true
	
	$Guys.add_child(instance)


func _on_game_harderer_timer_timeout() -> void:
	if %GameTimer.wait_time <= 0.3:
		return
		
	%GameTimer.wait_time = %GameTimer.wait_time - 0.1
	%GameHardererTimer.wait_time = %GameHardererTimer.wait_time + 0.25

func refresh_fail_count():
	var fc_node = get_node("UI/Control/VBOX/Control/LivesCount")
	# this function gives us the proper red color based on the lives count
	# f(n) = 1.5 - 0.5n
	var text_color = Color(1.5-0.5*stats.lives,0.0,0.0,1.0)
	fc_node.set("theme_override_colors/default_color", text_color)
	
	var prefix: String
	var suffix: String
	
	if stats.lives == 1:
		prefix = "[shake rate=80.0 level=10 connected=1]"
		suffix = "[/shake]"
	
	
	fc_node.text = prefix + str(stats.lives) + suffix

func killzone(body: CharacterBody2D, good_type: String):
	if body.get_meta("type") == good_type:
		stats.score += randi_range(100, 110)
	else:
		# controller vibration
		if Global.input_method == Global.INPUT_SCHEMES.CONTROLLER:
			Input.start_joy_vibration(0, 0.5, 1.0, 0.4)

		$HeartbeatPlayer.stop()
		$HeartbeatPlayer.play()
		$LifeLostPlayer.stop()
		$LifeLostPlayer.play()
		$VignettePlayer.stop()
		$VignettePlayer.play("fade_inout")

		if $GameResetFail.is_stopped():
			$GameResetFail.start()
			
		$Angel.play("cry")
		
		stats.lives -= 1
	
	get_node("UI/Control/VBOX/Control2/MoneyLabel").text = str(stats.score)
	refresh_fail_count()
	body.queue_free()


func _on_bottom_count_zone_body_entered(body):
	killzone(body, "bad")

func _on_top_count_zone_body_entered(body):
	killzone(body, "good")

func _on_game_reset_fail_timeout() -> void:
	stats.lives = LIVES_COUNT
	refresh_fail_count()
	

func _on_angel_animation_finished():
	$Angel.play("idle")

@export var speed_collect_scene: PackedScene

func _on_new_collect_timer_timeout() -> void:
	if $Collectibles.get_child_count() != 0:
		return
	
	var collect_type = randi_range(0,1)
	var SpawnRate = $GameTimer.wait_time
	if SpawnRate <= 0.5:
		collect_type = 1
	if SpawnRate >= 1.7:
		collect_type = 0
	
	var instance
	instance = speed_collect_scene.instantiate()
	instance.position.y = 100
	instance.position.x = randi_range(450, 700)

	if collect_type == 0:
		print("fast")
		instance.set_meta("collect_type", "fast")
		instance.animation = "fast"
		
			
	if collect_type == 1:
		print("slow")
		instance.set_meta("collect_type", "slow")
		instance.animation = "slow"
	
	var despawn_timer = Timer.new()
	despawn_timer.wait_time = 7.0
	despawn_timer.name = "DespawnTimer"
	instance.add_child(despawn_timer)
		
	$Collectibles.add_child(instance)
