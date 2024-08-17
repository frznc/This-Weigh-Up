extends RigidBody2D

var player_inside = false
@export_range(0,5) var weight_value = 0

@onready var player = get_tree().current_scene.get_node("player")

func _ready() -> void:
	$sprite.frame = int(weight_value)
	

func _physics_process(delta: float) -> void:
	# Player has picked up the weight, add it to them
	if (Input.is_action_just_pressed("pickup")) && player_inside:
		if Global.nearby_weights.back() == name:
			Global.held_weights.push_back(weight_value) # Add weight to global array
			player.update_weight() # update the player's weight value
			player.add_to_weightstack(weight_value) # Add to the 'weight stack'
			queue_free()
			


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true
		Global.nearby_weights.push_front(name)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false
		Global.nearby_weights.erase(name)
