extends AudioStreamPlayer2D

var musicplaying = false


func playmusic():
	musicplaying = true
	$"/root/Music".play()

func stopmusic():
	musicplaying = false
	$"/root/Music".stop()


func _on_finished() -> void:
	playmusic()
