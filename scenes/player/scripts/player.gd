extends KinematicBody2D

signal died()
signal started()

export var coots_face_dead: StreamTexture = preload("res://scenes/player/visuals/coots_face_dead.png")
export var speed: float = 600.0
export var push_force: float = 1700.0
export var pushback_force: float = 2500.0
export var accel: float = 25.0
export var deccel: float = 10.0
export var dash_speed: float = 1900.0
export var dash_duration: float = 0.1
export var rot_speed: float = 10.0

const ENEMIES_OBJECTS_BIT: int = 1

### MOVEMENT
var velocity: Vector2 = Vector2.ZERO
var push_vec: Vector2 = Vector2.ZERO
### STATES
var dashing: bool = false
var can_dash: bool = true
var attacking: bool = false
var dead: bool = false
var started: bool = false

var close_by: Array = []
var closest_object = null
var max_health: float = 100.0
var health: float = max_health
var damage_direct_enemy: float = 75.0
var damage_self: float = 50.0

var hitstop_count: int = 0
var hitstop_object: int = 5
var hitstop_enemy: int = 8

onready var line_2d: Line2D = $Line2D
onready var health_bar: ProgressBar = $UI/HealthBar
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite

func _ready() -> void:
	EventBus.connect("heal", self, "on_heal")
	health_bar.visible = false
	
func _process(delta: float) -> void:
	if attacking or dashing or dead: return
	if hitstop_count > 0:
		return
	
	var dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if dir != Vector2.ZERO:
		velocity = lerp(velocity, dir * speed, accel * delta)
	else:
		velocity = lerp(velocity, Vector2.ZERO, deccel * delta)
		if not started:
			started = true
			emit_signal("started")
	
	if Input.is_action_just_pressed("fire") and closest_object:
		attacking = true
		velocity = push_vec.normalized() * dash_speed
		animation_player.play("attack")
	elif Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		set_collision_mask_bit(ENEMIES_OBJECTS_BIT, false)
		set_collision_layer_bit(ENEMIES_OBJECTS_BIT, false)
		$DashTimer.start()
		$Dash.play()
		velocity = dir * dash_speed
		
	if close_by.empty(): return
	
	compute_closest_close_by()
	push_vec = closest_object.global_position - global_position
	
	## show push vec with line
	show_push_vector(push_vec)
	
func _physics_process(delta: float) -> void:
	if dead: return
	
	if hitstop_count > 0:
		hitstop_count -= 1
		if hitstop_count <= 0:
			stop_hitstop()
		return
	
	velocity = move_and_slide(velocity)
	
	sprite.rotation = lerp_angle(sprite.rotation, velocity.angle()-deg2rad(90), rot_speed*delta)
	
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if not collider.is_in_group("Pushable"):
			# TODO: stop?
			continue
		if attacking:
			$Hit.play()
			collider.push(push_vec.normalized()*push_force)
			velocity = -push_vec.normalized()*pushback_force
			attacking = false
			
			if collider.is_in_group("Enemies"):
				collider.collision_normal = collision.normal
				damage(damage_self)
				collider.damage(damage_direct_enemy)
				start_hitstop(hitstop_enemy)
				collider.start_hitstop(hitstop_enemy)
			else:
				Globals.camera.shake(0.3, 20, 8)
				start_hitstop(hitstop_object)
				collider.start_hitstop(hitstop_object)
#				animation_player.play("bump")
			
			return
			
func start_hitstop(frames: int) -> void:
	hitstop_count = frames
	animation_player.stop(false)
	
func stop_hitstop() -> void:
	hitstop_count = 0
	animation_player.play()

func on_heal(amount: float) -> void:
	heal(amount)
	
func heal(amount: float) -> void:
	print("Heal: ", amount)
#	animation_player.play("heal")
	set_health(amount)

func damage(amount: float) -> void:
	$TakeDamage.play()
#	animation_player.play("damage")
	Globals.camera.shake(0.4, 25, 10)
	set_health(-amount)
		
func set_health(amount: float) -> void:
	health += amount
	health = clamp(health, 0, max_health)
	health_bar.value = health
	if health >= 100.0:
		health_bar.visible = false
	else:
		health_bar.visible = true
	if health <= 0:
		die()
		
func die() -> void:
	dead = true
	health_bar.hide()
	animation_player.stop()
	animation_player.play("RESET")
	sprite.texture = coots_face_dead
	$GhostParticles.emitting = true
	emit_signal("died")
	print("dead")

func compute_closest_close_by() -> void:
	var min_dist: float = 1000000.0
	closest_object = null
	for x in close_by:
		var dist = x.global_position.distance_to(global_position)
		if dist < min_dist:
			min_dist = dist
			closest_object = x
	
func show_push_vector(push_vec: Vector2) -> void:
	if line_2d.points.empty():
		line_2d.add_point(Vector2.ZERO)
		line_2d.add_point(Vector2.ZERO)
	line_2d.set_point_position(0, to_local(closest_object.global_position))
	line_2d.set_point_position(1, to_local(closest_object.global_position + push_vec))

func hide_push_vector() -> void:
	line_2d.clear_points()

func _on_Area2D_body_entered(body: Node) -> void:
	if not body.is_in_group("Pushable"): return
	close_by.append(body)

func _on_Area2D_body_exited(body: Node) -> void:
	if not body.is_in_group("Pushable"): return
	close_by.erase(body)
	if close_by.empty():
		closest_object = null
	hide_push_vector()

func _on_DashTimer_timeout() -> void:
	dashing = false
	set_collision_mask_bit(ENEMIES_OBJECTS_BIT, true)
	set_collision_layer_bit(ENEMIES_OBJECTS_BIT, true)
	$DashTimeout.start()

func _on_DashTimeout_timeout() -> void:
	can_dash = true
