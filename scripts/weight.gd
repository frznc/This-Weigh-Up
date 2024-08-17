extends Node2D

var player_inside = false

@onready var player = preload("res://scenes/player.tscn")

func _physics_process(delta: float) -> void:
	# Player has picked up the weight, add it to them
	if (Input.is_action_just_pressed("pickup")):
		if player_inside:
			Global.weights += 1
			queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false
