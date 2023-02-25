extends Node2D

var started: bool = false
var current_wave: int = 1
var enemies_per_wave: int = 3
var max_enemies_spawned: int = 4
var objects_in_game: int = 0

onready var spawn_manager: Node = $SpawnManager

func _ready() -> void:
	randomize()
	
func next_wave() -> void:
	pass
	
func upgrade() -> void:
	pass

func _on_Player_started() -> void:
	started = true
	spawn_manager.start()
