extends Node2D

export var enemy: PackedScene = preload("res://scenes/enemy/enemy.tscn")

var amount_to_spawn: int = 1
var tween: SceneTreeTween
var player = null

var positions: Array = []

func _ready() -> void:
	pass
		
func fill_in_positions_and_shuffle() -> void:
	for x in $SpawnPos.get_children():
		positions.append(x.global_position)
		positions.shuffle()

func spawn() -> void:
	if tween and tween.is_active():
		tween.kill()
	
	if positions.empty():
		fill_in_positions_and_shuffle()
		
	var pos: Vector2 = positions.pop_back()
	
	tween = get_tree().create_tween()
	tween.tween_callback(self, "spawn_enemy", [get_parent(), pos])
	tween.tween_interval(0.3)

func spawn_enemy(parent, pos: Vector2) -> void:
	var instance = enemy.instance()
	instance.target = player
	parent.add_child(instance)
	instance.global_position = pos

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "appear":
		# Fill in position after we appeared to make sure that we get
		# the right position. If we do it too early, the node is not moved yet
		fill_in_positions_and_shuffle()
		spawn()
