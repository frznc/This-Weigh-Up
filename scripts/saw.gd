extends Node2D

@onready var sprite = $AnimatedSprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.die()
	
	if body.name == "weight":
		print("hey")


func _on_rotation_timeout() -> void:
	# This is so shit. I don't know a better way
	if sprite.frame == 0:
		sprite.frame = 1
	else:
		sprite.frame = 0
