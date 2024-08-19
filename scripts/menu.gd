extends Node2D

@export var first_level : PackedScene

@onready var pause_menu : Control = get_tree().current_scene.get_node("Pause")
@onready var puff : CPUParticles2D = $"Logo Body/Puff"
@onready var thud : AudioStreamPlayer2D = $thud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(first_level)


func _on_options_pressed() -> void:
	pause_menu.pause()
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_timer_timeout() -> void:
	puff.emitting = true
	thud.play()
