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
var pips_target
var weight_on_enter = 0
var calculating = false

func _ready() -> void:
	# Set text to weight needed
	label.text = str(weight_needed)
	
	# Create pips
	for x in 20:
		var pip_inst = pip.instantiate()
		if pips.size() == 0:
			pip_inst.position = sprite.position + Vector2(-12, 7)
		else:
			pip_inst.position = pips.back().position + Vector2(0, -1)
		pips.append(pip_inst)
		add_child(pip_inst)

func _process(delta: float) -> void:
	if complete == false: # None of this runs if the level is completed
		if player_inside && calculating == false:
			calculating = true
			pip_timer.start()
		if player_inside && weight_on_enter != Global.weight:
			reset()
			pip_timer.start()
			
func reset():
		if error_told == true:
			error_told = false
			resetpips()
		weight_on_enter = Global.weight
		
func resetpips():
	for pip in pips:
		pip.dim()
	pips_lit = 0
	
func complete_level():
	if endpoint != null:
			endpoint.turn_on()
func uncomplete_level():
	if endpoint != null:
			endpoint.turn_off()
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and body.global_position.y <= stand_box.global_position.y + 8:
		player_inside = true
		weight_on_enter = Global.weight
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false
		calculating = false
		if error_told == true:
			reset()
			resetpips()

func _on_pip_tick_timeout() -> void:
	if player_inside == true: pips_target = Global.weight
	else: pips_target = 0 # Set target to 0 if player is not on scale
	
	if pips_target > weight_needed && error_told == false:
		error.play()
		for pip in pips:
			pip.too_much()
		error_told = true
		pip_timer.stop()
	if error_told == true:
		return
		
	if pips_lit < pips_target:
		pips[pips_lit].light_up(pips_lit)
		pips_lit += 1
	if pips_lit > pips_target:
		pips[pips_lit - 1].light_down(pips_lit)
		pips_lit -= 1
	
	if pips_lit == weight_needed:
		label["theme_override_colors/font_color"] = Color("00E436")
		yay.play()
		pip_timer.stop()
		complete = true
		complete_level()
	
