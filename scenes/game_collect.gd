extends Sprite2D

@onready var GameTimer = get_node("../../GameTimer")
@onready var despawn_timer = $DespawnTimer

@export var animation = ""

var speed_multiplier = 1.0  # Local speed multiplier instead of Engine.time_scale

func _ready():
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(_on_despawn_timer)
	despawn_timer.start()
	$CollectAnim.play(animation)

func _on_despawn_timer():
	$Area2D/CollisionShape2D.set_deferred("disabled",true)
	$AnimationPlayer.play("fadeout")
	await get_tree().create_timer(10.0, true, false, true).timeout
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "FallGuy" or "BadGuy":
		self.set_meta("started", "true")
		
		$BubblePinkSprite.play("bubble_destroy")
		$CollectAnim.visible = false
		$Area2D/CollisionShape2D.set_deferred("disabled",true)
		
		var wait_timer = get_tree().create_timer(3.0, true, false, true)
		if self.get_meta("collect_type") == "fast":
			speed_multiplier = 1.5
			_apply_speed_effect(speed_multiplier)
			$SpeedUpAudio.play()
			
		if self.get_meta("collect_type") == "slow":
			speed_multiplier = 0.5
			_apply_speed_effect(speed_multiplier)
			$SlowDownAudio.play()

		await wait_timer.timeout
		_apply_speed_effect(1.0)
		queue_free()

func _apply_speed_effect(multiplier: float) -> void:
	# Apply speed to all fall guys via Global signal
	Global.game_speed_multiplier = multiplier
	
	# Speed up animations
	var guys_node = get_node("../../Guys")
	if guys_node:
		for guy in guys_node.get_children():
			if guy.has_node("AnimatedSprite2D"):
				guy.get_node("AnimatedSprite2D").speed_scale = multiplier
