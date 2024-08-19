extends Node2D

@export_range(1, 20) var weight_needed : int = 1
@export var endpoint : Node2D

@onready var player = get_tree().current_scene.get_node("player")
@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var stand_box : Area2D = $Area2D
@onready var pip : PackedScene = preload("res://scenes/objects/pip.tscn")
@onready var pip_timer = $"Pip Tick"
@onready var blip = $blip
@onready var yay = $complete
@onready var error = $error

var error_told = false
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
		pips_queue = (float(Global.weight) / weight_needed) * 10
		if pips_queue > 10:
			pips_queue = 10
		if pips_queue > 9 and pips_queue < 10:
			pips_queue = 9
		if Global.weight > 0 and Global.weight <= weight_needed:
			pips[pips_lit].light_up(pips_lit)
		var weight_ratio = clamp(float(Global.weight) / weight_needed, 0, 1)
		pip_timer.wait_time = lerp(0.25, 0.06, weight_ratio)
		if Global.weight > weight_needed and !error_told:
			error_told = true
			error.play()
			for pip in pips:
				pip.too_much()
		elif Global.weight <= weight_needed:
			pip_timer.start()
	elif !player_inside:
		pip_timer.stop()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and body.global_position.y <= stand_box.global_position.y + 8:
		player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		if !complete:
			if Global.weight > 0 and (pips_lit > 0 or Global.weight > weight_needed):
				blip.play()
			pips_queue = 0
			pips_lit = 0
			for x in 10:
				pips[x].dim()
		player_inside = false
		error_told = false


func _on_pip_tick_timeout() -> void:
	if pips_lit < pips_queue - 1:
		pips_lit += 1
		pips[pips_lit].light_up(pips_lit)
	if pips_lit == 9:
		complete = true
		if endpoint != null:
			endpoint.turn_on()
		label["theme_override_colors/font_color"] = Color("00E436")
		yay.play()
		pip_timer.stop()
