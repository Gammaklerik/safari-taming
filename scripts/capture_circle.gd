extends TextureRect

@onready var gm : Node = get_tree().current_scene.get_node("game_manager")
@onready var sealing_arrow : TextureRect = $arrow_pivot/arrow
@export var closed_arrow : Texture2D
@export var open_arrow : Texture2D
var arrow_speed : float
var arrow_speed_min : float = 1.5
var arrow_speed_max : float = 3.0
var arrow_dir : int = 1
var reverse_chance : float = 0.5
var speed_change_chance : float = 1.0
@onready var sealing_segment : TextureRect = $segment_pivot/capture_segment
@export var closed_segment : Texture2D
@export var open_segment : Texture2D

var capture_in_progress : bool = false:
	set(value):
		capture_in_progress = value
		if capture_in_progress:
			$reverse_timer.start()
			$speed_change_timer.start()
			arrow_speed = randf_range(arrow_speed_min, arrow_speed_max)
		else:
			$reverse_timer.stop()
			$speed_change_timer.stop()

func _ready() -> void:
	reset()

func _physics_process(delta: float) -> void:
	if capture_in_progress:
		$arrow_pivot.rotation += (arrow_dir * arrow_speed) * delta
		if Input.is_action_just_pressed("seal"):
			gm.attempt_seal()

func _on_reverse_timer_timeout() -> void:
	if randf_range(0.0, 1.0) <= reverse_chance:
		arrow_dir *= -1

func _on_speed_change_timer_timeout() -> void:
	if randf_range(0.0, 1.0) <= speed_change_chance:
		arrow_speed = randf_range(arrow_speed_min, arrow_speed_max)

func reset() -> void:
	$segment_pivot.rotation = randf_range(0, 360)
	$arrow_pivot.rotation = randf_range(0, 360)

func _on_arrow_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area != null:
		if area.get_parent().name == "capture_segment":
			sealing_arrow.texture = open_arrow
			sealing_segment.texture = open_segment

func _on_arrow_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area != null:
		if area.get_parent().name == "capture_segment":
			sealing_arrow.texture = closed_arrow
			sealing_segment.texture = closed_segment
