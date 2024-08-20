extends Node2D

@onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(global_position)
	Global.confine = global_position.x
