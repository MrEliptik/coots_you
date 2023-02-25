extends Node2D

func _ready() -> void:
	for x in get_tree().get_nodes_in_group("Enemies"):
		x.target = $Player
