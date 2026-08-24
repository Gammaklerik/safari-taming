extends CharacterBody2D

@onready var gm : Node = get_tree().current_scene.get_node("game_manager")

@export_category("Creature Constants")
@export_group("Species Attributes")
@export var species : String
@export_enum("Air", "Water", "Earth", "Fire", "Nature", "Fae", "Metal", "Ice", "Electric", "Radiant", "Void", "Spectral", "Venom", "Normal", "Bug") var type_1 : String
@export_enum("Air", "Water", "Earth", "Fire", "Nature", "Fae", "Metal", "Ice", "Electric", "Radiant", "Void", "Spectral", "Venom", "Normal", "Bug") var type_2 : String
@export_group("Capture Stats")
@export_enum("Very Slow", "Slow", "Medium", "Fast", "Very Fast", "Impossibly Fast") var speed : String = "Medium"
@export_enum("Narrow", "Average", "Wide") var speed_variability : String = "Average"
var speed_min : float = 0.5
var speed_max : float = 0.5
@export_enum("Playful", "Dodgy", "Evasive", "Eratic") var reversal_chance : String = "Dodgy"
var reverse_chance : float = 0.01
@export_enum("Consistent", "Unpredictable", "Abrupt", "Bizarre") var speed_change : String = "Unpredictable"
var speed_change_chance : float = 0.01
var temperment : Dictionary
var walk_speed : float = 50.0
var direction : Vector2
@export_group("Sprites")
@export var normal_sprite : Texture2D
@export var shiny_sprite : Texture2D
var star_level : int
var is_shiny : bool

signal start_capture(creature)

var seen_by_player : bool = false

@onready var bounds : Vector4 = get_parent().get_parent().bounds

func _ready() -> void:
	var star_level_roll : float = randf()
	if star_level_roll <= 0.45:
		star_level = 1
	elif star_level_roll <= 0.70:
		star_level = 2
	elif star_level_roll <= 0.85:
		star_level = 3
	elif star_level_roll <= 0.96:
		star_level = 4
	else:
		star_level = 5
	
	if randf() <= (1.0/100.0):
		is_shiny = true
		$sprite.texture = shiny_sprite
	else:
		is_shiny = false
		$sprite.texture = normal_sprite
	
	for s in gm.speeds:
		if s.get("name") == speed:
			speed_min = s.get("speed")
	for v in gm.speed_variability:
		if v.get("name") == speed_variability:
			speed_max = speed_min + v.get("variability")
	for r in gm.reversal_chances:
		if r.get("name") == reversal_chance:
			reversal_chance = r.get("chance")
	for c in gm.speed_changes:
		if c.get("name") == speed_change:
			speed_change_chance = c.get("chance")
	
	temperment = gm.temperments[randi_range(0, 8)]
	speed_min *= temperment.get("speed")
	speed_max *= temperment.get("speed")
	reverse_chance *= temperment.get("reversal")
	speed_change_chance *= temperment.get("speed_change")
	
	start_capture.connect(func(): gm.start_capture(self))

func _physics_process(delta: float) -> void:
	if $walk_timer.is_stopped() && $wait_timer.is_stopped():
		direction = Vector2.from_angle(deg_to_rad(randf_range(0.0, 360.0)))
		while direction_out_of_bounds(direction):
			direction = Vector2.from_angle(deg_to_rad(randf_range(0.0, 360.0)))
		$walk_timer.start(randf_range(0.5, 2.0))
	
	if direction:
		velocity = direction * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.y = move_toward(velocity.y, 0, walk_speed)
	
	move_and_slide()

func direction_out_of_bounds(dir : Vector2) -> bool:
	$cast.target_position = (dir * walk_speed) + position
	if $cast.target_position.x < bounds.x || $cast.target_position.x > bounds.z || $cast.target_position.y < bounds.y || $cast.target_position.y > bounds.w:
		return true
	else:
		return false

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.name == "player" && !gm.player.is_capturing:
		start_capture.emit()

func get_info() -> Dictionary:
	return {"nickname": species ,"species": species, "star_level": star_level, "is_shiny": is_shiny, "temperment": temperment.get("name"), "sprite": $sprite.texture}

func _on_walk_timer_timeout() -> void:
	direction = Vector2.ZERO
	$wait_timer.start(randf_range(0.5, 1.5))

func _on_visibility_screen_entered() -> void:
	seen_by_player = true
	if !$despawn_timer.is_stopped():
		$despawn_timer.stop()

func _on_visibility_screen_exited() -> void:
	if seen_by_player:
		$despawn_timer.start()

func _on_despawn_timer_timeout() -> void:
	queue_free()
