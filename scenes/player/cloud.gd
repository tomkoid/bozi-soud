extends CharacterBody2D

const max_speed = 800
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
	#else:		count += randi_range(100, 110)

		#velocity += (input * accel * delta)
		#velocity = velocity.limit_length(max_speed)

	move_and_slide()

#func _on_area_2d_area_entered(area):
	#$AnimatedSprite2D.play("bounce")
	#position.y = 510
	#await get_tree().create_timer(0.25).timeout
	#position.y = 500


func _on_player_as_animation_finished() -> void:
	%PlayerAS.play("idle")
