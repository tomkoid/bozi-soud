extends Sprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "FallGuy" or "BadGuy":
		var StartSpawnRate = %GameTimer.wait_time 
		$".".visible = false # instead of calling queue_free() we make the sprite invisible
		$Area2D/CollisionShape2D.set_deferred("disabled",true) # and disable the collision shape, otherwise the timer wouldn't work 
		
		
		if self.name == "GameSpeedCollect":
			%GameTimer.wait_time /= 2
			await get_tree().create_timer(5.0).timeout
			%GameTimer.wait_time = StartSpawnRate
			queue_free()
		if self.name == "GameSlowCollect":
			%GameTimer.wait_time *= 2
			await get_tree().create_timer(5.0).timeout
			%GameTimer.wait_time = StartSpawnRate
			queue_free()
		else:
			queue_free()
