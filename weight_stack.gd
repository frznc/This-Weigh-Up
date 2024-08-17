extends Node2D
# Hello. These are purely visuals for the weights on the player's head. They don't really do anything other than exist
var weight_value = 0
var id = 0

@onready var player = get_tree().current_scene.get_node("player")

func _ready() -> void:
	$sprite.frame = int(weight_value)
	global_position = player.global_position


func _process(delta: float) -> void:
	if Global.held_weights.size() < id: # If the weight's ID is larger than the size of the global stack array, it knows to die. 
		queue_free()
	# set above player position, lerp, idk a lot of bull Shit
	global_position = global_position.lerp(player.global_position+Vector2(1,2)+Vector2(0,id*-8),delta * 30 / id)
	
