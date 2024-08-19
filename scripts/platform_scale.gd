@tool
extends Node2D

@export var compare_scale : Node2D
@export_range(0, 30) var max : int
@export_range(-30, 0) var min : int

@onready var label = $Sprite2D/StaticBody2D/Label
@onready var max_spr = $"Max Point"
@onready var min_spr = $"Min Point"
@onready var sprite = $Sprite2D

var start_y : int
var player_inside : bool = false
var weight_held : int = 0
var max_weight_difference: int = 20  # Max weight difference to move the platform fully
var target_y: float  # Target Y position for this platform

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide min/max points
	#max.visible = false
	#min.visible = false
	
	# Find positions
	start_y = global_position.y
	max_spr.position.y = -8 + (max * -8)
	min_spr.position.y = 8 + (min * -8)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move min/max points in editor
	if Engine.is_editor_hint():
		max_spr.position.y = start_y - (max * 8)
		min_spr.position.y = start_y + (min * 8)

	# Reset the weight
	weight_held = 0

	# Calculate the amount of weight on the scale
	if player_inside:
		weight_held += Global.weight

	label.text = str(weight_held)

	# Check how this compares to the other scale
	if compare_scale != null:
		# Calculate the weight difference
		var weight_difference = weight_held - compare_scale.weight_held
		var movement_ratio = clamp(float(abs(weight_difference)) / max_weight_difference, 0, 1)

		# Calculate the target Y position using linear interpolation
		var target_y = lerp(float(start_y), min_spr.position.y, movement_ratio)
		var other_target_y = lerp(float(compare_scale.start_y), compare_scale.min_spr.position.y, movement_ratio)

		# Move the platforms in opposite directions based on the weight difference
		if weight_difference > 0:
			sprite.global_position.y = target_y
			compare_scale.sprite.global_position.y = compare_scale.start_y - (target_y - start_y)
		elif weight_difference < 0:
			compare_scale.sprite.global_position.y = other_target_y
			sprite.global_position.y = start_y - (other_target_y - compare_scale.start_y)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false
