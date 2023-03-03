extends Node2D

func _ready() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(0.6))
	EventBus.connect("paused", self, "on_paused")

func on_paused() -> void:
	pass
