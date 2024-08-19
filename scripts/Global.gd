extends Node

var can_move = true

var weight = 0
var heaviness = 0

var held_weights = [] # Array containing the weights the player is holding
var nearby_weights = [] # List of weights within pickup range. Used in avoiding picking up multiple at once.

var confine : int = 10000000

func restart_level():
	Global.can_move = true
	reset_globals()
	get_tree().paused = false
	get_tree().reload_current_scene()


func reset_globals():
	confine = 10000000
	weight = 0
	heaviness = 0
	held_weights = []
	nearby_weights = []
