extends NodeState

@export var character: CharacterBody2D
@export var animated_sprite_2d: AnimatedSprite2D
@export var min_idle_time: float = 2
@export var max_idle_time: float = 30

@onready var idle_state_timer: Timer = Timer.new()

var idle_state_time_interval: float
var idle_state_timeout: bool = false

func _ready() -> void:
	idle_state_time_interval = randf_range(min_idle_time, max_idle_time)
	idle_state_timer.wait_time = idle_state_time_interval
	idle_state_timer.timeout.connect(on_idle_state_timeout)
	add_child(idle_state_timer)


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	pass


func _on_next_transitions() -> void:
	if idle_state_timeout:
		transition.emit("Walk")


func _on_enter() -> void:
	animated_sprite_2d.play("idle")
	
	idle_state_timeout = false
	idle_state_timer.start()


func _on_exit() -> void:
	animated_sprite_2d.stop()
	idle_state_timer.stop()


func on_idle_state_timeout() -> void:
	idle_state_timeout = true
