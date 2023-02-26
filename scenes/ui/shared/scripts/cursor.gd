extends Node2D

export var max_lean_angle: float = 15.0
export var lean_speed: float = 10.0

onready var paw: TextureRect = $Paw

var use_gamepad: bool = false
var last_mouse_position: Vector2
var threshold: float = 40.0

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	if last_mouse_position.distance_to(mouse_pos) > threshold:
		use_gamepad = false
	last_mouse_position = mouse_pos

	if use_gamepad: 
		scale.y = 1
		return
	
	global_position = mouse_pos
	
	var center: Vector2 = get_viewport_rect().size / 2.0
	var offset: Vector2 = (global_position - center)
	var offset_normalized: Vector2 = (global_position - center) / center

	if global_position.y < center.y:
		scale.y = -1
	else:
		scale.y = 1
	
#	paw.rect_rotation = lerp_angle(paw.rect_rotation, deg2rad(max_lean_angle * offset.x), lean_speed * delta)
	rotation = lerp_angle(rotation, deg2rad(max_lean_angle * offset_normalized.x), lean_speed * delta)
