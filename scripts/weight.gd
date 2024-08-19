extends RigidBody2D

var player_inside = false
var test = false

@export_range(-9,9) var weight_value : int = 0 
@onready var player = get_tree().current_scene.get_node("player")


func _ready() -> void:
	# Value is negative, change it to the correct frame
	if (weight_value < 0):
		$sprite.frame = abs(weight_value) + 10
	else:
		$sprite.frame = weight_value


func _physics_process(delta: float) -> void:
	# Player has picked up the weight, add it to them
	if (Input.is_action_just_pressed("pickup")) and player_inside and Global.can_move:
		if Global.nearby_weights.front() == name:
			Global.held_weights.push_back(weight_value) # Add weight to global array
			player.update_weight() # update the player's weight value
			player.add_to_weightstack(weight_value) # Add to the 'weight stack'
			$pickup.play()
			queue_free()


	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true
		Global.nearby_weights.push_front(name)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false
		Global.nearby_weights.erase(name)
