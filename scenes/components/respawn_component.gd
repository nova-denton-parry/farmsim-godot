class_name RespawnComponent
extends Node2D

# variables set by damage component spawning in the respawn component
var scene_to_respawn: String
var days_to_respawn: int

var days_passed: int = 0

func _ready() -> void:
	DayNightCycleManager.time_tick_day.connect(on_time_tick_day)


func on_time_tick_day():
	days_passed += 1
	if days_passed >= days_to_respawn:
		respawn()


func respawn():
	var instance: Node2D = load(scene_to_respawn).instantiate()
	instance.global_position = global_position
	get_parent().add_child(instance)
	queue_free()
