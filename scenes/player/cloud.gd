extends CharacterBody2D

const KC_SPEED = 48000
const accel = 1000
const friction = 2500
const JUMP_VELOCITY = -1500

var input = Vector2.ZERO

@onready var hit_particles = preload("res://scenes/misc/hit_particles.tscn")
@onready var particles_container = get_node("../Particles")

func _ready():
	Global.emit_player_particles.connect(create_hit_particles)

func create_hit_particles():
	if Global.settings.s["particles"] == false:
		return

	var hp_instance: GPUParticles2D = hit_particles.instantiate()
	hp_instance.position.x = position.x
	hp_instance.position.y = position.y
	hp_instance.name = "HitParticle"
	particles_container.add_child(hp_instance)
	hp_instance.restart()
	
	hp_instance.finished.connect(remove_hit_particles.bind(hp_instance))

func remove_hit_particles(hp_instance: GPUParticles2D):
	particles_container.remove_child(hp_instance)

# func _physics_process(delta):
# 	player_movement(delta)

#func get_input():
	#input.x = int(Input.is_action_pressed("right_move")) - int(Input.is_action_pressed("left_move"))
	#return input.normalized()

func _physics_process(delta: float) -> void:
	var player_as_size:	int = 80
	var viewport_size = get_viewport().get_visible_rect().size

	if Global.input_method == Global.INPUT_SCHEMES.TOUCH_SCREEN:
		var next_position_x = get_global_mouse_position().x

		if next_position_x >= viewport_size.x - player_as_size:
			next_position_x = viewport_size.x - player_as_size
		elif next_position_x <= 0 + player_as_size:
			next_position_x = 0 + player_as_size

		position.x = next_position_x
	

	if Global.input_method == Global.INPUT_SCHEMES.KEYBOARD or Global.input_method == Global.INPUT_SCHEMES.CONTROLLER:
		# automatically handles strength of input
		var direction = Input.get_axis("left_move", "right_move")

		if direction:
			velocity.x = direction * KC_SPEED * delta
		else:
			velocity.x = move_toward(velocity.x, 0, KC_SPEED)

		if position.x >= viewport_size.x - player_as_size:
			position.x = viewport_size.x - player_as_size
		elif position.x <= 0 + player_as_size:
			position.x = 0 + player_as_size

	position.y = 500

	move_and_slide()

#func _on_area_2d_area_entered(area):
	#$AnimatedSprite2D.play("bounce")
	#position.y = 510
	#await get_tree().create_timer(0.25).timeout
	#position.y = 500


func _on_player_as_animation_finished() -> void:
	%PlayerAS.play("idle")
