extends KinematicBody2D

signal died()

export var speed: float = 150.0
export var accel: float = 10.0
export var push_object_force: float = 550.0

var velocity: Vector2 = Vector2.ZERO
var target = null
var pushed: bool 
var max_health: float = 100.0
var health: float = max_health
var dead: bool = false
var angle: float = 0.0
var started: bool = false

onready var health_bar: ProgressBar = $UI/HealthBar

func _ready() -> void:
	var angles: Array = [-65.0, 65.0]
	angle = deg2rad(angles[randi()%angles.size()])
	speed += rand_range(-50, 50)
	health_bar.visible = false
	
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if dead or not started: return
	if not pushed:
		var dir: Vector2 = (target.global_position - global_position).normalized()
		velocity = lerp(velocity, dir*speed, accel*delta)
	
	var collision = move_and_collide(velocity * delta)
	
	if not collision: return
	
	pushed = false
	
	var collider = collision.collider
	if collider.is_in_group("Pushable") and not collider.is_in_group("Enemies"):
		var normal = -collision.normal
		normal = normal.rotated(angle)
		
		collider.move_away(normal * push_object_force)
	elif collider.is_in_group("Walls"):
		pass
		
func push(push_vector: Vector2, until_collision: bool = true) -> void:
	if until_collision:
		pushed = true
	velocity = push_vector

func damage(value: float) -> void:
	health -= value
	health = clamp(health, 0,max_health)
	health_bar.value = health
	if health >= 100.0:
		health_bar.visible = false
	else:
		health_bar.visible = true
	if health <= 0:
		die()
		
func die() -> void:
	dead = true
	emit_signal("died", self)
	queue_free()

func _on_SpawnInvicibility_timeout() -> void:
	$CollisionShape2D.disabled = false
	started = true
