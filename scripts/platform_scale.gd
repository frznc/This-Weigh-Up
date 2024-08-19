@tool
extends Node2D

@export var compare_scale : Node2D
@export_range(0, 30) var max : int
@export_range(-30, 0) var min : int

@onready var label = $Sprite2D/Label
@onready var max_spr = $"Max Point"
@onready var min_spr = $"Min Point"
@onready var sprite = $Sprite2D
@onready var timer = $"Movement Timer"

var start_y : int
var player_inside : bool = false
var weight_held : int = 0
var weights_inside = []
var max_weight_difference: int = 20  # Max weight difference to move the platform fully
var target_y: float  # Target Y position for this platform

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide min/max points
	#max.visible = false
	#min.visible = false
	
	# Find positions
	start_y = global_position.y - 4
	max_spr.position.y = -8 + (max * -8)
	min_spr.position.y = 8 + (min * -8)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(weights_inside)
	# Move min/max points in editor
	if Engine.is_editor_hint():
		max_spr.position.y = -8 + (max * -8)
		min_spr.position.y = 8 + (min * -8)

	# Reset the weight
	weight_held = 0

	# Calculate the amount of weight on the scale
	for weight in weights_inside:
		weight_held += weight.weight_value
	if player_inside:
		weight_held += Global.weight

	label.text = str(weight_held)

	# Check how this compares to the other scale
	if compare_scale != null:
		# Calculate the weight difference
		var weight_difference = weight_held - compare_scale.weight_held
		var movement_ratio = clamp(float(abs(weight_difference)) / max_weight_difference, 0, 1)
		# Map the difference to a wait time between 0.10 and 0.05
		timer.wait_time = lerp(0.12, 0.05, movement_ratio)

		# Calculate the target Y position using linear interpolation
		if weight_difference > 0:
			target_y = lerp(float(start_y), min_spr.position.y, movement_ratio)
		elif weight_difference < 0:
			target_y = lerp(float(start_y), max_spr.position.y, movement_ratio)
		elif weight_difference == 0:
			target_y = lerp(float(start_y), max_spr.position.y, movement_ratio)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true
	
	if body.name == "Static Weight":
		#print("Entered: ", body.get_parent().sitting_on)
		weights_inside.append(body.get_parent())


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false
	
	if body.name == "Static Weight":
		weights_inside.erase(body.get_parent())


func _on_movement_timer_timeout() -> void:
	# Move the sprite towards the target_y by 1 unit
	if abs(sprite.position.y - target_y) <= 1:
		sprite.position.y = target_y
	else:
		if sprite.position.y < target_y:
			sprite.position.y += 1
		elif sprite.position.y > target_y:
			sprite.position.y -= 1
