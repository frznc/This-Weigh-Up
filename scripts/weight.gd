extends RigidBody2D

var player_inside = false
var test = false
var sitting_on = ""
var collidable = true

@export_range(-9, 9, 0.99) var weight_value : int = 0 

@onready var player = get_tree().current_scene.get_node("player")
@onready var selected = $selected

func _ready() -> void:
	# Value is negative, change it to the correct frame
	if (weight_value < 0):
		$sprite.frame = abs(weight_value) + 10
	else:
		$sprite.frame = weight_value
	
	

func _process(delta: float) -> void:
	if player.closest_weight == self && !player.dead:
		selected.visible = true
	else:
		selected.visible = false
		
	match collidable:
		true: $"Static Weight/CollisionShape2D".disabled = false
		false: $"Static Weight/CollisionShape2D".disabled = true
		
	if player_inside == false: # gives collision back after a player presses down to go through it
		collidable = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Player
	if body.name == "player":
		player_inside = true
		Global.nearby_weights.push_front(self)
	
	# Platform Scale
	#if body.name == "Static Hitbox" and linear_velocity.y == 0:
		#print('hi')
	#print(body.name)
	
	# Another Weight


func _on_area_2d_body_exited(body: Node2D) -> void:
	# Player
	if body.name == "player":
		player_inside = false
		Global.nearby_weights.erase(self)
	
