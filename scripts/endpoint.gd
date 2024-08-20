extends Node2D

@export var next_level : PackedScene
@export var inital_on : bool = false

@onready var hitbox = $Area2D

func _ready():
	if !inital_on:
		visible = false
		hitbox.collision_layer = 0
		hitbox.collision_mask = 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and next_level != null:
		Global.reset_globals()
		get_tree().change_scene_to_packed(next_level)

func turn_on():
	visible = true
	hitbox.collision_layer = 1 | 2
	hitbox.collision_mask = 1 | 2
