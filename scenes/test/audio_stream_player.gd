extends AudioStreamPlayer

@onready var audio_stream_player: AudioStreamPlayer = $"."

func _ready() -> void:
	audio_stream_player.play()

func _on_finished() -> void:
	audio_stream_player.play()
