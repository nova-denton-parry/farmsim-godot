class_name  HurtComponent
extends Area2D

@export var tool: DataTypes.Tools = DataTypes.Tools.None

signal hurt

func _on_area_entered(area: Area2D) -> void:
	var hit_component = area as HitComponent
	var parent = hit_component.owner
	var sprite = parent.find_child("AnimatedSprite2D")
	
	if tool == hit_component.current_tool:
		hurt.emit(hit_component.hit_damage, sprite)
