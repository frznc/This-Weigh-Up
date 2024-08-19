extends Node2D

@export_range(1, 3) var size : int = 1
@export_range(0, 19) var weight_limit : int = 0

@onready var block_hitbox : StaticBody2D = $Area2D
@onready var block_shape : RectangleShape2D = $Area2D/CollisionShape2D.shape
@onready var break_shape : RectangleShape2D = $Area2D2/CollisionShape2D.shape

@onready var reset_timer : Timer = $Reset

@onready var sprite : AnimatedSprite2D = $Sprite2D
@onready var limit_label : Label = $Label
@onready var break_particles : CPUParticles2D = $"Break Particles"

var player_inside = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	limit_label.text = str(weight_limit)
	
	# Change size
	sprite.frame = size - 1
	block_shape.extents = Vector2(0, 4.25)
	break_shape.extents = Vector2(0, 1)
	break_particles.emission_rect_extents = Vector2(0, 4)
	while size > 0:
		block_shape.extents += Vector2(4, 0)
		break_shape.extents += Vector2(4, 0)
		break_particles.emission_rect_extents += Vector2(4, 0)
		size -= 1
	break_shape.extents += Vector2(-4, 0)


func _process(delta: float) -> void:
	if player_inside and weight_limit <= Global.weight and sprite.visible:
		switch_state()

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true


func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false


func _on_reset_timeout() -> void:
	switch_state()


func switch_state():
	# ON -> OFF
	if sprite.visible:
		block_hitbox.collision_layer = 0
		block_hitbox.collision_mask = 0
		sprite.visible = false
		limit_label.visible = false
		break_particles.emitting = true
		reset_timer.start()
		$break.play()
	
	# OFF -> ON
	else:
		block_hitbox.collision_layer = 1 | 2
		block_hitbox.collision_mask = 1 | 2
		sprite.visible = true
		limit_label.visible = true
