extends Particles2D

func _ready() -> void:
	emitting = true
	$ExplosionParticles.emitting = true
	$CheeseParticlesBackup.emitting = true
	$Timer.start((lifetime / speed_scale)+1.5)
	$Explosion.play()

func _on_Timer_timeout() -> void:
	queue_free()
