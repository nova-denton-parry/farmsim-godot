class_name  GrowthCycleComponent
extends Node

@export var current_growth_state: int = 1
@export var total_growth_states: int = 5
@export_range(1, 365) var days_until_harvest: int = 7

signal crop_maturity
signal reset_watering

var is_watered: bool
var days_growing: int = 0
var days_per_state: int
var extra_days: int = 0
var days_in_state: int = 1
var states_per_change: int = 1
var extra_growth_states: int = 0

func _ready() -> void:
	DayNightCycleManager.time_tick_day.connect(on_time_tick_day)
	
	if days_until_harvest < total_growth_states:
		# special conditions for shorter growth period than num of states
		extra_growth_states = total_growth_states % days_until_harvest
		@warning_ignore("integer_division")
		states_per_change = total_growth_states / days_until_harvest
	else: 
		# calculate days per growth stage (assuming normal conditions)
		@warning_ignore("integer_division")
		days_per_state = days_until_harvest / total_growth_states
		extra_days = days_until_harvest % total_growth_states


func on_time_tick_day(_day: int) -> void:
	if is_watered:
		growth_states()
		days_growing += 1
		print("Days Growing: ", days_growing)
		is_watered = false # reset watering for the next day
		reset_watering.emit()


func growth_states() -> void:
	if days_until_harvest == 1:
		# if a crop should grow in one day, set to maturity on growth
		current_growth_state = total_growth_states
	elif extra_days == 0:
		# no extra days
		if days_in_state >= days_per_state && extra_growth_states == 0:
			# time to change and no extra growth states
			current_growth_state += states_per_change
			days_in_state = 1
		elif extra_growth_states != 0:
			# extra growth states to apply
			if total_growth_states - current_growth_state <= states_per_change + 1:
				# if there's only enough growth states left to reach maturity, only go to maturity
				current_growth_state = total_growth_states
			elif total_growth_states - states_per_change == 1:
				# if there's only one day left to grow, skip to maturity
				print("checking for one change left")
				current_growth_state = total_growth_states
			else:
				# all other cases, apply one of the extra growth states in the current changes
				current_growth_state += states_per_change + 1
				extra_growth_states -= 1
				days_in_state = 1
		else:
			# not time to change state yet, add a day to tracking
			days_in_state += 1
	else:
		if current_growth_state == total_growth_states - 1:
			# if there are extra days and crop is in the state before maturity,
			# keep applying the extra days until gone before changing states
			days_in_state += 1
			extra_days -= 1
		else: 
			if days_in_state == days_per_state + 1:
				# if not about to be mature, skip to next growth state when one day
				# past the normal days per state and update extra days
				current_growth_state += states_per_change
				extra_days -= 1
				days_in_state = 1
			else:
				# if not about to be mature and not ready to skip to next state,
				# apply day to tracker and ignore extra days at this time
				days_in_state += 1
	
	# after applying all days/states, check for maturity
	# set to >= in case of going over on accident (should be prevented by code,
	# but still set as a failsafe)
	print("Growth State: ", current_growth_state, "/", total_growth_states)
	print("States Per Change: ", states_per_change)
	print("Extra States: ", extra_growth_states)
	if current_growth_state >= total_growth_states:
		crop_maturity.emit()


func get_current_growth_state() -> int:
	return current_growth_state

