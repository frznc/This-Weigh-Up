extends Control

func _ready() -> void:
	$CanvasLayer/PanelContainer/MarginContainer/Label.text = str(name)
