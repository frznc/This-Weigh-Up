extends Node2D

@export var weight_needed : int = 1
@export var endpoint : Node2D

@onready var player = get_tree().current_scene.get_node("player")
@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var stand_box : Area2D = $Area2D
@onready var pip : PackedScene = preload("res://scenes/objects/pip.tscn")
@onready var pip_timer = $"Pip Tick"
@onready var blip = $blip
@onready var yay = $complete

var complete = false
var player_inside = false
var pips = []
var pips_lit : int = 0
var pips_queue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set text to weight needed
	label.text = str(weight_needed)
	
	# Create pips
	for x in 10:
		var pip_inst = pip.instantiate()
		if pips.size() == 0:
			pip_inst.position = sprite.position + Vector2(-12, 6)
		else:
			pip_inst.position = pips.back().position + Vector2(0, -2)
		pips.append(pip_inst)
		add_child(pip_inst)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_inside and pip_timer.is_stopped() and !complete:
		print("Weight: ", Global.weight, " Needed: ", weight_needed)
		pips_queue = (float(Global.weight) / weight_needed) * 10
		print(pips_queue)
		if pips_queue > 10:
			pips_queue = 10
		if pips_queue > 9 and pips_queue < 10:
			pips_queue = 9
		if Global.weight > 0:
			pips[pips_lit].light_up(pips_lit)
		pip_timer.start()
	elif !player_inside:
		pip_timer.stop()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and body.global_position.y <= stand_box.global_position.y + 8:
		player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		if !complete:
			if Global.weight > 0 and pips_lit > 0:
				blip.play()
			pips_queue = 0
			pips_lit = 0
			for x in 10:
				pips[x].dim()
		player_inside = false


func _on_pip_tick_timeout() -> void:
	if pips_lit < pips_queue - 1:
		pips_lit += 1
		pips[pips_lit].light_up(pips_lit)
	if pips_lit == 9:
		complete = true
		endpoint.turn_on()
		label["theme_override_colors/font_color"] = Color("00E436")
		yay.play()
		pip_timer.stop()
