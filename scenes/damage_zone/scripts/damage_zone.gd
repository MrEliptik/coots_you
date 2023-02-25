extends Area2D

export var damage: float = 25.0

func _ready() -> void:
	pass

func _on_DamageZone_body_entered(body: Node) -> void:
	if not body.has_method("damage"): return
	body.damage(damage)
