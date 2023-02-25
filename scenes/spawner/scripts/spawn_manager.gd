extends Node

signal wave_cleared()

export var spawner: PackedScene = preload("res://scenes/spawner/spawner.tscn")
export var object: PackedScene = preload("res://scenes/objects/object.tscn")
export var spawn_points_container_path: NodePath
export var player_path: NodePath
export var spawn_points_object_container_path: NodePath
export var spawn_points_object_start_container_path: NodePath
export var objects_container_path: NodePath

var positions: Array = []
var current_enemies: Array = []
var objects: Array = []
var amount_to_spawn_enemies: int = 1
var amount_to_spawn_objects: int = 3
var max_enemies_spawn: int = 4
var spawn_tween: SceneTreeTween

onready var spawn_points_container = get_node(spawn_points_container_path)
onready var spawn_points_object_container = get_node(spawn_points_object_container_path)
onready var spawn_points_object_start_container = get_node(spawn_points_object_start_container_path)
onready var player = get_node(player_path)
onready var objects_container = get_node(objects_container_path)

func _ready() -> void:
	spawn_objects(objects_container, amount_to_spawn_objects)

func fill_in_positions_and_shuffle(container) -> Array:
	var positions: Array = []
	for x in container.get_children():
		positions.append(x.global_position)
		positions.shuffle()
	return positions
	
func start(enemies_amount: int, objects_amount: int) -> void:
	amount_to_spawn_enemies = enemies_amount
	amount_to_spawn_objects = objects_amount
	$WaitTimer.start(1.0)
	
func stop() -> void:
	$WaitTimer.stop()

func _on_WaitTimer_timeout() -> void:
	var pos = get_random_spawn_location(positions)
	var spawner_needed: int = 1
	var last_spawner_amount: int = 0
	# Calculate how many enemies we have to spawn
	# If higher than max_enemies_spawn, calculate how many spawner of 4 enmies
	# we need, and spawn them random amount in the future
	if amount_to_spawn_enemies > max_enemies_spawn:
		spawner_needed = ceil(float(amount_to_spawn_enemies)/float(max_enemies_spawn))
		if spawner_needed < 1 or spawner_needed == 0:
			spawner_needed = 1

		last_spawner_amount = amount_to_spawn_enemies % max_enemies_spawn
	else:
		last_spawner_amount = amount_to_spawn_enemies
		
	if spawn_tween and spawn_tween.is_running():
		spawn_tween.kill()
	spawn_tween = get_tree().create_tween()
	
	for i in range(spawner_needed):
		var amount = int(float(amount_to_spawn_enemies)/float(max_enemies_spawn)) * max_enemies_spawn
		# Last spawner
		if i == (spawner_needed - 1):
			spawn_tween.tween_callback(self, "spawn_spawner", [get_parent(), pos, last_spawner_amount])
		else:
			spawn_tween.tween_callback(self, "spawn_spawner", [get_parent(), pos, amount])
			spawn_tween.tween_interval(rand_range(4.0, 8.0))
	
#	spawn_spawner(get_parent(), pos, amount_to_spawn_enemies)
	spawn_objects(objects_container, amount_to_spawn_objects)

##### ENEMIES #####
func get_random_spawn_location(positions: Array) -> Vector2:
#	var available_nodes = spawn_points_container.get_children()
#	var location: Vector2 = Vector2.ZERO
#
#	location = available_nodes[randi()%available_nodes.size()].global_position
	
	if positions.empty():
		positions = fill_in_positions_and_shuffle(spawn_points_container)
		
	var location: Vector2 = positions.pop_back()
	 
	return location

func spawn_spawner(parent, pos: Vector2, amount: int) -> void:
	var instance = spawner.instance()
	instance.player = player
	instance.amount_to_spawn = amount
	parent.add_child(instance)
	instance.global_position = pos
	instance.connect("spawned", self, "on_enemies_spawned")
	
func clear_currrent_enemies_list() -> void:
	current_enemies.clear()

func on_enemies_spawned(enemies: Array) -> void:
	current_enemies.append_array(enemies)
	var idx_to_remove = []
	for i in range(enemies.size()):
		if not is_instance_valid(enemies[i]): 
			idx_to_remove.append(i)
			continue
		enemies[i].connect("died", self, "on_enemy_died")
		
func on_enemy_died(which) -> void:
	current_enemies.erase(which)
	if current_enemies.empty():
		emit_signal("wave_cleared")
	
##### OBJECTS #####
func get_random_object_position(poses: Array) -> Vector2:
	var pos: Vector2 = Vector2.ZERO
	if poses.empty():
		poses = fill_in_positions_and_shuffle(spawn_points_container)
		
	pos = poses.pop_back()
	return pos

func spawn_objects(parent, amount: int) -> void:
	if objects.size() > 5: return
	
	# Spawn only the amount of objects to not go higher than 5
	amount = amount - objects.size()
	
	var poses: Array = []
	for point in spawn_points_object_start_container.get_children():
		poses.append(point.global_position)
		
	for i in range(amount):
		var instance = object.instance()
		parent.add_child(instance)
		instance.global_position = get_random_object_position(poses)
		instance.connect("destroyed", self, "on_object_destroyed")
		objects.append(instance)

func on_object_destroyed(which) -> void:
	objects.erase(which)
