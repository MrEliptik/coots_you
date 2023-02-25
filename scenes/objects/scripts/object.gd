extends KinematicBody2D

signal destroyed(which)

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

func _ready() -> void:
	pass 

func _physics_process(delta: float) -> void:
	if not pushed:
		velocity = lerp(velocity, Vector2.ZERO, friction * delta)
	
	var collision = move_and_collide(velocity * delta)
	if not collision: return

	var collider = collision.collider
	if collider.is_in_group("Walls"):
		has_bounced = true
		velocity = velocity.bounce(collision.normal) * 0.6
		set_health(-damage_walls)
	elif collider.is_in_group("Pushable"):
		if collider.is_in_group("Enemies"):
			collider.push(-collision.normal * velocity.length() * 0.6, false)
		else:
			collider.push(-collision.normal * velocity.length() * 0.5)
			
		velocity = velocity.bounce(collision.normal) * 0.6
		
		if collider.has_method("damage") and (pushed or has_bounced):
			if has_bounced:
				collider.damage(damage_bounce)
			else:
				collider.damage(damage_direct)
			if collider.is_in_group("Enemies") and collider.dead:
				set_health(-damage_enemies)
				# Heal the player
				EventBus.emit_heal(heal_amount_kill_enemy)
				
		has_bounced = true
		
	elif collider.is_in_group("Player"):
		has_bounced = true
		velocity = velocity.bounce(collision.normal) * 0.6
		
	pushed = false

func set_health(amount: float) -> void:
	health += amount
	health = clamp(health, 0, max_health)
	if health <= 0:
		explode()
		
func explode() -> void:
	emit_signal("destroyed", self)
	queue_free()

func push(push_vector: Vector2) -> void:
	pushed = true
	has_bounced = false
	velocity = push_vector
	
func move_away(push_vector: Vector2) -> void:
	has_bounced = false
	velocity = push_vector
