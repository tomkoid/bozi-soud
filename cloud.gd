extends CharacterBody2D


const SPEED = 500.0



func _physics_process(delta): #pohyb oblacku

	var direction = Input.get_axis("left_move", "right_move")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
