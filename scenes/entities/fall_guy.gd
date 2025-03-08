extends CharacterBody2D


const SPEED = 300.0
var theta: float

var jump_pos_x = randi_range(20,200)
var first_jump = false
var bridge_jump = false
var jump_velocity
var count = 0
@export var dir = 1
@export var tilt: bool = true
@export var tilt_speed: float = 0.01

@onready var player_as = get_node("../../Player/PlayerAS")
@onready var guy_as = $AnimatedSprite2D


func _ready() -> void:
	var guy_type = get_meta("type")
	
	if guy_type == "good":
		jump_velocity = randi_range(-500, -400)
	if guy_type == "bad":
		jump_velocity = randi_range(-350, -250)
	
	if dir == 1:
		jump_pos_x = randi_range(50, 200)
	elif dir == -1:
		jump_pos_x = randi_range(950, 1075)

func _physics_process(delta):	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor() and guy_as.animation == "jump":
		guy_as.stop()
		guy_as.play("run")

	# Handle jump.
	if is_on_floor() and not first_jump:
		if (dir == 1 and position.x >= jump_pos_x) or (dir == -1 and position.x <= jump_pos_x):
			first_jump = true
			guy_as.play("jump")
			velocity.y = jump_velocity
			bridge_jump = true
	
	# tilt fall guy a bit
	if not is_on_floor() and bridge_jump:
		theta = wrapf(atan2(0.0, 2.0) - 2.0, PI * dir, PI)
		rotation += clamp(TAU * tilt_speed * delta, 0, abs(theta)) * sign(theta)
		


	velocity.x = dir * SPEED
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Global.emit_player_particles.emit()

		get_node("../../BoingEffect").play()
		player_as.stop()
		velocity.y = -1500
		player_as.play("bounce")
		
