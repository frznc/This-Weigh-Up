extends Node2D
@export var level_title = ""
@export var star_background = true

@onready var background = preload("res://scenes/background.tscn")
@onready var title = preload("res://scenes/level_title.tscn")

func _ready() -> void:
	if star_background:
		var inst = background.instantiate()
		add_child(inst)
	if level_title != "":
		var inst = title.instantiate()
		inst.name = level_title
		add_child(inst)


func _process(delta: float) -> void:
	pass
