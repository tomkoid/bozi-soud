extends CharacterBody2D


@export var SPEED = 300.0
var theta: float

var jump_pos_x = randi_range(20,200)
var first_jump = false
var bridge_jump = false
var jump_velocity
var count = 0
@export var dir = 1
@export var tilt: bool = true
@export var tilt_speed: float = 0.01

var bounced = false  # Track if fall guy just bounced

@onready var player_as = get_node("../../Player/PlayerAS")
@onready var guy_as = $AnimatedSprite2D


func _ready() -> void:
	var guy_type = get_meta("type")
	
	if guy_type == "good":
		jump_velocity = randi_range(-500, -400)
	if guy_type == "bad":
		jump_velocity = randi_range(-500, -400)
	
	if dir == 1:
		jump_pos_x = randi_range(50, 200)
	elif dir == -1:
		jump_pos_x = randi_range(950, 1075)

func _physics_process(delta):
	# Apply game speed multiplier to delta for smooth speed changes
	var adjusted_delta = delta * Global.game_speed_multiplier
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * adjusted_delta
		
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
		rotation += clamp(TAU * tilt_speed * adjusted_delta, 0, abs(theta)) * sign(theta)
		

	# Only set velocity.x if not bounced, or if back on floor
	if is_on_floor():
		bounced = false
	
	if not bounced:
		velocity.x = dir * SPEED
	
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# controller vibration
		if Global.input_method == Global.INPUT_SCHEMES.CONTROLLER:
			Input.start_joy_vibration(0, 0.5, 0.5, 0.1)

		Global.emit_player_particles.emit()

		get_node("../../BoingEffect").play()
		player_as.stop()
		
		# Apply bounce with player's momentum
		var player_velocity_x = 0
		if "last_velocity" in body:
			player_velocity_x = body.last_velocity.x
		
		# Set bounced flag to prevent velocity override
		bounced = true
		
		# Base upward velocity
		velocity.y = -1500
		
		# Player's direction always takes priority
		if abs(player_velocity_x) > 50:
			# Player is moving - use their direction
			velocity.x = player_velocity_x * 0.8
			
			# If player direction is opposite to fall guy's direction, change the fall guy's permanent direction
			if sign(player_velocity_x) != 0 and sign(player_velocity_x) != dir:
				dir = sign(player_velocity_x)
				guy_as.flip_h = (dir == -1)
		else:
			# Player is stationary - weak bounce in current direction
			velocity.x = dir * SPEED * 0.3
		
		player_as.play("bounce")
		
