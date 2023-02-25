extends Label

var tween: SceneTreeTween

func _ready() -> void:
	rect_scale = Vector2.ZERO

func show_animated() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "rect_scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_scale", Vector2(1.25, 1.25), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rect_scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	$StageClear.play()
