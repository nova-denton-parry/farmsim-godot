class_name FieldCursorComponent

extends Node

@export var grass_tilemap_layer: TileMapLayer
@export var tilled_soil_tilemap_layer: TileMapLayer
@export var terrain_set: int = 0
@export var terrain: int = 4

@onready var player: Player = UtilFunctions.find_first_in_parents_by_type(self, "Player")
@onready var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var mouse_location_component: MouseLocationComponent = UtilFunctions.find_first_in_parents_by_name_and_type(self, "MouseLocationComponent", "Node")

var clicked_cell: Vector2


func _process(_delta: float) -> void:
	if Input.is_action_pressed("use"):
		clicked_cell = mouse_location_component.cell_position
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			await sprite.animation_finished
			add_tilled_soil_cell()
		elif ToolManager.selected_tool == DataTypes.Tools.MineRock:
			await sprite.animation_finished
			remove_tilled_soil_cell()
		elif Input.is_action_pressed("use"):
			if is_instance_valid(InventoryManager.selected_item):
				if InventoryManager.selected_item.type == DataTypes.ItemTypes.Seeds:
					plant_crop(InventoryManager.selected_item, mouse_location_component.active_inventory_square)



func add_tilled_soil_cell() -> void:
	if (mouse_location_component.distance < mouse_location_component.close_distance 
		&& mouse_location_component.cell_source_id != -1):
			tilled_soil_tilemap_layer.set_cells_terrain_connect(
				[clicked_cell], terrain_set, terrain, true)


func remove_tilled_soil_cell() -> void:
	if (mouse_location_component.distance < mouse_location_component.close_distance 
		&& mouse_location_component.cell_source_id != -1):
			tilled_soil_tilemap_layer.set_cells_terrain_connect(
				[clicked_cell], 0, -1, true)


func plant_crop(seeds: Seeds, cell: InventorySquare):
	if mouse_location_component.is_plantable_cell == true:
		var crop_instance = seeds.crop_plant.instantiate()
		crop_instance.global_position = tilled_soil_tilemap_layer.to_global(mouse_location_component.local_cell_position) - Vector2(0, 8)
		get_tree().current_scene.add_child(crop_instance)
		InventoryManager.remove_item(seeds, cell)
		await get_tree().create_timer(0.2).timeout
		return
