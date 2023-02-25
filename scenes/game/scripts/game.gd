extends Node2D

export var death_screen: PackedScene = preload("res://scenes/ui/death_screen/death_screen.tscn")
export var win_screen: PackedScene = preload("res://scenes/ui/win_screen/win_screen.tscn")

var started: bool = false
var current_wave: int = 1
var enemies_per_wave: int = 2
#var enemies_per_wave: int = 5
var objects_per_wave: int = 2
var objects_in_game: int = 0

var tween: SceneTreeTween
var cam_tween: SceneTreeTween

onready var spawn_manager: Node = $SpawnManager
onready var wave: Label = $Wave
onready var camera: Camera2D = $Camera2D
onready var player: KinematicBody2D = $Player
onready var wave_cleared: Label = $UICanvas/WaveCleared

func _ready() -> void:
	randomize()
	camera.target = player
	Globals.camera = camera
	
func next_wave() -> void:
	camera.target = player
	current_wave += 1
	wave.set_wave(current_wave)
	if current_wave%2:
		enemies_per_wave += 1
	if current_wave%3:
		objects_per_wave += 1
	spawn_manager.start(enemies_per_wave, objects_per_wave)
	
func upgrade() -> void:
	pass
	
func last_kill_sequence(last_enemy) -> void:
	if cam_tween and cam_tween.is_running():
		cam_tween.kill()
	
	camera.target = null
	cam_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	cam_tween.tween_property(camera, "global_position", last_enemy.global_position, 0.2)
	cam_tween.parallel().tween_property(Engine, "time_scale", 0.1, 0.35)
	cam_tween.parallel().tween_property(camera, "zoom", Vector2(0.7, 0.7), 0.3)
	cam_tween.tween_interval(0.6*0.1)
	cam_tween.tween_property(Engine, "time_scale", 1.0, 0.35)
	cam_tween.parallel().tween_property(camera, "global_position", get_viewport_rect().size/2.0, 0.4)
	cam_tween.parallel().tween_property(camera, "zoom", Vector2.ONE, 0.4)
	cam_tween.tween_callback(wave_cleared, "show_animated")
	cam_tween.tween_callback(self, "next_wave")

func _on_Player_started() -> void:
	pass
#	started = true
#	spawn_manager.start()

func _on_Tutorial_tutorial_done() -> void:
	started = true
	spawn_manager.start(enemies_per_wave, objects_per_wave)
	wave.appear()

func _on_SpawnManager_wave_cleared(last_enemy) -> void:
	if player.dead: return
	last_kill_sequence(last_enemy)
#	next_wave()

func _on_Player_died() -> void:
	if cam_tween and cam_tween.is_running():
		cam_tween.kill()
	
	camera.target = null
	cam_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	cam_tween.tween_property(camera, "global_position", player.global_position, 0.35)
	cam_tween.tween_property(camera, "zoom", Vector2(0.7, 0.7), 0.40)
	cam_tween.tween_property(camera, "rotation_degrees", rand_range(-10.0, 10.0), 0.4)
	cam_tween.tween_callback(self, "spawn_death_screen")

func on_retry() -> void:
	get_tree().reload_current_scene()

func on_continue_playing() -> void:
	next_wave()

func spawn_death_screen() -> void:
	var instance = death_screen.instance()
	$UICanvas.add_child(instance)
	instance.set_wave(current_wave)
	instance.connect("retry", self, "on_retry")
	
func spawn_win_screen() -> void:
	var instance = win_screen.instance()
	$UICanvas.add_child(instance)
	instance.set_wave(current_wave)
	instance.connect("continue_playing", self, "on_continue_playing")
