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
	if minute % 10 == 0:
		time_label.text = "%02d:%02d" % [hour, minute]
	if time_label.text == '' || time_label.text == '00:00':
		@warning_ignore("integer_division")
		# if the game time isn't set in the display, set it
		# time label should be set with the minutes rounded to the nearest 10
		# doesn't use snappedf as it should always round down
		minute = (minute / 10) * 10
		time_label.text = "%02d:%02d" % [hour, minute]


func _on_normal_speed_button_pressed() -> void:
	DayNightCycleManager.game_speed = DayNightCycleManager.normal_speed


func _on_fast_speed_button_pressed() -> void:
	DayNightCycleManager.game_speed = DayNightCycleManager.fast_speed


func _on_cheetah_speed_button_pressed() -> void:
	DayNightCycleManager.game_speed = DayNightCycleManager.cheetah_speed

