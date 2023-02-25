extends Control

signal continue_playing()

func _ready() -> void:
	pass

func _on_ContinueBtn_pressed() -> void:
	emit_signal("continue_playing")
	$AnimationPlayer.play("disappear")

func _on_QuitBtn_pressed() -> void:
	get_tree().quit()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "disappear":
		queue_free()
