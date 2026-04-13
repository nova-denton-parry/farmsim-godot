class_name HarvestableComponent

extends Node

@onready var root: Node

@export var crop: Crop
@onready var mouse_location_component: MouseLocationComponent = UtilFunctions.find_first_in_parents_by_name_and_type(self, "MouseLocationComponent", "Node")



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("attempting to harvest ", crop.name)
		if crop.is_mature:
			print("crop ", crop.name, " is mature")
			mouse_location_component.get_cell_under_mouse()
			if mouse_location_component.does_cell_have_crop():
				print("cell has crop")
				if mouse_location_component.distance < mouse_location_component.close_distance:
					print("crop is close enough")
					var hovered_position = mouse_location_component.tilled_layer.to_global(mouse_location_component.local_cell_position) - Vector2(0, 8)
					if crop.global_position.distance_to(hovered_position) < 4.0:
						var harvest_scene = crop.harvest_scene.instantiate()
						mouse_location_component.get_parent().add_child(harvest_scene)
						harvest_scene.global_position = crop.global_position
						crop.queue_free()
				
