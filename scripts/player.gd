extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

@onready var world = "res://scenes/world.tscn"
@onready var weight = "res://scenes/weight.tscn"

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = (JUMP_VELOCITY + (Global.weights * 15))

	# Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Drop weights
	if Input.is_action_just_pressed("drop") and Global.weights > 0:
		Global.weights -= 1
		# Add a weight back to the world at this position. i have no idea how to do this
	
	move_and_slide()
