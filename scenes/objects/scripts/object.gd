extends KinematicBody2D

signal destroyed(which)

export var yarn_explosion: PackedScene = preload("res://scenes/objects/yarn_explosion.tscn")
export var friction: float = 2.0
export var heal_amount_kill_enemy: float = 20.0

var velocity: Vector2 = Vector2.ZERO

var pushed: bool = false
var damage_direct: float = 100.0
var damage_bounce: float = 25.0

var has_bounced: bool = false
var max_health: float = 100.0
var health: float = max_health
var damage_walls: float = 15.0
var damage_enemies: float = 50.0

var hitstop_count: int = 0
var hitstop_object: int = 5
var hitstop_walls: int = 3
var hitstop_enemy_direct: int = 10
var hitstop_enemy_bounce: int = 5

onready var sprite: Sprite = $Sprite
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sprite_base_scale: Vector2 = sprite.scale
onready var collision_base_radius: float = collision_shape.shape.radius

func _ready() -> void:
	animation_player.play("appear")

func _physics_process(delta: float) -> void:
	if hitstop_count > 0:
		hitstop_count -= 1
		if hitstop_count <= 0:
			stop_hitstop()
		return
	
	if not pushed:
		velocity = lerp(velocity, Vector2.ZERO, friction * delta)
	
	var collision = move_and_collide(velocity * delta)
	if not collision: return

	animation_player.play("bump")
	var collider = collision.collider
	if collider.is_in_group("Walls"):
		has_bounced = true
		velocity = velocity.bounce(collision.normal) * 0.6
		set_health(-damage_walls)
		$WallBump.pitch_scale = rand_range(0.95, 1.05)
		$WallBump.play()
		start_hitstop(hitstop_walls)
	elif collider.is_in_group("Pushable"):
		if collider.is_in_group("Enemies"):
			collider.collision_normal = collision.normal
			collider.push(-collision.normal * velocity.length() * 0.6, false)
		else:
			collider.push(-collision.normal * velocity.length() * 0.5)
			start_hitstop(hitstop_object)
			collider.start_hitstop(hitstop_object)
			
		velocity = velocity.bounce(collision.normal) * 0.6
		
		if collider.has_method("damage") and (pushed or has_bounced):
			if has_bounced:
				collider.damage(damage_bounce)
				Globals.camera.shake(0.3, 20, 10)
				start_hitstop(hitstop_enemy_bounce)
				$HitEnemy.play()
				collider.start_hitstop(hitstop_enemy_bounce)
			else:
				Globals.camera.shake(0.5, 25, 15)
				collider.damage(damage_direct)
				start_hitstop(hitstop_enemy_direct)
				$HitEnemy.pitch_scale = 0.55
				$HitEnemy.play()
				collider.start_hitstop(hitstop_enemy_direct)
			if collider.is_in_group("Enemies") and collider.dead:
				set_health(-damage_enemies)
				# Heal the player
				EventBus.emit_heal(heal_amount_kill_enemy)
				
		has_bounced = true
		
	elif collider.is_in_group("Player"):
		has_bounced = true
		velocity = velocity.bounce(collision.normal) * 0.6
		
	pushed = false

func start_hitstop(frames: int) -> void:
	hitstop_count = frames
#	animation_player.stop(false)
	animation_player.call_deferred("stop", false)
	
func stop_hitstop() -> void:
	hitstop_count = 0
	animation_player.play()

func set_health(amount: float) -> void:
	health += amount
	health = clamp(health, 0, max_health)
	
	# Scale depending on the health
	var factor = health/max_health
	print(factor)
	
	if health <= 0:
		explode()
		
func spawn_yarn_explosion() -> void:
	var instance = yarn_explosion.instance()
	get_tree().get_current_scene().add_child(instance)
	instance.global_position = global_position

func explode() -> void:
	spawn_yarn_explosion()
	emit_signal("destroyed", self)
	queue_free()

func push(push_vector: Vector2) -> void:
	pushed = true
	has_bounced = false
	velocity = push_vector
	
func move_away(push_vector: Vector2) -> void:
	has_bounced = false
	velocity = push_vector

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "appear":
		animation_player.play("RESET")
