extends CharacterBody2D

const DEF_SPEED = 80.0 # unchanging base speed
const DEF_JUMP_VELOCITY = -175.0 # unchanging base jump vel

var speed = 80.0
var jump_velocity = -175.0

var death_time = 1
var too_heavy = false

var restart_time = 1

var jumping = false
var coyote_time = 0.06
var jump_available = true

var weight_mult = 4 # Amount Global.weight impacts jump height and speed.

@onready var weight_obj = preload("res://objects/weight.tscn")
@onready var weightstack_obj = preload("res://scenes/weight_stack.tscn")

@onready var sprite = $sprite
@onready var particle_crushed = $"Crushed Particles"

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	run_physics(delta)
	if Global.can_move:run_movement(delta)
	else: velocity.x = 0
	
	sprite.play(str(get_player_state())) # Get current state from get_player_state then play the anim
	# flip sprite based on dir
	
	## Drop weights
	if Input.is_action_just_pressed("drop") and Global.held_weights != [] and Global.can_move:
		var top_weight_pos = Global.held_weights.size() - 1 # Get the position of the top weight
		var weight_to_drop = Global.held_weights.pop_at(top_weight_pos) # Get value of top weight
		print(weight_to_drop)
		var weight_to_spawn = weight_to_drop # we will re-spawn the Global.weight that is being dropped :)
		Global.held_weights.remove_at(top_weight_pos) # Remove Global.weight from array.
		update_weight()
		
		## Global.weight is now removed from the player. Place it back to the world
		var instance = weight_obj.instantiate() # Create new Global.weight object
		instance.weight_value = str(weight_to_spawn) # Set the weight
		instance.position = position + Vector2(0,(top_weight_pos * -8) - 9) # Set position to top stack position
		get_parent().add_child(instance) # Add Global.weight to world
		#refresh_collisionshape()
		
	# Restart Level
	if Input.is_action_just_pressed("restart"):
		Global.restart_level()
	
	debug()
	move_and_slide()


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


func update_weight(): # Update current player Global.weight based on the 'inventory'
	Global.weight = 0
	jump_velocity = DEF_JUMP_VELOCITY
	speed = DEF_SPEED
	for x : int in Global.held_weights:
		Global.weight += x
	jump_velocity += (Global.weight * (weight_mult / 1.5))
	speed -= (Global.weight * weight_mult)
	
	if Global.weight > 15:
		Global.heaviness = 2
	elif Global.weight > 10:
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
		get_tree().create_timer(death_time).timeout.connect(die) # NOTE: If you restart the level before this is done, it can still activate and restart it again. Need to fix


func die():
	Global.can_move = false
	Global.heaviness = 7
	sprite.visible = false
	particle_crushed.emitting = true
	get_tree().create_timer(restart_time).timeout.connect(Global.restart_level)


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


func debug(): # Debug
	if Input.is_action_just_pressed("f1"):
		$camera/CanvasLayer.visible = !$camera/CanvasLayer.visible
	$"camera/CanvasLayer/Control/VBoxContainer/held weights".text = str("held: ", Global.held_weights)
	$"camera/CanvasLayer/Control/VBoxContainer/jump vel".text = str("jump vel: ", jump_velocity)
	$camera/CanvasLayer/Control/VBoxContainer/speed.text = str("speed: ", speed)
	$camera/CanvasLayer/Control/VBoxContainer/weight.text = str("weight: ", Global.weight," lb")
