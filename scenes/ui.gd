extends CanvasLayer

@onready var weight_text = $Label
@onready var dial = $Dial
@onready var dial_neg = $"Negative Dial"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	weight_text.text = str(Global.weight)
	
	# Regular dial
	if (Global.weight >= 0):
		dial.rotation = deg_to_rad(lerp(99, 259, Global.weight / 20.0))
	else:
		dial.rotation = 0
	
	# Evil fucked up version of dial (negative dial)
	if (Global.weight < 0):
		dial_neg.rotation = deg_to_rad(lerp(99, 259, abs(Global.weight / 20.0)))
	else:
		dial_neg.rotation = 0
