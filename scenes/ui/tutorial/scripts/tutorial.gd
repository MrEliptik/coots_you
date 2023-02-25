extends Control

signal tutorial_done()

onready var w: Label = $Control/W
onready var s: Label = $Control/S
onready var a: Label = $Control/A
onready var d: Label = $Control/D
onready var shift: Label = $Control2/Shift
onready var space: Label = $Control2/Space

var inputs_activated = [false, false, false, false, false, false]
var tutorial_done: bool = false

var tween: SceneTreeTween

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if tutorial_done: return
	if Input.get_action_strength("left") > 0.0:
		if not inputs_activated[0]:
			inputs_activated[0] = true
			a.self_modulate.a = 0.5
			a.get_child(0).emitting = true
	if Input.get_action_strength("right") > 0.0:
		if not inputs_activated[1]:
			inputs_activated[1] = true
			d.self_modulate.a = 0.5
			d.get_child(0).emitting = true
	if Input.get_action_strength("up") > 0.0:
		if not inputs_activated[2]:
			inputs_activated[2] = true
			w.self_modulate.a = 0.5
			w.get_child(0).emitting = true
	if Input.get_action_strength("down") > 0.0:
		if not inputs_activated[3]:
			inputs_activated[3] = true
			s.self_modulate.a = 0.5
			s.get_child(0).emitting = true
	if Input.is_action_just_pressed("dash"):
		if not inputs_activated[4]:
			inputs_activated[4] = true
			shift.self_modulate.a = 0.5
			shift.get_child(0).emitting = true
	if Input.is_action_just_pressed("fire"):
		if not inputs_activated[5]:
			inputs_activated[5] = true
			space.self_modulate.a = 0.5
			space.get_child(0).emitting = true

	if not false in inputs_activated:
		disappear()
		tutorial_done = true
		emit_signal("tutorial_done")

func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(self, "queue_free")
