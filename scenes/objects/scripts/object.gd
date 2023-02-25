extends KinematicBody2D

export var friction: float = 2.0
export var heal_amount_kill_enemy: float = 20.0

var velocity: Vector2 = Vector2.ZERO

var pushed: bool = false
var damage_direct: float = 100.0
var damage_bounce: float = 50.0

var has_bounced: bool = false

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
	elif collider.is_in_group("Pushable"):
		collider.push(-collision.normal * velocity.length() * 0.5)
		velocity = velocity.bounce(collision.normal) * 0.3
		
		if collider.has_method("damage") and pushed:
			if has_bounced:
				collider.damage(damage_bounce)
			else:
				collider.damage(damage_direct)
			if collider.is_in_group("Enemies") and collider.dead:
				# Heal the player
				EventBus.emit_heal(heal_amount_kill_enemy)
				
		has_bounced = true
		
	elif collider.is_in_group("Player"):
		has_bounced = true
		velocity = velocity.bounce(collision.normal) * 0.6
		
	pushed = false

func push(push_vector: Vector2) -> void:
	pushed = true
	has_bounced = false
	velocity = push_vector
