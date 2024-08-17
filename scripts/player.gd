extends CharacterBody2D

const def_speed = 80.0 # unchanging base speed
const def_jump_velocity = -175.0 # unchanging base jump vel

var speed = 80.0
var jump_velocity = -175.0

var weight = 0
var weight_mult = 4 # Amount weight impacts jump height and speed.

@onready var world = "res://scenes/world.tscn"
@onready var weight_obj = preload("res://objects/weight.tscn")
@onready var weightstack_obj = preload("res://scenes/weight_stack.tscn")

func _ready() -> void:
	refresh_collisionshape()

func _physics_process(delta: float) -> void:
	
	run_physics(delta)
	
	
	# Drop weights
	if Input.is_action_just_pressed("drop") and Global.held_weights != []:
		var top_weight = Global.held_weights.size() - 1 # Get the position of the top weight
		var weight_to_drop = Global.held_weights.pop_at(top_weight) # Get value of top weight
		print(weight_to_drop)
		var weight_to_spawn = weight_to_drop # we will re-spawn the weight that is being dropped :)
		Global.held_weights.remove_at(top_weight) # Remove weight from array.
		update_weight()
	## weight is now removed from the player. lets place it back to the world!
		var instance = weight_obj.instantiate() # Create new weight object
		instance.weight_value = str(weight_to_spawn) # Set the weight
		instance.position = position + Vector2(0,0) # Set position to player's position (plus an offset if needed)
		get_parent().add_child(instance) # Add weight to world
		refresh_collisionshape()

		

	
	debug()
	move_and_slide()
	

func run_physics(delta):
	if not is_on_floor(): # Gravity
		velocity += get_gravity() * delta
		
	if Input.is_action_pressed("jump") and is_on_floor(): # Jumping
		velocity.y = jump_velocity
		
	var direction := Input.get_axis("left", "right") # Movement
	if direction: velocity.x = direction * speed
	else: velocity.x = move_toward(velocity.x, 0, speed)
	

func update_weight(): # Update current player weight based on the 'inventory'
	weight = 0
	jump_velocity = def_jump_velocity
	speed = def_speed
	for x in Global.held_weights:
		weight += int(x)
	jump_velocity += (weight *  weight_mult)
	speed -= (weight * weight_mult)
	
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
	$"camera/CanvasLayer/Control/VBoxContainer/held weights".text = str("held: ",Global.held_weights)
	$"camera/CanvasLayer/Control/VBoxContainer/jump vel".text = str("jump vel: ",jump_velocity)
	$camera/CanvasLayer/Control/VBoxContainer/speed.text = str("speed: ",speed)
	$camera/CanvasLayer/Control/VBoxContainer/weight.text = str("weight: ",weight," lb")
