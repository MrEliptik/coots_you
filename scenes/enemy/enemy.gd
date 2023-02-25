extends KinematicBody2D

signal died()

export var speed: float = 150.0
export var accel: float = 10.0
export var push_object_force: float = 150.0

var velocity: Vector2 = Vector2.ZERO
var target = null
var pushed: bool 
var max_health: float = 100.0
var health: float = max_health
var dead: bool = false

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if dead: return
	if not pushed:
		var dir: Vector2 = (target.global_position - global_position).normalized()
		velocity = lerp(velocity, dir*speed, accel*delta)
	
	var collision = move_and_collide(velocity * delta)
	
	if not collision: return
	
	pushed = false
	
	var collider = collision.collider
	if collider.is_in_group("Pushable") and not collider.is_in_group("Enemies"):
		var normal = -collision.normal
		var angles: Array = [-65.0, 65.0]
		# Rotate the normal 45 or -45 degrees
		normal = normal.rotated(deg2rad(angles[randi()%angles.size()]))
		
		collider.push(normal * push_object_force)
	elif collider.is_in_group("Walls"):
		pass
		
func push(push_vector: Vector2) -> void:
	pushed = true
	velocity = push_vector

func damage(value: float) -> void:
	health -= value
	health = clamp(health, 0,max_health)
	if health <= 0:
		die()
		
func die() -> void:
	dead = true
	emit_signal("died")
	queue_free()
