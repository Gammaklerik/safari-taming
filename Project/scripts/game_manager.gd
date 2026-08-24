extends Node

@onready var player : CharacterBody2D = get_tree().current_scene.get_node("player")
@onready var sealing_circle : TextureRect = $ui/control/capture_circle
@onready var timer_label : Label = $ui/control/timer_label
@onready var timer : Timer = $expedition_timer
@onready var ui : Control = $ui/control
@export var capture_list_element : PackedScene

var speeds : Array[Dictionary] = [{"name": "Very Slow", "speed": 0.75}, {"name": "Slow", "speed": 1.5}, {"name": "Medium", "speed": 2.5}, {"name": "Fast", "speed": 4.0}, {"name": "Very Fast", "speed": 6.0}, {"name": "Impossibly Fast", "speed": 8.0}]
var speed_variabilities : Array[Dictionary] = [{"name": "Narrow", "variability": 0.5}, {"name": "Average", "variability": 1.5}, {"name": "Wide", "variability": 3.0}]
var reversal_chances : Array[Dictionary] = [{"name": "Playful", "chance": 0.15}, {"name": "Dodgy", "chance": 0.30}, {"name": "Evasive", "variability": 0.45}, {"name": "Eratic", "variability": 0.70}]
var speed_changes : Array[Dictionary] = [{"name": "Consistent", "chance": 0.10}, {"name": "Unpredictable", "chance": 0.30}, {"name": "Abrupt", "chance": 0.50}, {"name": "Bizarre", "chance": 0.80}]
var temperments : Array[Dictionary] = [{"name": "Aloof", "reversal": 1.0, "speed": 1.0, "speed_change": 1.0}, {"name": "Blunt", "reversal": 1.0, "speed": 1.0, "speed_change": 1.0}, {"name": "Brave", "reversal": 0.9, "speed": 1.1, "speed_change": 1.0}, {"name": "Clumsy", "reversal": 1.0, "speed": 0.9, "speed_change": 1.1}, {"name": "Deceptive", "reversal": 1.1, "speed": 1.0, "speed_change": 0.9}, {"name": "Docile", "reversal": 1.0, "speed": 1.0, "speed_change": 1.0}, {"name": "Hasty", "reversal": 1.0, "speed": 1.1, "speed_change": 0.9}, {"name": "Patient", "reversal": 1.1, "speed": 0.9, "speed_change": 1.0}, {"name": "Rash", "reversal": 0.9, "speed": 1.0, "speed_change": 1.1}]

var target_creature : CharacterBody2D
var successes : int :
	set(value):
		if successes < value:
			for rect in sealing_circle.get_node("successes/container").get_children():
				if rect.color.a != 255.0:
					rect.color.a = 255.0
					break
		else:
			for i in sealing_circle.get_node("successes/container").get_child_count():
				if sealing_circle.get_node("successes/container").get_child(sealing_circle.get_node("successes/container").get_child_count() - 1 - i).color.a == 255.0:
					sealing_circle.get_node("successes/container").get_child(sealing_circle.get_node("successes/container").get_child_count() - 1 - i).color.a = 0.0
					break
		successes = value
		if successes == 3:
			for rect in sealing_circle.get_node("successes/container").get_children():
				rect.color.a = 0.0
			successes = 0
			capture(target_creature)

func _process(delta: float) -> void:
	if !timer.is_stopped():
		timer_label.text = str(int(timer.time_left / 60)) + "m " + str(int(timer.time_left) - (int(timer.time_left / 60) * 60)) + "s Left"

func attempt_seal():
	if sealing_circle.sealing_arrow.get_child(0).get_overlapping_areas().has(sealing_circle.sealing_segment.get_child(0)):
		successes += 1
		sealing_circle.reset()
	else:
		if successes > 0:
			successes -= 1
		else:
			end_capture()

func capture(creature : CharacterBody2D):
	player.captured_creatures.append(creature.get_info())
	var new_creature : Panel = capture_list_element.instantiate()
	new_creature.get_node("sprite").texture = creature.get_info().get("sprite")
	new_creature.get_node("name").text = creature.get("species")
	for star in creature.get("star_level"):
		new_creature.get_node("stars").get_child(star).show()
	ui.get_node("capture_notif_box").add_child(new_creature)
	end_capture()

func start_capture(creature : CharacterBody2D):
	if creature != null:
		target_creature = creature
		sealing_circle.show()
		sealing_circle.arrow_speed_min = creature.speed_min
		sealing_circle.arrow_speed_max = creature.speed_max
		sealing_circle.reverse_chance = creature.reverse_chance
		sealing_circle.speed_change_chance = creature.speed_change_chance
		player.is_capturing = true
		sealing_circle.capture_in_progress = true
		get_tree().paused = true
		PhysicsServer2D.set_active(true)

func end_capture():
	target_creature.queue_free()
	target_creature = null
	sealing_circle.hide()
	player.is_capturing = false
	sealing_circle.capture_in_progress = false
	get_tree().paused = false
	PhysicsServer2D.set_active(true)

func _on_expedition_timer_timeout() -> void:
	ui.get_node("run_end_screen").show()
	get_tree().paused = true
	for creature in player.captured_creatures:
		var new_creature : Panel = capture_list_element.instantiate()
		new_creature.get_node("sprite").texture = creature.get("sprite")
		new_creature.get_node("name").text = creature.get("species")
		new_creature.get_node("temperment").text = creature.get("temperment")
		for star in creature.get("star_level"):
			new_creature.get_node("stars").get_child(star).show()
		ui.get_node("run_end_screen/captures/container").add_child(new_creature)

func _on_new_run_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://test.tscn")
