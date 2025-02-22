extends Sprite2D

@onready var GameTimer = get_node("../../GameTimer")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "FallGuy" or "BadGuy":
		self.set_meta("started", "true")
		var StartSpawnRate = GameTimer.wait_time
		print(StartSpawnRate)
		$".".visible = false # instead of calling queue_free() we make the sprite invisible
		$Area2D/CollisionShape2D.set_deferred("disabled",true) # and disable the collision shape, otherwise the timer wouldn't work 
		 
		print(body.get_meta("collect_type"))
		var wait_timer = get_tree().create_timer(5.0)
		if self.get_meta("collect_type") == "fast":
			GameTimer.wait_time /= 2
			
		if self.get_meta("collect_type") == "slow":
			GameTimer.wait_time *= 2

		await wait_timer.timeout
		GameTimer.wait_time = StartSpawnRate
		queue_free()
