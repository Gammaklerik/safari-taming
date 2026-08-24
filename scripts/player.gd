extends CharacterBody2D

@onready var gm : Node = get_tree().current_scene.get_node("game_manager")

var speed : float = 100.0

var is_capturing : bool = false
signal attempt_seal

var captured_creatures : Array[Dictionary]

func _ready() -> void:
	attempt_seal.connect(gm.attempt_seal)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()
