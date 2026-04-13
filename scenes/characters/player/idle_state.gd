extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:	
	if player.player_direction == Vector2.LEFT:
		animated_sprite_2d.play("idle_left")
	elif player.player_direction == Vector2.RIGHT:
		animated_sprite_2d.play("idle_right")
	elif player.player_direction == Vector2.UP:
		animated_sprite_2d.play("idle_back")
	elif player.player_direction == Vector2.DOWN:
		animated_sprite_2d.play("idle_front")
	elif player.player_direction == GameInputEvents.up_left:
		animated_sprite_2d.play("idle_back")
		player.player_direction = Vector2.UP
	elif player.player_direction == GameInputEvents.up_right:
		animated_sprite_2d.play("idle_back")
		player.player_direction = Vector2.UP
	elif player.player_direction == GameInputEvents.down_left:
		animated_sprite_2d.play("idle_front")
		player.player_direction = Vector2.DOWN
	elif player.player_direction == GameInputEvents.down_right:
		animated_sprite_2d.play("idle_front")
		player.player_direction = Vector2.DOWN
	else:
		animated_sprite_2d.play("idle_front")
		player.player_direction = Vector2.DOWN


func _on_next_transitions() -> void:
	GameInputEvents.movement_input()
	
	if GameInputEvents.is_movement_input():
		transition.emit("Walk")
	
	if player.current_tool == DataTypes.Tools.AxeWood && GameInputEvents.use_tool():
		transition.emit("Chopping")
	
	if player.current_tool == DataTypes.Tools.TillGround && GameInputEvents.use_tool():
		transition.emit("Tilling")
	
	if player.current_tool == DataTypes.Tools.WaterCrops && GameInputEvents.use_tool():
		transition.emit("Watering")
	
	if player.current_tool == DataTypes.Tools.MineRock && GameInputEvents.use_tool():
		transition.emit("Mining")


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
