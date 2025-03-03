extends Node2D

var MAX_DEATH_COUNT = 3

@export var stats: Stats

var save_path = "user://game.save"

var game_data = {
	"best_score": 0
}

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(game_data)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# reset stats
	stats.fail_count = 0
	stats.score = 0
	
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		game_data = file.get_var(true)
		
	$TimerLabel.text = str(%GameTimer.wait_time)
	refresh_fail_count()
	
	_on_game_timer_timeout() # spawn first enemy right away


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("reload"):
		get_tree().reload_current_scene()
	
	if stats.fail_count >= MAX_DEATH_COUNT:
		if game_data.best_score < stats.score or game_data.best_score == 0:
			game_data.best_score = stats.score
			save()

			
		%UI.hide()
		get_node("EndScreen/ScoreContainer/ScoreLabel").text += str(stats.score)
		get_node("EndScreen/ScoreContainer/BestScoreLabel").text += str(game_data.best_score)
		get_node("EndScreen").show()
		get_tree().paused = true

		stats.fail_count = 0
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
		
	$TimerLabel.text = str(%GameTimer.wait_time)
	%GameTimer.wait_time = %GameTimer.wait_time - 0.1
	%GameHardererTimer.wait_time = %GameHardererTimer.wait_time + 0.25

func refresh_fail_count():
	var fc_node = get_node("UI/Control/VBOX/Control/FailCount")
	var text_color = Color(stats.fail_count * 1.0/(MAX_DEATH_COUNT-1),0.0,0.0,1.0)
	fc_node.set("theme_override_colors/default_color", text_color)
	
	var prefix: String
	var suffix: String
	
	if stats.fail_count == MAX_DEATH_COUNT-1:
		prefix = "[shake rate=80.0 level=10 connected=1]"
		suffix = "[/shake]"
	
	
	fc_node.text = prefix + str(stats.fail_count) + "/" + str(MAX_DEATH_COUNT) + suffix

func killzone(body: CharacterBody2D, good_type: String):
	if body.get_meta("type") == good_type:
		stats.score += randi_range(100, 110)
	else:
		if $GameResetFail.is_stopped():
			$GameResetFail.start()
			
		$Angel.play("cry")
		
		stats.fail_count += 1
	
	get_node("UI/Control/VBOX/Control2/MoneyLabel").text = str(stats.score)
	refresh_fail_count()
	body.queue_free()

func _on_bottom_count_zone_body_entered(body):
	killzone(body, "bad")

func _on_top_count_zone_body_entered(body):
	killzone(body, "good")

func _on_game_reset_fail_timeout() -> void:
	stats.fail_count = 0
	refresh_fail_count()
	

func _on_angel_animation_finished():
	$Angel.play("idle")
	
