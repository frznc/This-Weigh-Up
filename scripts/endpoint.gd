extends Node2D

@export var next_level : PackedScene
@export var initial_on : bool = false
@onready var player = get_tree().current_scene.get_node("player")
@onready var hitbox = $Area2D
var touched = false

func _ready():
	if !initial_on:
		visible = false
		hitbox.collision_layer = 0
		hitbox.collision_mask = 0
	$Sprite2D.play("default")
	$arrow.play("default")
func _physics_process(delta: float) -> void:
	if touched == true:
		player.global_position.y -= 0.5

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and next_level != null:
		if !initial_on: # On touch
			$timer.start()
			$sfx.play()
			$explodetimer.start()
			touched = true
			player.spinning = true
			player.spawned = false
			player.global_position.x = global_position.x
			player.global_position.y -= 3
			player.drop_weight(true)
		else:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_timer_timeout() -> void:
	Global.reset_globals()
	get_tree().change_scene_to_packed(next_level)

func _on_explodetimer_timeout() -> void:
	player.explode()

func turn_on():
	visible = true
	hitbox.collision_layer = 1 | 2
	hitbox.collision_mask = 1 | 2
	
func turn_off():
	visible = false
	hitbox.collision_layer = 0 | 0
	hitbox.collision_mask = 0 | 0
