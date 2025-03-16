extends Sprite2D

@onready var GameTimer = get_node("../../GameTimer")
@onready var despawn_timer = $DespawnTimer

@export var animation = ""

func _ready():
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(_on_despawn_timer)
	despawn_timer.start()
	$CollectAnim.play(animation)

func _on_despawn_timer():
	visible = false
	$Area2D/CollisionShape2D.set_deferred("disabled",true)
	await get_tree().create_timer(10.0).timeout
	print("ENTITY DESPAWN")
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "FallGuy" or "BadGuy":
		self.set_meta("started", "true")
		var StartSpawnRate = GameTimer.wait_time
		$".".visible = false # instead of calling queue_free() we make the sprite invisible
		$Area2D/CollisionShape2D.set_deferred("disabled",true) # and disable the collision shape, otherwise the timer wouldn't work 
		#$Area2D/CollisionShape2D.queue_free() 
		
		var wait_timer = get_tree().create_timer(5.0)
		if self.get_meta("collect_type") == "fast":
			GameTimer.wait_time /= 2
			
		if self.get_meta("collect_type") == "slow":
			GameTimer.wait_time *= 2

		await wait_timer.timeout
		GameTimer.wait_time = StartSpawnRate
		queue_free()
