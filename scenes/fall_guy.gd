extends CharacterBody2D


const SPEED = 300.0

var jump_pos_x = randi_range(0,250)
var first_jump = false
var jump_velocity = -400

func _ready() -> void:
	jump_velocity = randi_range(-200, -800)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor() and $AnimatedSprite2D.animation == "jump":
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.play("run")

	# Handle jump.
	if position.x >= jump_pos_x and is_on_floor() and not first_jump:
		first_jump = true
		$AnimatedSprite2D.play("jump")
		velocity.y = jump_velocity

	velocity.x = 1 * SPEED
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:	
	if body.name == "Player":
		print("trigger")
		$"../../Player/PlayerAS".stop()
		$"../../Player/PlayerAS".play("bounce")
		velocity.y = -1500
		
		body.position.y = 510
		await get_tree().create_timer(0.25).timeout
		body.position.y = 500
