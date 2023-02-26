extends Control

signal retry()

onready var retry_btn: Button = $HBoxContainer/RetryBtn
onready var quit_btn: Button = $HBoxContainer/QuitBtn


func _ready() -> void:
	retry_btn.grab_focus()
	if OS.has_feature("HTML5"):
		quit_btn.disabled
		quit_btn.visible = false
	retry_btn.grab_focus()
	$Cursor.use_gamepad = true
	$Cursor.global_position = retry_btn.rect_global_position + Vector2(retry_btn.rect_size.x/2.0, retry_btn.rect_size.y)
	
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

func _on_RetryBtn_focus_entered() -> void:
	$Cursor.use_gamepad = true
	$Cursor.global_position = retry_btn.rect_global_position + Vector2(retry_btn.rect_size.x/2.0, retry_btn.rect_size.y)

func _on_QuitBtn_focus_entered() -> void:
	$Cursor.use_gamepad = true
	$Cursor.global_position = quit_btn.rect_global_position + Vector2(quit_btn.rect_size.x/2.0, quit_btn.rect_size.y)

