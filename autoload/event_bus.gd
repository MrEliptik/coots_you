extends Node

signal heal(amount)

func _ready() -> void:
	pass

func emit_heal(amount: float) -> void:
	emit_signal("heal", amount)
