extends Control

signal continue_playing()
onready var continue_btn: Button = $HBoxContainer/ContinueBtn
onready var quit_btn: Button = $HBoxContainer/QuitBtn

func _ready() -> void:
	if OS.has_feature("HTML5"):
		quit_btn.disabled
		quit_btn.visible = false
	continue_btn.grab_focus()
	$Cursor.use_gamepad = true
	$Cursor.global_position = continue_btn.rect_global_position + Vector2(continue_btn.rect_size.x/2.0, continue_btn.rect_size.y)

func _on_ContinueBtn_pressed() -> void:
	emit_signal("continue_playing")
	$AnimationPlayer.play("disappear")

func _on_QuitBtn_pressed() -> void:
	get_tree().quit()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "disappear":
		queue_free()

func _on_ContinueBtn_focus_entered() -> void:
	$Cursor.use_gamepad = true
	$Cursor.global_position = continue_btn.rect_global_position + Vector2(continue_btn.rect_size.x/2.0, continue_btn.rect_size.y)

func _on_QuitBtn_focus_entered() -> void:
	$Cursor.use_gamepad = true
	$Cursor.global_position = quit_btn.rect_global_position + Vector2(quit_btn.rect_size.x/2.0, quit_btn.rect_size.y)
