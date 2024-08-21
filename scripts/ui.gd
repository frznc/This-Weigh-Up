extends CanvasLayer

@onready var weight_text = $Label
@onready var dial = $Dial
@onready var dial_neg = $"Negative Dial"

func _ready() -> void:
	dial.rotation = deg_to_rad(90)
	
func _process(delta: float) -> void:
	weight_text.text = str(Global.weight)
	
	# Regular dial
	if (Global.weight >= 0):
		dial.rotation = lerp_angle(dial.rotation,deg_to_rad(lerp(99, 259, Global.weight / 20.0)),0.08)
	else:
		dial.rotation = 0
	
	# Evil fucked up version of dial (negative dial)
	if (Global.weight < 0):
		dial_neg.rotation = deg_to_rad(lerp(99, 259, abs(Global.weight / 20.0)))
	else:
		dial_neg.rotation = 0
