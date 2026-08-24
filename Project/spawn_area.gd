extends Area2D

@export_category("Spawn Area Settings")
@export_range(1.0, 10.0) var max_spawn_amount : int = 1
@export var respawn_enabled : bool = true
var spawning : bool = false

@export_category("Encounter Table")
@export_group("20%")
@export var encounter_01 : String
@export var encounter_02 : String
@export_group("10%")
@export var encounter_03 : String
@export var encounter_04 : String
@export var encounter_05 : String
@export var encounter_06 : String
@export_group("5%")
@export var encounter_07 : String
@export var encounter_08 : String
@export_group("4%")
@export var encounter_09 : String
@export var encounter_10 : String
@export_group("1%")
@export var encounter_11 : String
@export var encounter_12 : String

@onready var bounds : Vector4 = Vector4($shape.shape.get_rect().position.x, $shape.shape.get_rect().position.y, $shape.shape.get_rect().end.x, $shape.shape.get_rect().end.y)

func _process(delta: float) -> void:
	if spawning && $spawns.get_child_count() < max_spawn_amount && $spawn_timer.is_stopped() && respawn_enabled:
		$spawn_timer.start(randf_range(4.0, 10.0))

func spawn(amount : int) -> void:
	for i in amount:
		var spawn_roll = randf_range(0.01, 1.0)
		var new_spawn : CharacterBody2D
		if spawn_roll <= 0.02:
			if randi_range(0, 1):
				new_spawn = load("res://scenes/creatures/" + encounter_12.to_lower() + ".tscn").instantiate()
			else:
				new_spawn = load("res://scenes/creatures/" + encounter_11.to_lower() + ".tscn").instantiate()
		elif spawn_roll <= 0.10:
			if randi_range(0, 1):
				new_spawn = load("res://scenes/creatures/" + encounter_10.to_lower() + ".tscn").instantiate()
			else:
				new_spawn = load("res://scenes/creatures/" + encounter_09.to_lower() + ".tscn").instantiate()
		elif spawn_roll <= 0.20:
			if randi_range(0, 1):
				new_spawn = load("res://scenes/creatures/" + encounter_08.to_lower() + ".tscn").instantiate()
			else:
				new_spawn = load("res://scenes/creatures/" + encounter_07.to_lower() + ".tscn").instantiate()
		elif spawn_roll <= 0.60:
			var roll = randi_range(0, 3)
			if roll == 0:
				new_spawn = load("res://scenes/creatures/" + encounter_06.to_lower() + ".tscn").instantiate()
			elif roll == 1:
				new_spawn = load("res://scenes/creatures/" + encounter_05.to_lower() + ".tscn").instantiate()
			elif roll == 2:
				new_spawn = load("res://scenes/creatures/" + encounter_04.to_lower() + ".tscn").instantiate()
			else:
				new_spawn = load("res://scenes/creatures/" + encounter_03 + ".tscn").instantiate()
		else:
			if randi_range(0, 1):
				new_spawn = load("res://scenes/creatures/" + encounter_02.to_lower() + ".tscn").instantiate()
			else:
				new_spawn = load("res://scenes/creatures/" + encounter_01.to_lower() + ".tscn").instantiate()
		$spawns.add_child(new_spawn)
		new_spawn.position = Vector2(randf_range(bounds.x, bounds.z), randf_range(bounds.y, bounds.w))


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "player":
		spawning = true
		if $spawns.get_child_count() > 0:
			spawn(max_spawn_amount)

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "player":
		spawning = false

func _on_spawn_timer_timeout() -> void:
	spawn(1)
