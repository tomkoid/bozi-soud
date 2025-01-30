extends CharacterBody2D

const max_speed = 600
const accel = 700
const friction = 1000

var input = Vector2.ZERO

func _physics_process(delta):
	player_movement(delta)

func get_input():
	input.x = int(Input.is_action_pressed("right_move")) - int(Input.is_action_pressed("left_move"))
	return input.normalized()

func player_movement(delta):
	input = get_input()
	
	
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)

	move_and_slide()
