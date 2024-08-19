extends Node2D

@onready var label = $Label

var start_y : int
var player_inside : bool = false
var weight_held : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_y = global_position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	weight_held = 0
	# Calculate the amount of weight on the scaled
	if player_inside:
		weight_held += Global.weight
	
	label.text = str(weight_held)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false
