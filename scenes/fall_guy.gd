extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var jump_pos_x = randi_range(150,350)
var first_jump = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if position.x >= jump_pos_x and is_on_floor() and not first_jump:
		first_jump = true
		velocity.y = JUMP_VELOCITY

	velocity.x = 1 * SPEED
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	pass # Replace with function body.
