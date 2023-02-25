extends KinematicBody2D

signal died()

export var cheese_particles: PackedScene = preload("res://scenes/enemy/cheese_particles.tscn")
export var speed: float = 150.0
export var accel: float = 10.0
export var push_object_force: float = 550.0
export var enraged_speed_boost: float = 2.0
export var bigger_factor: float = 2.0

var velocity: Vector2 = Vector2.ZERO
var target = null
var pushed: bool 
var max_health: float = 100.0
var health: float = max_health
var dead: bool = false
var angle: float = 0.0
var started: bool = false
var collision_normal: Vector2

var hitstop_count: int = 0
var hitstop_object: int = 5
var hitstop_walls: int = 3

var enraged: bool = false
var bigger: bool = false

onready var health_bar: ProgressBar = $UI/HealthBar
onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

func _ready() -> void:
	var angles: Array = [-65.0, 65.0]
	angle = deg2rad(angles[randi()%angles.size()])
	speed += rand_range(-50, 50)
	health_bar.visible = false
	$Appear.play()
	
	# 5 % chance of being enraged
	if randf() > 0.95:
		enraged = true
		$Sprite/EnragedParticles.emitting = true
		speed *= enraged_speed_boost
		
	if enraged: return
	# 20 % chance of being bigger
	if randf() > 0.8:
		bigger = true
		sprite.scale *= bigger_factor
		$CollisionShape2D.shape.set_deferred("radius", $CollisionShape2D.shape.radius * 2)
		max_health *= bigger_factor
		health = max_health
		health_bar.max_value = max_health
		health_bar.value = health
		health_bar.rect_position.y *= bigger_factor
	
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if dead or not started: return
	
	sprite.rotation = velocity.angle()
	
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
		start_hitstop(hitstop_object)
	elif collider.is_in_group("Walls"):
		start_hitstop(hitstop_walls)
		
func start_hitstop(frames: int) -> void:
	hitstop_count = frames
	animation_player.stop(false)
	animation_player_2.stop(false)
	
func stop_hitstop() -> void:
	hitstop_count = 0
	animation_player.play()
	animation_player_2.play()
		
func push(push_vector: Vector2, until_collision: bool = true) -> void:
	if until_collision:
		pushed = true
	velocity = push_vector

func damage(value: float) -> void:
	$AnimationPlayer.play("damage")
	health -= value
	health = clamp(health, 0,max_health)
	health_bar.value = health
	if health >= max_health:
		health_bar.visible = false
	else:
		health_bar.visible = true
	if health <= 0:
		die()
		
func die() -> void:
	dead = true
	spawn_cheese_particles(collision_normal.angle()+deg2rad(180.0))
	emit_signal("died", self)
	queue_free()
	
func spawn_cheese_particles(angle: float) -> void:
	var instance = cheese_particles.instance()
	get_tree().get_current_scene().add_child(instance)
	instance.global_position = global_position
	instance.rotation = angle

func _on_SpawnInvicibility_timeout() -> void:
	$CollisionShape2D.disabled = false
	started = true
