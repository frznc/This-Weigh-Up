extends Control

var enabled = true

func _ready() -> void:
	if enabled:
		$CanvasLayer/PanelContainer/MarginContainer/Label.text = str(name)
