extends CharacterBody2D

const max_speed = 800
const accel = 1000
const friction = 2500
const JUMP_VELOCITY = -1500

var input = Vector2.ZERO

func _physics_process(delta):
	player_movement(delta)
	position.x = get_global_mouse_position().x
	position.y = 500

#func get_input():
	#input.x = int(Input.is_action_pressed("right_move")) - int(Input.is_action_pressed("left_move"))
	#return input.normalized()

func player_movement(delta):
	#input = get_input()
	
	
	#if input == Vector2.ZERO:
		#if velocity.length() > (friction * delta):
			#velocity -= velocity.normalized() * (friction * delta)
		#else:
			#velocity = Vector2.ZERO
	#else:
		#velocity += (input * accel * delta)
		#velocity = velocity.limit_length(max_speed)

	move_and_slide()


#func _on_area_2d_area_entered(area):
	#$AnimatedSprite2D.play("bounce")
	#$"../FallGuy".velocity.y = JUMP_VELOCITY
	#position.y = 510
	#await get_tree().create_timer(0.25).timeout
	#position.y = 500
