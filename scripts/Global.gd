extends Node

var weight = 0
var heaviness = 0

var held_weights = [] # Array containing the weights the player is holding
var nearby_weights = [] # List of weights within pickup range. Used in avoiding picking up multiple at once.
