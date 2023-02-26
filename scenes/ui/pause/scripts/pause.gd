extends Control

var tween: SceneTreeTween
onready var continue_btn: Button = $HBoxContainer/ContinueBtn
onready var quit_btn: Button = $HBoxContainer/QuitBtn

func _ready() -> void:
	disappear()
	if OS.has_feature("HTML5"):
		quit_btn.disabled
		quit_btn.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		
		if get_tree().paused:
			appear()
		else:
			disappear()
			
func appear() -> void:
	continue_btn.grab_focus()
	$Cursor.use_gamepad = true
	$Cursor.global_position = continue_btn.rect_global_position + Vector2(continue_btn.rect_size.x/2.0, continue_btn.rect_size.y)
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($OldMovieShader.material, "shader_param/projector_power", 0.5, 0.4)
	tween.parallel().tween_property($OldMovieShader.material, "shader_param/vignette_param", 2.125, 0.4)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.4)

func disappear() -> void:
	var focus = get_focus_owner()
	if focus:
		focus.release_focus()
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($OldMovieShader.material, "shader_param/projector_power", 0.0, 0.4)
	tween.parallel().tween_property($OldMovieShader.material, "shader_param/vignette_param", 1.0, 0.4)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)

func _on_ContinueBtn_pressed() -> void:
	if not get_tree().paused: return
	get_tree().paused = false
	disappear()

func _on_QuitBtn_pressed() -> void:
	if not get_tree().paused: return
	get_tree().quit()

func _on_ContinueBtn_focus_entered() -> void:
	$Cursor.use_gamepad = true
	$Cursor.global_position = continue_btn.rect_global_position + Vector2(continue_btn.rect_size.x/2.0, continue_btn.rect_size.y)

func _on_QuitBtn_focus_entered() -> void:
	$Cursor.use_gamepad = true
	$Cursor.global_position = quit_btn.rect_global_position + Vector2(quit_btn.rect_size.x/2.0, quit_btn.rect_size.y)

