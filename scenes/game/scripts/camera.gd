extends Camera2D

var target = null
var max_lean: float = 5.0
var camera_speed: float = 15.0

onready var base_zoom: Vector2 = zoom
onready var min_zoom: Vector2 = Vector2(0.95, 0.95)
onready var center: Vector2 = get_viewport_rect().size/2.0
onready var max_distance: float = Vector2(1280, 720).distance_to(center)

#### Shake
var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if target:
		var offset_center: Vector2 = (target.global_position - center) / center
		var distance_center: float = target.global_position.distance_to(center) / max_distance
		offset_h = offset_center.x
		offset_v = offset_center.y
		zoom = lerp(min_zoom, base_zoom, distance_center)
		var new_angle = max_lean * offset_h
		rotation_degrees = lerp(rotation_degrees, new_angle, camera_speed*delta)

	# Only shake when there's shake time remaining.
	if _timer == 0:
		return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		set_offset(get_offset() - _last_offset)

# Kick off a new screenshake effect.
func shake(duration: float, frequency: float, amplitude: float):
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	# Reset previous offset, if any.
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)
