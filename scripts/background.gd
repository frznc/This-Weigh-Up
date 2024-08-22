extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in get_children():
		x.play("default")
