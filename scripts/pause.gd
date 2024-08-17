extends ColorRect

@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Quit
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Resume
@onready var fullscreen_button: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Fullscreen
@onready var volume_slider = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Volume
@onready var player = get_parent()

func _ready():
	visible = false
	
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)
	
	## set values to defaults from options.gd
	volume_slider.value = Options.data.volume
	
func _unhandled_input(event: InputEvent):
	# Pause/Unpause
	if event.is_action_pressed("pause"):
		print("hi")
		if (!get_tree().paused):
			pause()
		else:
			unpause()

func pause():
	visible = true
	get_tree().paused = true

func unpause():
	Options.save_data()
	visible = false
	get_tree().paused = false

func _on_fullscreen_toggled(toggled_on):
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		$tick.play()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$tick.play()

## set slider values
func _on_volume_drag_ended(value_changed):
	Options.data.volume = volume_slider.value
	
## play slider ticks / set master volume
func _on_volume_value_changed(value): #volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_slider.value)
	if volume_slider.value == -20:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	$tick.play()


func _on_debug_toggled(toggled_on):
	player.tptorooms()
