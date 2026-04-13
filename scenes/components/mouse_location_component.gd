class_name  MouseLocationComponent
extends Node

@onready var player: Player = UtilFunctions.find_first_in_parents_by_type(self, "Player")
@onready var tile_map_layer: TileMapLayer = UtilFunctions.find_first_in_parents_by_type(self, "TileMapLayer")
@onready var planting_preview_sprite: Sprite2D = self.find_child("PlantingPreviewSprite")

@onready var grass_layer: TileMapLayer = UtilFunctions.find_first_in_parents_by_name_and_type(self, "Grass", "TileMapLayer")
@onready var highlight_layer: TileMapLayer = UtilFunctions.find_first_in_parents_by_name_and_type(self, "Highlight", "TileMapLayer")
@onready var tilled_layer: TileMapLayer = UtilFunctions.find_first_in_parents_by_name_and_type(self, "*Tilled*", "TileMapLayer")

var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position: Vector2
var distance: float

var is_planting_preview: bool = false
var is_plantable_cell: bool = false
var active_inventory_square: InventorySquare = null

const close_distance: int = 25
const med_distance: int = 35
const far_distance: int = 50


func _process(_delta: float) -> void:
	if is_planting_preview == false:
		highlight_hovered_cell()
	else:
		planting_preview()

func get_cell_under_mouse() -> void:
	mouse_position = tile_map_layer.get_local_mouse_position()
	cell_position = tile_map_layer.local_to_map(mouse_position)
	cell_source_id = tile_map_layer.get_cell_source_id(cell_position)
	local_cell_position = tile_map_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)

func highlight_hovered_cell() -> void:
	is_plantable_cell = false
	planting_preview_sprite.visible = false
	get_cell_under_mouse()
	highlight_layer.clear()
	var grass_cell: int = grass_layer.get_cell_source_id(cell_position)
	
	if grass_cell == 1:
		if (player.current_tool != DataTypes.Tools.None && 
			!cell_has_collision(grass_layer, local_cell_position, 2)):
			
			if distance < close_distance:
				highlight_layer.set_cell(cell_position, 0, Vector2i(0, 0))
			elif distance < med_distance:
				highlight_layer.set_cell(cell_position, 1, Vector2i(0, 0))
			elif distance < far_distance:
				highlight_layer.set_cell(cell_position, 2, Vector2i(0, 0))
			else:
				highlight_layer.set_cell(cell_position, 11, Vector2i(0,0))


func cell_has_collision(layer: TileMapLayer,
	cell_local_position: Vector2, collision_mask: int) -> bool:
		var space_state = layer.get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(16, 16)
		query.shape = shape
		query.transform = Transform2D(0, layer.to_global(cell_local_position))
		query.collision_mask = collision_mask
		return space_state.intersect_shape(query).size() > 0


func on_active_seeds(sprite: Texture2D, cell: InventorySquare):
	planting_preview_sprite.texture = sprite
	planting_preview_sprite.modulate.a = 0.5
	active_inventory_square = cell


func planting_preview():
	is_plantable_cell = false
	get_cell_under_mouse()
	highlight_layer.clear()
	planting_preview_sprite.visible = true
	planting_preview_sprite.global_position = tilled_layer.to_global(local_cell_position)
	
	var grass_cell: int = grass_layer.get_cell_source_id(cell_position)
	var tilled_cell: int = tilled_layer.get_cell_source_id(cell_position)
	if tilled_cell == 2:
		if !cell_has_collision(tilled_layer, local_cell_position, 2):
			if distance < close_distance:
				if !does_cell_have_crop():
					highlight_layer.set_cell(cell_position, 3, Vector2i(0, 0))
					is_plantable_cell = true
					return
			
	if grass_cell == 1:
			highlight_layer.set_cell(cell_position, 4, Vector2i(0, 0))
			is_plantable_cell = false
			return
	
	is_plantable_cell = false


func does_cell_have_crop() -> bool:
	var crop_position = tilled_layer.to_global(local_cell_position) - Vector2(0, 8)
	for crop in get_tree().get_nodes_in_group("crops"):
		if crop.global_position.distance_to(crop_position) < 5.0:
			return true
	return false
