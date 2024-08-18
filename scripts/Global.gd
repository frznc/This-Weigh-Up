extends Node

var weight = 0
var heaviness = 0

var held_weights = [] # Array containing the weights the player is holding
var nearby_weights = [] # List of weights within pickup range. Used in avoiding picking up multiple at once.

func restart_level():
	reset_globals()
	get_tree().paused = false
	get_tree().reload_current_scene()

func reset_globals():
	weight = 0
	heaviness = 0
	held_weights = []
	nearby_weights = []
