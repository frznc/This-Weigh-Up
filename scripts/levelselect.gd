extends Control
@onready var row1 = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer
@onready var row2 = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2
@onready var row3 = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3
@onready var row4 = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4
@onready var button = preload("res://scenes/level_button.tscn")
var levels = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levels += 1
	for x in levels:
		if !x==0: # Ignore level 0
			var inst = button.instantiate()
			inst.name = str(x)
			inst.text = str(x)
			# Set row
			if x<=5:
				row1.add_child(inst)
			elif x<=10:
				row2.add_child(inst)
			elif x<=15:
				row3.add_child(inst)
			else:
				row4.add_child(inst)
				
			if !ResourceLoader.exists(str("res://scenes/levels/lv",str(inst.name),".tscn")): # Disable level if it doesnt exist
				inst.disabled = true

func level_change(name):
	if ResourceLoader.exists(str("res://scenes/levels/lv",str(name),".tscn")):
		get_tree().change_scene_to_packed(load(str("res://scenes/levels/lv",str(name),".tscn")))
	else:
		print("Level does not exist!")
