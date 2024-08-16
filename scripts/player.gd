extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

var weight = 0 # 0 (no weight) to 150 (10 weights) each weight adds 15

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = (JUMP_VELOCITY + weight)

	# Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
