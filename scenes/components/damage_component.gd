class_name DamageComponent
extends Node2D

@export var max_damage: int = 1
@export var current_damage: int = 0
@export var should_respawn: bool = false
@export var days_to_respawn: int = 3

var respawn_component_uid: String = 'uid://ch4wkmjhj2rpm'

signal max_damage_reached

func apply_damage(damage: int) -> void:
	current_damage = clamp(current_damage + damage, 0, max_damage)
	
	if current_damage == max_damage:
		if should_respawn:
			# if the scene should respawn, create a respawn component
			var respawn_component_scene: PackedScene = load(respawn_component_uid) as PackedScene
			var respawn_component_instance: Node2D = respawn_component_scene.instantiate()
			get_parent().get_parent().add_child(respawn_component_instance)
			
			# set respawn component values before being deleted with parent
			respawn_component_instance.global_position = global_position
			respawn_component_instance.days_to_respawn = days_to_respawn
			respawn_component_instance.scene_to_respawn = get_parent().scene_file_path
		max_damage_reached.emit()
		
