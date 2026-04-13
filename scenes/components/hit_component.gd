class_name HitComponent
extends Area2D

@export var current_tool: DataTypes.Tools = DataTypes.Tools.None
@export var hit_damage: int = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

signal animationComplete

func awaitAnimationComplete() -> void:
	await animated_sprite_2d.animation_finished
	animationComplete.emit()
