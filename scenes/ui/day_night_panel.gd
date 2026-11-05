extends Control

@onready var day_label: Label = $DayPanel/MarginContainer/DayLabel
@onready var time_label: Label = $TimePanel/MarginContainer/TimeLabel
@onready var normal_speed_button: Button = $Control/NormalSpeedButton
@onready var fast_speed_button: Button = $Control/FastSpeedButton
@onready var cheetah_speed_button: Button = $Control/CheetahSpeedButton


func _ready() -> void:
	DayNightCycleManager.time_tick.connect(on_time_tick)

func on_time_tick(day: int, hour: int, minute: int) -> void:
	day_label.text = "Day " + str(day)
	@warning_ignore('integer_division')
	# this looks weird, but it effectively rounds down to ten
	# snappedf doesn't work because it rounds to nearest - this needs to always round down
	var rounded_minute: int = (minute / 10) * 10
	time_label.text = '%02d:%02d' % [hour, rounded_minute]


func _on_normal_speed_button_pressed() -> void:
	DayNightCycleManager.game_speed = DayNightCycleManager.normal_speed


func _on_fast_speed_button_pressed() -> void:
	DayNightCycleManager.game_speed = DayNightCycleManager.fast_speed


func _on_cheetah_speed_button_pressed() -> void:
	DayNightCycleManager.game_speed = DayNightCycleManager.cheetah_speed

