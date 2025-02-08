extends CharacterBody2D


const SPEED = 300.0

var jump_pos_x = randi_range(20,200)
var first_jump = false
var jump_velocity
var count = 0
@export var dir = 1


func _ready() -> void:
	var guy_type = get_meta("type")
	
	if guy_type == "good":
		jump_velocity = randi_range(-350, -250)
	if guy_type == "bad":
		jump_velocity = randi_range(-500, -400)
	
	if dir == 1:
		jump_pos_x = randi_range(50, 200)
	elif dir == -1:
		jump_pos_x = randi_range(950, 1075)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor() and $AnimatedSprite2D.animation == "jump":
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.play("run")

	# Handle jump.
	if is_on_floor() and not first_jump:
		if (dir == 1 and position.x >= jump_pos_x) or (dir == -1 and position.x <= jump_pos_x):
			first_jump = true
			$AnimatedSprite2D.play("jump")
			velocity.y = jump_velocity
		

	velocity.x = dir * SPEED
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_node("../../BoingEffect").play()
		$"../../Player/PlayerAS".stop()
		velocity.y = -1500
		$"../../Player/PlayerAS".play("bounce")
		
