extends CharacterBody2D

const DEF_SPEED = 80.0 # unchanging base speed
const DEF_JUMP_VELOCITY = -175.0 # unchanging base jump vel

var speed = 80.0
var jump_velocity = -175.0

var death_time = 1

var coyote_time = 0.06
var jump_available = true

var weight_mult = 4 # Amount Global.weight impacts jump height and speed.

@onready var world = "res://scenes/world.tscn"
@onready var weight_obj = preload("res://objects/weight.tscn")
@onready var weightstack_obj = preload("res://scenes/weight_stack.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var particle_crushed = $"Crushed Particles"

func _ready() -> void:
	refresh_collisionshape()


func _physics_process(delta: float) -> void:
	run_physics(delta)
	
	## Drop weights
	if Input.is_action_just_pressed("drop") and Global.held_weights != [] and Global.weight <= 20:
		var top_weight = Global.held_weights.size() - 1 # Get the position of the top weight
		var weight_to_drop = Global.held_weights.pop_at(top_weight) # Get value of top weight
		print(weight_to_drop)
		var weight_to_spawn = weight_to_drop # we will re-spawn the Global.weight that is being dropped :)
		Global.held_weights.remove_at(top_weight) # Remove Global.weight from array.
		update_weight()
		
		## Global.weight is now removed from the player. Place it back to the world
		var instance = weight_obj.instantiate() # Create new Global.weight object
		instance.weight_value = str(weight_to_spawn) # Set the weight
		instance.position = position + Vector2(0,0) # Set position to player's position (plus an offset if needed)
		get_parent().add_child(instance) # Add Global.weight to world
		refresh_collisionshape()

	print(int(global_position.x / 8))
	
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
	
	# Jumping
	if Input.is_action_pressed("jump") and jump_available: 
		jump_available = false
		velocity.y = jump_velocity
		
	var direction := Input.get_axis("left", "right") # Movement
	if direction: velocity.x = direction * speed
	else: velocity.x = move_toward(velocity.x, 0, speed)


func coyote_timeout():
	jump_available = false


func update_weight(): # Update current player Global.weight based on the 'inventory'
	Global.weight = 0
	jump_velocity = DEF_JUMP_VELOCITY
	speed = DEF_SPEED
	for x : int in Global.held_weights:
		Global.weight += x
	jump_velocity += (Global.weight *  weight_mult)
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
		Global.weight = 21 # Kinda silly but this is done so the dial in the UI doesnt look weird
		get_tree().create_timer(death_time).timeout.connect(die)


func die():
	Global.heaviness = 8
	sprite.visible = false
	particle_crushed.emitting = true


func add_to_weightstack(weight): # Called when picking up a weight. Creates the visual
	var instance = weightstack_obj.instantiate()
	instance.weight_value = weight
	instance.id = Global.held_weights.size() # if weights ID is larger than the size of the stack array, it shouldnt exist!
	get_parent().add_child(instance)
	refresh_collisionshape()


func refresh_collisionshape(): # Sets the player collision based on the stack height.
	$CollisionShape2D.shape.extents = Vector2(3,3) # default
	$CollisionShape2D.position = Vector2(1,2) # default
	
	for x in Global.held_weights:
		$CollisionShape2D.position += Vector2(0,-4)
		$CollisionShape2D.shape.extents += Vector2(0,4)


func debug(): # Debug
	if Input.is_action_just_pressed("f1"):
		$camera/CanvasLayer.visible = !$camera/CanvasLayer.visible
	$"camera/CanvasLayer/Control/VBoxContainer/held weights".text = str("held: ", Global.held_weights)
	$"camera/CanvasLayer/Control/VBoxContainer/jump vel".text = str("jump vel: ", jump_velocity)
	$camera/CanvasLayer/Control/VBoxContainer/speed.text = str("speed: ", speed)
	$camera/CanvasLayer/Control/VBoxContainer/weight.text = str("weight: ", Global.weight," lb")
