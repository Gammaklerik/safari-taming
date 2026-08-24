extends VBoxContainer

@onready var notif_timer : Timer = get_tree().current_scene.get_node("game_manager/notif_timer")

var notifs_list : Array[Node]

func _on_child_entered_tree(node: Node) -> void:
	notif_timer.start()
	notifs_list.append(node)

func _on_notif_timer_timeout() -> void:
	notifs_list.pop_back().queue_free()
