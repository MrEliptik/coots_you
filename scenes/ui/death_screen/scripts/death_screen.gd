extends Control

signal retry()

func _ready() -> void:
	$HBoxContainer/RetryBtn.grab_focus()
	
func set_wave(wave: int) -> void:
	$Wave.text = "WAVE " + str(wave)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "appear":
		$AnimationPlayer.play("wiggle")
		
	elif anim_name == "disappear":
		emit_signal("retry")
		queue_free()

func disappear() -> void:
	$AnimationPlayer.play("disappear")

func _on_RetryBtn_pressed() -> void:
	disappear()
	
func _on_QuitBtn_pressed() -> void:
	get_tree().quit()
