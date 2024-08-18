extends Node2D

@export var next_level : PackedScene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and next_level != null:
		Global.reset_globals()
		get_tree().change_scene_to_packed(next_level)
