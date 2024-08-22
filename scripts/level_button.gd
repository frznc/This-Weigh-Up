extends Button

@onready var main = get_parent().get_parent().get_parent().get_parent().get_parent()

func _on_pressed() -> void:
	main.level_change(name)
