extends Node

signal heal(amount)
signal paused(value)

func _ready() -> void:
	pass

func emit_heal(amount: float) -> void:
	emit_signal("heal", amount)

func emit_paused(value: bool) -> void:
	emit_signal("paused", value)
