extends Particles2D

func _ready() -> void:
	$Timer.start(lifetime + 0.5)

func _on_Timer_timeout() -> void:
	queue_free()
