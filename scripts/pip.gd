extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var blip = $blip

# Riveting code
func light_up(num : int):
	blip.pitch_scale = 0.75 + (float(num) / 10)
	blip.play()
	sprite.frame = 1

func dim():
	sprite.frame = 0
