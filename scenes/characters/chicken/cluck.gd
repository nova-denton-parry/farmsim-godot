extends AudioStreamPlayer2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"."

var cluck_timer: Timer = Timer.new()
var min_time_between_clucks: float = 10
var max_time_between_clucks: float = 60
const cluck1: Resource = preload("uid://cfoneo2xwdkfq")
const cluck2: Resource = preload("uid://b1grlamosj1u8")
var current_cluck: Resource

func _ready() -> void:
	set_randoms()
	cluck_timer.timeout.connect(cluck)
	add_child(cluck_timer)
	cluck_timer.start()


func cluck() -> void:
	cluck_timer.stop()
	set_randoms()
	audio_stream_player_2d.play()
	cluck_timer.start()


func set_randoms() -> void:
	cluck_timer.wait_time = randf_range(min_time_between_clucks, max_time_between_clucks)
	var which_cluck: int = randi_range(1, 2)
	if which_cluck == 1:
		current_cluck = cluck1
	else:
		current_cluck = cluck2
	audio_stream_player_2d.stream = current_cluck
	
