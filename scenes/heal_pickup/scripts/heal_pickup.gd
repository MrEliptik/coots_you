extends Area2D

export var heal_amount: float = 25.0

func _ready() -> void:
	pass

func _on_HealPickup_body_entered(body: Node) -> void:
	if not body.has_method("heal"): return
	body.heal()
