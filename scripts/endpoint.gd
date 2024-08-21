extends Node2D

@export var next_level : PackedScene
@export var initial_on : bool = false

@onready var hitbox = $Area2D

func _ready():
	if !initial_on:
		visible = false
		hitbox.collision_layer = 0
		hitbox.collision_mask = 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and next_level != null:
		Global.reset_globals()
		if !initial_on:
			get_tree().change_scene_to_packed(next_level)
		else:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

func turn_on():
	visible = true
	hitbox.collision_layer = 1 | 2
	hitbox.collision_mask = 1 | 2
	
func turn_off():
	visible = false
	hitbox.collision_layer = 0 | 0
	hitbox.collision_mask = 0 | 0
