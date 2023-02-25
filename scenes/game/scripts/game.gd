extends Node2D

var started: bool = false
var current_wave: int = 1
var enemies_per_wave: int = 2
#var enemies_per_wave: int = 5
var objects_per_wave: int = 2
var objects_in_game: int = 0

var tween: SceneTreeTween

onready var spawn_manager: Node = $SpawnManager
onready var wave: Label = $Wave

func _ready() -> void:
	randomize()
	
func next_wave() -> void:
	current_wave += 1
	wave.set_wave(current_wave)
	if current_wave%2:
		enemies_per_wave += 1
	if current_wave%3:
		objects_per_wave += 1
	spawn_manager.start(enemies_per_wave, objects_per_wave)
	
func upgrade() -> void:
	pass

func _on_Player_started() -> void:
	pass
#	started = true
#	spawn_manager.start()

func _on_Tutorial_tutorial_done() -> void:
	started = true
	spawn_manager.start(enemies_per_wave, objects_per_wave)
	wave.appear()

func _on_SpawnManager_wave_cleared() -> void:
	next_wave()
