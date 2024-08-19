extends CharacterBody2D

const DEF_SPEED = 80.0 # unchanging base speed
const DEF_JUMP_VELOCITY = -175.0 # unchanging base jump vel

var speed = 80.0
var jump_velocity = -175.0

var too_heavy = false

var jumping = false
var coyote_time = 0.06
var jump_available = true

var enable_physics = true

var weight_mult = 4 # Amount that a weight impacts jump height and speed.

@onready var weight_obj = preload("res://scenes/objects/weight.tscn")
@onready var weightstack_obj = preload("res://scenes/weight_stack.tscn")

@onready var hands = $hands
@onready var sprite = $sprite
@onready var particle_crushed = $"Crushed Particles"

@onready var death_timer = $"Death Timer"
@onready var restart_timer = $"Restart Timer"

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if enable_physics:run_physics(delta)
	else: velocity.x = 0;velocity.y = 0
	if Global.can_move:run_movement(delta)
	else: velocity.x = 0; $sprite.play("idle")
	
	sprite.play(str(get_player_state())) # Get current state from get_player_state then play the anim
	# flip sprite based on dir
	
	position_hands(delta)
	
	## Drop weights
	if Input.is_action_just_pressed("drop") and Global.held_weights != [] and Global.can_move:
		drop_weight(false)
		
	# Restart Level
	if Input.is_action_just_pressed("restart"):
		death_timer.stop()
		restart_timer.stop()
		Global.restart_level()
	
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
		var instance = weight_obj.instantiate() # Create new weight object
		instance.weight_value = str(weight_to_spawn) # Set the weight
		# If all the weights are being dropped (upon death), place them in their stack pos. Otherwise place at player
		if all:
			instance.position = position + Vector2(0,(top_weight_pos * -8) - 8) # Set position to top stack position
		else:
			instance.position = position + Vector2(0,0) # Set position to player's position (plus an offset if needed)
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
	if Input.is_action_pressed("jump") and jump_available: 
		jump_available = false
		velocity.y = jump_velocity
		jumping = true
	# Movement
	var direction := Input.get_axis("left", "right")
	if direction: velocity.x = direction * speed
	else: velocity.x = move_toward(velocity.x, 0, speed)
	if Input.is_action_just_pressed("left"): sprite.flip_h = true 
	if Input.is_action_just_pressed("right"): sprite.flip_h = false


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
		Global.heaviness = 5
	if Global.weight > 10:
		Global.heaviness = 3
	elif Global.weight > 5:
		Global.heaviness = 1
	else:
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
	$death.play()
	#drop_weight(true)
	Global.can_move = false
	enable_physics = false
	Global.heaviness = 7
	hands.visible = false
	sprite.visible = false
	particle_crushed.emitting = true
	hands.visible = false
	restart_timer.start()


func _on_restart_timer_timeout() -> void:
	Global.restart_level()


func add_to_weightstack(weight): # Called when picking up a weight. Creates the visual
	var instance = weightstack_obj.instantiate()
	instance.weight_value = weight
	instance.id = Global.held_weights.size() # if weights ID is larger than the size of the stack array, it shouldnt exist!
	get_parent().add_child(instance)


func get_player_state():
	if too_heavy == true:
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
	else:
		hands.frame = 1 
		match sprite.flip_h: # position based on player orientation
			true:hands.global_position = hands.global_position.lerp(global_position + Vector2(0,6),delta*80)
			false:hands.global_position = hands.global_position.lerp(global_position + Vector2(1,6),delta*80)
		if sprite.frame == 1: # if player is in the hoppy part of walk anim, move arms up a pixel
			hands.global_position = hands.global_position + Vector2(0,-1)
		


func debug(): # Debug
	if Input.is_action_just_pressed("f1"):
		$camera/CanvasLayer.visible = !$camera/CanvasLayer.visible
	$"camera/CanvasLayer/Control/VBoxContainer/held weights".text = str("held: ", Global.held_weights)
	$"camera/CanvasLayer/Control/VBoxContainer/jump vel".text = str("jump vel: ", jump_velocity)
	$camera/CanvasLayer/Control/VBoxContainer/speed.text = str("speed: ", speed)
	$camera/CanvasLayer/Control/VBoxContainer/weight.text = str("weight: ", Global.weight," lb")
