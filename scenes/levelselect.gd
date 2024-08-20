extends Control
@onready var lv1 = $"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/1"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



	


func _on__pressed() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/levels/lv1.tscn"))
