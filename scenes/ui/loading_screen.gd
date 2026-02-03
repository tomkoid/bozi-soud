extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var status_label = $VBoxContainer/StatusLabel

var precompile_scene: Node2D
var precompile_canvas: CanvasLayer
var progress = 0.0

# Preloaded resources kept in memory to prevent re-compilation
var _cached_resources: Array = []
# Audio players kept alive to prevent re-buffering
var _audio_players: Array = []

func _ready() -> void:
	# Create an invisible precompile scene
	precompile_scene = Node2D.new()
	add_child(precompile_scene)
	precompile_scene.position = Vector2(-10000, -10000)  # Far offscreen
	
	# Create a canvas layer for UI shader precompilation
	precompile_canvas = CanvasLayer.new()
	precompile_canvas.layer = -100
	add_child(precompile_canvas)
	
	# Start precompilation process
	await get_tree().process_frame
	_start_precompilation()

func _start_precompilation() -> void:
	update_progress(3, "Loading shaders...")
	await get_tree().create_timer(0.05).timeout
	
	# Precompile shaders first (most important for stutter)
	await _precompile_shaders()
	
	update_progress(10, "Loading fonts...")
	await get_tree().create_timer(0.05).timeout
	
	# Precompile fonts and text rendering
	await _precompile_fonts()
	
	update_progress(20, "Loading particles...")
	await get_tree().create_timer(0.05).timeout
	
	# Precompile particle shaders
	await _precompile_particles()
	
	update_progress(30, "Loading entities...")
	await get_tree().create_timer(0.05).timeout
	
	# Precompile entity scenes (fall_guy, bad_guy)
	await _precompile_entities()
	
	update_progress(45, "Loading collectibles...")
	await get_tree().create_timer(0.05).timeout
	
	# Precompile collectible scenes
	await _precompile_collectibles()
	
	update_progress(55, "Loading animations...")
	await get_tree().create_timer(0.05).timeout
	
	# Precompile additional animations (angel, etc)
	await _precompile_animations()
	
	update_progress(65, "Loading audio...")
	await get_tree().create_timer(0.05).timeout
	
	# Preload and warm up audio
	await _precompile_audio()
	
	update_progress(75, "Loading UI...")
	await get_tree().create_timer(0.05).timeout
	
	# Precompile UI elements
	await _precompile_ui()
	
	update_progress(82, "Testing speed effects...")
	await get_tree().create_timer(0.05).timeout
	
	# Test time scale changes
	await _precompile_time_scale()
	
	update_progress(88, "Loading game assets...")
	await get_tree().create_timer(0.05).timeout
	
	# Preload main scenes
	await _preload_scenes()
	
	update_progress(95, "Warming up...")
	await get_tree().create_timer(0.05).timeout
	
	# Final warmup - render multiple frames
	await _final_warmup()
	
	update_progress(100, "Ready!")
	await get_tree().create_timer(0.2).timeout
	
	# Clean up precompile scene before transition
	_cleanup_precompile()
	
	# Go to main menu
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")

func _precompile_shaders() -> void:
	# Load and compile the vignette shader by creating a ColorRect with it
	var shader = load("res://scenes/UI.gdshader")
	_cached_resources.append(shader)
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("outerRadius", 0.886)
	shader_material.set_shader_parameter("MainAlpha", 0.675)
	shader_material.set_shader_parameter("vignette_color", Color(0, 0, 0, 1))
	_cached_resources.append(shader_material)
	
	var color_rect = ColorRect.new()
	color_rect.material = shader_material
	color_rect.size = Vector2(200, 200)
	color_rect.position = Vector2(-10000, -10000)
	precompile_canvas.add_child(color_rect)
	
	# Render multiple frames with varying alpha to ensure shader compiles all paths
	for i in range(10):
		color_rect.modulate.a = float(i) / 10.0
		shader_material.set_shader_parameter("MainAlpha", float(i) / 10.0)
		await get_tree().process_frame
	
	await get_tree().create_timer(0.3).timeout

func _precompile_fonts() -> void:
	# Load all fonts used in the game
	var fonts = [
		"res://assets/fonts/Jersey15-Regular.ttf",
		"res://assets/fonts/VCR_OSD_MONO_1.001.ttf",
		"res://assets/fonts/AnglicanText.ttf",
	]
	
	for font_path in fonts:
		if ResourceLoader.exists(font_path):
			var font = load(font_path)
			_cached_resources.append(font)
	
	# Create labels with various text to pre-render font glyphs
	var test_texts = [
		"0123456789",
		"Score: 999999",
		"Lives: 3",
		"GAME OVER",
		"Final Trial",
		"next reset: 10s",
	]
	
	for text in test_texts:
		var label = Label.new()
		label.text = text
		label.position = Vector2(-10000, -10000)
		precompile_canvas.add_child(label)
		await get_tree().process_frame
	
	# Create RichTextLabel with BBCode effects (shake effect causes stutter)
	var rtl = RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.text = "[shake rate=80.0 level=10 connected=1]3[/shake]"
	rtl.size = Vector2(100, 50)
	rtl.position = Vector2(-10000, -10000)
	precompile_canvas.add_child(rtl)
	
	# Let the shake effect render for several frames
	for i in range(30):
		await get_tree().process_frame
	
	await get_tree().create_timer(0.3).timeout

func _precompile_particles() -> void:
	# Create multiple particle instances to trigger shader compilation
	var particle_scene = load("res://scenes/misc/hit_particles.tscn")
	_cached_resources.append(particle_scene)
	
	# Create more particles and let them run longer
	for i in range(10):
		var particles = particle_scene.instantiate()
		precompile_scene.add_child(particles)
		particles.emitting = true
		await get_tree().process_frame
	
	# Wait for particles to fully render and compile shaders
	await get_tree().create_timer(0.8).timeout
	
	# Clean up particle instances
	for child in precompile_scene.get_children():
		child.queue_free()
	await get_tree().process_frame

func _precompile_entities() -> void:
	# Precompile fall_guy and bad_guy scenes to prevent first-spawn stutter
	var fall_guy_scene = load("res://scenes/entities/fall_guy.tscn")
	var bad_guy_scene = load("res://scenes/entities/bad_guy.tscn")
	_cached_resources.append(fall_guy_scene)
	_cached_resources.append(bad_guy_scene)
	
	# Create a mock Player node with PlayerAS for fall_guy.gd's @onready reference
	var mock_player = Node2D.new()
	mock_player.name = "Player"
	var mock_player_as = AnimatedSprite2D.new()
	mock_player_as.name = "PlayerAS"
	mock_player.add_child(mock_player_as)
	precompile_scene.add_child(mock_player)
	
	# Create multiple instances of each to ensure thorough compilation
	var instances = []
	for scene in [fall_guy_scene, bad_guy_scene]:
		for j in range(5):
			var instance = scene.instantiate()
			instance.set_meta("type", "good")  # Prevent null errors
			instance.position = Vector2(j * 100, 0)
			precompile_scene.add_child(instance)
			instances.append(instance)
			
			# Play all animations to compile them
			var anim_sprite = instance.get_node_or_null("AnimatedSprite2D")
			if anim_sprite:
				anim_sprite.play("run")
		
		await get_tree().process_frame
	
	# Let animations play for a bit
	await get_tree().create_timer(0.5).timeout
	
	# Switch to jump animation
	for child in precompile_scene.get_children():
		var anim_sprite = child.get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.play("jump")
	
	await get_tree().create_timer(0.5).timeout
	
	# Simulate physics interactions
	for child in precompile_scene.get_children():
		if child is CharacterBody2D:
			child.velocity = Vector2(100, -500)
			child.move_and_slide()
	
	await get_tree().create_timer(0.3).timeout
	
	# Clean up entity instances
	for child in precompile_scene.get_children():
		child.queue_free()
	await get_tree().process_frame

func _precompile_collectibles() -> void:
	# Precompile game_collect scene to prevent first-pickup stutter
	var collect_scene = load("res://scenes/entities/game_collect.tscn")
	_cached_resources.append(collect_scene)
	
	# Create instances for both fast and slow animations
	for anim_type in ["fast", "slow"]:
		var instance = collect_scene.instantiate()
		instance.set_meta("collect_type", anim_type)
		instance.animation = anim_type
		
		# Add DespawnTimer before adding to tree (required by game_collect.gd _ready)
		var despawn_timer = Timer.new()
		despawn_timer.wait_time = 999.0
		despawn_timer.name = "DespawnTimer"
		instance.add_child(despawn_timer)
		
		precompile_scene.add_child(instance)
		await get_tree().process_frame
		
		# Stop the timer to prevent any timeout during precompile
		despawn_timer.stop()
		
		# Play animations to compile them
		var collect_anim = instance.get_node_or_null("CollectAnim")
		if collect_anim:
			collect_anim.play(anim_type)
		
		var bubble_sprite = instance.get_node_or_null("BubblePinkSprite")
		if bubble_sprite:
			bubble_sprite.play("default")
			await get_tree().process_frame
			bubble_sprite.play("bubble_destroy")
		
		var anim_player = instance.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.play("fadein")
			await get_tree().process_frame
			anim_player.play("fadeout")
		
		await get_tree().process_frame
	
	await get_tree().create_timer(0.4).timeout
	
	# Clean up collectible instances
	for child in precompile_scene.get_children():
		child.queue_free()
	await get_tree().process_frame

func _precompile_animations() -> void:
	# Precompile angel scene animations
	var angel_scene = load("res://scenes/entities/angel.tscn")
	_cached_resources.append(angel_scene)
	
	var angel = angel_scene.instantiate()
	precompile_scene.add_child(angel)
	
	# Play all angel animations
	angel.play("idle")
	await get_tree().create_timer(0.3).timeout
	angel.play("cry")
	await get_tree().create_timer(0.3).timeout
	
	# Precompile player scene
	var player_scene = load("res://scenes/player/player.tscn")
	_cached_resources.append(player_scene)
	
	var player = player_scene.instantiate()
	precompile_scene.add_child(player)
	await get_tree().process_frame
	
	# Play player animations if any
	var player_as = player.get_node_or_null("PlayerAS")
	if player_as:
		if player_as.sprite_frames:
			for anim_name in player_as.sprite_frames.get_animation_names():
				player_as.play(anim_name)
				for i in range(10):
					await get_tree().process_frame
	
	await get_tree().create_timer(0.3).timeout
	
	# Clean up
	for child in precompile_scene.get_children():
		child.queue_free()
	await get_tree().process_frame

func _precompile_audio() -> void:
	# Preload all audio files to prevent first-play stutter
	var audio_files = [
		"res://assets/sounds/sound_effects/collect.mp3",
		"res://assets/sounds/sound_effects/slowdowncollect.mp3",
		"res://assets/sounds/sound_effects/lifelost.mp3",
		"res://assets/sounds/sound_effects/heartbeat.mp3",
		"res://assets/sounds/ambient/ml_sonata.mp3",
		"res://assets/sounds/ambient/menu_ambient.mp3",
	]
	
	for audio_path in audio_files:
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			_cached_resources.append(audio_stream)
			
			# Create a player and play at zero volume to warm up the audio system
			var player = AudioStreamPlayer.new()
			player.stream = audio_stream
			player.volume_db = -80  # Silent
			add_child(player)
			player.play()
			_audio_players.append(player)
			await get_tree().process_frame
	
	# Let audio warm up longer
	await get_tree().create_timer(0.5).timeout
	
	# Stop all audio players
	for player in _audio_players:
		player.stop()

func _precompile_ui() -> void:
	# Load UI scene to precompile all UI elements
	var ui_scene = load("res://scenes/UI.tscn")
	_cached_resources.append(ui_scene)
	
	var ui = ui_scene.instantiate()
	precompile_canvas.add_child(ui)
	
	# Render several frames
	for i in range(10):
		await get_tree().process_frame
	
	await get_tree().create_timer(0.2).timeout
	
	# Load and precompile transition screen animations
	var transition_scene = load("res://scenes/ui/transition_screen.tscn")
	_cached_resources.append(transition_scene)
	
	var transition = transition_scene.instantiate()
	precompile_canvas.add_child(transition)
	
	var anim_player = transition.get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.play("fade_to_black")
		await get_tree().create_timer(0.2).timeout
		anim_player.play("fade_to_normal")
		await get_tree().create_timer(0.2).timeout
	
	# Load end screen (wrap in Control for positioning)
	var end_screen_scene = load("res://scenes/ui/end_screen.tscn")
	_cached_resources.append(end_screen_scene)
	
	var end_screen = end_screen_scene.instantiate()
	var end_screen_wrapper = Control.new()
	end_screen_wrapper.position = Vector2(-10000, -10000)
	end_screen_wrapper.add_child(end_screen)
	precompile_canvas.add_child(end_screen_wrapper)
	
	for i in range(5):
		await get_tree().process_frame
	
	# Load pause menu (wrap in Control for positioning)
	var pause_menu_scene = load("res://scenes/ui/pause_menu.tscn")
	_cached_resources.append(pause_menu_scene)
	
	var pause_menu = pause_menu_scene.instantiate()
	var pause_menu_wrapper = Control.new()
	pause_menu_wrapper.position = Vector2(-10000, -10000)
	pause_menu_wrapper.add_child(pause_menu)
	precompile_canvas.add_child(pause_menu_wrapper)
	
	for i in range(5):
		await get_tree().process_frame

func _precompile_time_scale() -> void:
	# Test different time scales to precompile related code
	Engine.time_scale = 1.5
	await get_tree().create_timer(0.1, true, false, true).timeout
	
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.1, true, false, true).timeout
	
	Engine.time_scale = 1.0
	await get_tree().create_timer(0.1, true, false, true).timeout

func _preload_scenes() -> void:
	# Preload critical scenes to cache them
	var scenes_to_preload = [
		"res://scenes/ui/menu.tscn",
		"res://scenes/level1.tscn",
		"res://scenes/objects/platform.tscn",
	]
	
	for scene_path in scenes_to_preload:
		if ResourceLoader.exists(scene_path):
			var scene = load(scene_path)
			_cached_resources.append(scene)
			await get_tree().process_frame

func _final_warmup() -> void:
	# Force multiple render frames to ensure everything is compiled
	for i in range(30):
		await get_tree().process_frame
	
	# Trigger garbage collection to avoid GC during gameplay
	# Note: This is a hint to the engine
	await get_tree().create_timer(0.1).timeout

func _cleanup_precompile() -> void:
	# Clean up any remaining children in precompile_scene
	for child in precompile_scene.get_children():
		child.queue_free()
	
	# Clean up canvas layer children
	for child in precompile_canvas.get_children():
		child.queue_free()
	
	# Clean up audio players
	for player in _audio_players:
		if is_instance_valid(player):
			player.queue_free()
	_audio_players.clear()
	
	# Note: _cached_resources is intentionally kept to prevent garbage collection

func update_progress(value: float, status: String) -> void:
	progress = value
	progress_bar.value = value
	status_label.text = status
	await get_tree().process_frame
