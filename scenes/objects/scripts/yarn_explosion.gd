extends Particles2D


func _ready() -> void:
	emitting = true
	$Timer.start((lifetime/speed_scale)+1.0)

func _on_Timer_timeout() -> void:
	queue_free()
