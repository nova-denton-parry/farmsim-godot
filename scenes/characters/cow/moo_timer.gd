extends AudioStreamPlayer2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"."

var moo_timer: Timer = Timer.new()
var min_time_between_moos: float = 10
var max_time_between_moos: float = 60

func _ready() -> void:
	moo_timer.wait_time = randf_range(min_time_between_moos, max_time_between_moos)
	moo_timer.timeout.connect(moo)
	add_child(moo_timer)
	moo_timer.start()


func moo() -> void:
	moo_timer.stop()
	audio_stream_player_2d.play()
	moo_timer.wait_time = randf_range(min_time_between_moos, max_time_between_moos)
	moo_timer.start()
