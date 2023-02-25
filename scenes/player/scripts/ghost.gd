extends Sprite

var tween: SceneTreeTween
func _ready() -> void:
	tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(self, "queue_free")
