extends Control

@onready var quit_button : Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer3/VBoxContainer/Quit
@onready var resume_button : Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer3/VBoxContainer/Resume
@onready var restart_button : Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer3/VBoxContainer/Restart
@onready var fullscreen_button : CheckBox = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer3/MarginContainer/HBoxContainer/fullscreen_check
@onready var volume_slider = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer3/MarginContainer/HBoxContainer/Volume
@onready var player = get_parent()

func _ready():
	visible = false
	
	resume_button.pressed.connect(unpause)
	restart_button.pressed.connect(Global.restart_level)
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
	$tick.play()
	visible = true
	get_tree().paused = true

func unpause():
	$tick.play()
	Options.save_data()
	visible = false
	get_tree().paused = false

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		$tick.play()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
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

func _on_restart_pressed() -> void:
	$tick.play()
