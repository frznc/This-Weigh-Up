extends CharacterBody2D

const DEF_SPEED = 80.0 # unchanging base speed
const DEF_JUMP_VELOCITY = -180.0 # unchanging base jump vel

var speed = 80.0
var jump_velocity = -180.0

var too_heavy = false
var dead = false
var spinning = false # Overrides anim state to spinning

var jumping = false
var coyote_time = 0.06
var jump_available = true
var crouching = false
var jump_enabled = true

var enable_physics = true

var weight_mult = 4 # Amount that a weight impacts jump height and speed.

var standingonweights = []
var closest_weight = null
var closest_distance = INF

var spawned = false # spawn anim

@onready var weight_obj = preload("res://scenes/objects/weight.tscn")
@onready var weightstack_obj = preload("res://scenes/weight_stack.tscn")

@onready var hands = $hands
@onready var sprite = $sprite
@onready var particle_crushed = $"Crushed Particles"
@onready var particle_sweat = $"Sweat Particles"
@onready var pickup_sound = $pickup
@onready var drop_sound = $drop
@onready var camera = $camera

@onready var death_timer = $"Death Timer"
@onready var restart_timer = $"Restart Timer"

func _ready() -> void:
	if Music.musicplaying == false:
		Music.volume_db = -8
		Music.playmusic()
	hands.visible = false
	$"spawn particles".emitting = true
	$"Spawn Timer".start()
	global_position.y -= 5
	spinning = true
func _on_spawn_timer_timeout() -> void:
	hands.visible = true
	spawned = true
	spinning = false

func _physics_process(delta: float) -> void:
	# Get current state from get_player_state then play the anim
	sprite.play(str(get_player_state()))
		
	if spawned == true: # Everything else goes down here
		if enable_physics:run_physics(delta)
		else: velocity.x = 0;velocity.y = 0
		if Global.can_move && !dead: run_movement(delta)
		else: velocity.x = 0;

		# Orient player
		if !dead:
			if Input.is_action_just_pressed("left"): sprite.flip_h = true 
			if Input.is_action_just_pressed("right"): sprite.flip_h = false
		

		
		position_hands(delta)
		check_crouching()
		
		# Check which weight is closest to the player
		closest_weight = null
		closest_distance = INF
		
		for weight in Global.nearby_weights:
			var distance = global_position.distance_to(weight.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_weight = weight

		## Pickup weights
		if (Input.is_action_just_pressed("pickup")) and Global.nearby_weights != [] and !dead and !too_heavy and !jumping:
			Global.held_weights.push_back(closest_weight.weight_value) # Add weight to global array
			update_weight() # update the player's weight value
			add_to_weightstack(closest_weight.weight_value) # Add to the 'weight stack'
			pickup_sound.pitch_scale = 0.5 + (Global.held_weights.size() * 0.02)
			pickup_sound.play()
			closest_weight.queue_free()
			pass
		
		## Drop weights
		if Input.is_action_just_pressed("drop") and Global.held_weights != [] and !dead and !too_heavy:
			drop_sound.play()
			drop_weight(false)
			
		# Restart Level
		if Input.is_action_just_pressed("restart"):
			death_timer.stop()
			restart_timer.stop()
			Global.restart_level()
		
		# Set camera confine
		camera.limit_right = Global.confine - 4
		
		# Die if out of level
		if global_position.y > 64 and Global.can_move:
			Global.can_move = false
			die()
		
		debug()
		move_and_slide()


func drop_weight(all : bool):
	# How many weights are we dropping?
	var num_to_remove = 1
	if all:
		num_to_remove = Global.held_weights.size()
	
	while num_to_remove > 0:
		var top_weight_pos = Global.held_weights.size() - 1 # Get the position of the top weight
		var weight_to_drop = Global.held_weights.pop_at(top_weight_pos) # Get value of top weight
		var weight_to_spawn = weight_to_drop # we will re-spawn the weight that is being dropped :)
		Global.held_weights.remove_at(top_weight_pos) # Remove weight from array.
		update_weight()
		
		
		## Weight is now removed from the player. Place it back to the world
		var instance : RigidBody2D = weight_obj.instantiate() # Create new weight object
		instance.weight_value = str(weight_to_spawn) # Set the weight
		# If all the weights are being dropped (upon death), place them in their stack pos. Otherwise place at player
		if all:
			instance.global_position = Global.weight_positions[top_weight_pos+1]
		else:
			instance.position = position + Vector2(0,0) # Set position to player's position (plus an offset if needed)
			
		# Throw weight~!!!
		if crouching == false && !all:
			match sprite.flip_h: # throw in direction
				false:instance.apply_central_impulse(Vector2(20,-50))
				true:instance.apply_central_impulse(Vector2(-20,-50))
				
		get_parent().add_child(instance) # Add weight to world
		
		num_to_remove -= 1

func run_physics(delta):
	# Gravity
	if not is_on_floor():
		if jump_available:
			get_tree().create_timer(coyote_time).timeout.connect(coyote_timeout)
		velocity += get_gravity() * delta
	else:
		jump_available = true
		jumping = false


func run_movement(delta):
	# Jumping
	if Input.is_action_pressed("jump") and jump_available && !Input.is_action_pressed("down") && jump_enabled: 
		jump_available = false
		velocity.y = jump_velocity
		jumping = true
	# Movement
	var direction := Input.get_axis("left", "right")
	if direction: velocity.x = direction * speed
	else: velocity.x = move_toward(velocity.x, 0, speed)
	


func coyote_timeout():
	jump_available = false


func update_weight(): # Update current player weight based on the 'inventory'
	Global.weight = 0
	jump_velocity = DEF_JUMP_VELOCITY
	speed = DEF_SPEED
	for x : int in Global.held_weights:
		Global.weight += x
	jump_velocity += (Global.weight * (weight_mult / 1.5))
	speed -= (Global.weight * weight_mult)
	
	if Global.weight > 15:
		particle_sweat.amount = 4
		particle_sweat.emitting = true
		Global.heaviness = 5
	if Global.weight > 10:
		particle_sweat.amount = 2
		particle_sweat.emitting = true
		Global.heaviness = 3
	elif Global.weight > 5:
		particle_sweat.emitting = false
		Global.heaviness = 1
	else:
		particle_sweat.emitting = false
		Global.heaviness = 0
	
	# Player is carrying too much weight, kill them
	if Global.weight > 20:
		speed = 0
		jump_velocity = 0
		too_heavy = true
		Global.can_move = false
		Global.weight = 21 # Kinda silly but this is done so the dial in the UI doesnt look weird
		death_timer.start()
		$crush.play()


func _on_death_timer_timeout() -> void:
	die()


func die():
	dead = true
	$death.play()
	drop_weight(true)
	Global.can_move = false
	enable_physics = false
	Global.heaviness = 7
	hands.visible = false
	sprite.visible = false
	particle_crushed.emitting = true
	restart_timer.start()
	
func explode():
	$explode.play()
	enable_physics = false
	hands.visible = false
	sprite.visible = false
	$"explode particles".emitting = true

func _on_restart_timer_timeout() -> void:
	Global.restart_level()


func add_to_weightstack(weight): # Called when picking up a weight. Creates the visual
	var instance = weightstack_obj.instantiate()
	instance.weight_value = weight
	instance.id = Global.held_weights.size() # if weights ID is larger than the size of the stack array, it shouldnt exist!
	get_parent().add_child(instance)


func get_player_state(): # Determine player state (used for animations)
	if spinning == true:
		return "spinning"
	if too_heavy == true || crouching == true:
		return "crouch"
	if jumping == true:
		return "jump"
	if Input.is_action_pressed("right") || Input.is_action_pressed("left"):
		return "walk"
	return "idle"

func position_hands(delta):
	if Global.held_weights != []:
		hands.frame = 0 
		hands.global_position = hands.global_position.lerp(global_position + Vector2(0,Global.heaviness),delta * 30)
		match sprite.flip_h: # position based on player orientation
			true:hands.global_position = hands.global_position.lerp(global_position + Vector2(3,Global.heaviness),delta * 30)
			false:hands.global_position = hands.global_position.lerp(global_position + Vector2(1,Global.heaviness),delta * 30)
	elif crouching == false:
		hands.frame = 1 
		hands.global_position = hands.global_position.lerp(global_position + Vector2(0,6),delta*80)
		if sprite.frame == 1: # if player is in the hoppy part of walk anim, move arms up a pixel
			hands.global_position = hands.global_position + Vector2(0,-1)
	else:
		hands.frame = 1 
		hands.global_position = hands.global_position.lerp(global_position + Vector2(0,6),delta*70)
		hands.global_position = hands.global_position + Vector2(0,1)

func check_crouching():
	if Input.is_action_pressed("down") && is_on_floor():
		crouching = true
		Global.can_move = false
		
		# Remove collision from weight below
		if Input.is_action_just_pressed("jump"):
			velocity.y = 0
			for x in standingonweights:
				x.get_parent().collidable = false
			
	else:
		crouching = false
		Global.can_move = true

func debug(): # Debug
	if Input.is_action_just_pressed("f1"):
		print("debug")
		#$camera/CanvasLayer.visible = !$camera/CanvasLayer.visible
	$"camera/CanvasLayer/Control/VBoxContainer/held weights".text = str("held: ", Global.held_weights)
	$"camera/CanvasLayer/Control/VBoxContainer/jump vel".text = str("jump vel: ", jump_velocity)
	$camera/CanvasLayer/Control/VBoxContainer/speed.text = str("speed: ", speed)
	$camera/CanvasLayer/Control/VBoxContainer/weight.text = str("weight: ", Global.weight," lb")

func jump_cooldown(time):
	$jumpcooldown.wait_time = time
	$jumpcooldown.start()
	jump_enabled = false
func _on_jumpcooldown_timeout() -> void:
	jump_enabled = true

# Keep list of weights below the player (Used for crouching to move down)
func _on_floorchecker_body_entered(body: Node2D) -> void:
	if body.name == "Static Weight":
		standingonweights.push_front(body)
func _on_floorchecker_body_exited(body: Node2D) -> void:
	if body.name == "Static Weight":
		standingonweights.erase(body)
