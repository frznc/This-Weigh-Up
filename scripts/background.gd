extends Node2D
var dir = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in get_children():
		if !x.name == "Timer":
			x.play("default")

	
func _physics_process(delta: float) -> void:
	rotation = rotation + 0.0003

func _on_timer_timeout() -> void:
	dir = !dir
