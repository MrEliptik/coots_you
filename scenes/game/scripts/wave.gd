extends Label

var tween: SceneTreeTween

func _ready() -> void:
	rect_scale = Vector2.ZERO
	
func appear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "rect_scale", Vector2.ONE, 0.2)
	
func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "rect_scale", Vector2.ZERO, 0.35)

func set_wave(wave: int) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "rect_scale", Vector2(1.25, 1.25), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(self, "set_text", ["WAVE " + str(wave)])
	tween.tween_property(self, "rect_scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


