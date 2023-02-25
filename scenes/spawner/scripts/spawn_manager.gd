extends Node

export var spawner: PackedScene = preload("res://scenes/spawner/spawner.tscn")
export var spawn_points_container_path: NodePath
export var player_path: NodePath

var positions: Array = []

onready var spawn_points_container = get_node(spawn_points_container_path)
onready var player = get_node(player_path)

func _ready() -> void:
	pass
	
func fill_in_positions_and_shuffle() -> void:
	for x in spawn_points_container.get_children():
		positions.append(x.global_position)
		positions.shuffle()
	
func start() -> void:
	$WaitTimer.start(1.0)
	
func stop() -> void:
	$WaitTimer.stop()

func get_random_spawn_location(poses: Array) -> Vector2:
#	var available_nodes = spawn_points_container.get_children()
#	var location: Vector2 = Vector2.ZERO
#
#	location = available_nodes[randi()%available_nodes.size()].global_position
	
	if poses.empty():
		fill_in_positions_and_shuffle()
		
	var location: Vector2 = poses.pop_back()
	 
	return location

func spawn_spawner(parent, pos: Vector2) -> void:
	var instance = spawner.instance()
	instance.player = player
	parent.add_child(instance)
	instance.global_position = pos

func _on_WaitTimer_timeout() -> void:
	var pos = get_random_spawn_location(positions)
	spawn_spawner(get_parent(), pos)
#	for i in range(10):
#		pass
