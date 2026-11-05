extends Control

var active_index: int = 0

@onready var hotbar_cells: Array[InventorySquare]  = create_hotbar_array()
@onready var active_cell: InventorySquare = hotbar_cells[active_index]

@onready var mouse_location_component: MouseLocationComponent = UtilFunctions.find_first_in_parents_by_name_and_type(self, "MouseLocationComponent", "MouseLocationComponent")

signal active_changed
signal active_seeds

func _ready() -> void:
	GameState.inventory_changed.connect(on_inventory_changed)
	for cell in hotbar_cells:
		active_changed.connect(cell.on_active_changed)
	active_seeds.connect(mouse_location_component.on_active_seeds)
	on_inventory_changed()
	update_active_cell(active_index)


func on_inventory_changed() -> void:
	for i in range(hotbar_cells.size()):
		var cell: InventorySquare = hotbar_cells[i]
		var entry: InventoryEntry = GameState.inventory[i] if i < GameState.inventory.size() else null
		cell.show_entry(entry)
	update_selected_item_info()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("change_tool_up"):
		if active_index > 0:
			active_index -= 1
			update_active_cell(active_index)
		else:
			active_index = hotbar_cells.size() - 1
			update_active_cell(active_index)
	
	if event.is_action_pressed("change_tool_down"):
		if active_index < hotbar_cells.size() - 1:
			active_index += 1
			update_active_cell(active_index)
		else:
			active_index = 0
			update_active_cell(active_index)
	
	if event.is_action_pressed("use"):
		var i = 0
		while i < hotbar_cells.size():
			if hotbar_cells[i].get_global_rect().has_point(event.global_position):
				active_index = i
				update_active_cell(i)
			i += 1



func create_hotbar_array() -> Array[InventorySquare]:
	var hotbar_row: MarginContainer = find_child("InventoryRow")
	var cells: Array[InventorySquare] = []
	for cell in hotbar_row.find_children('InventorySquare*'):
			cells.append(cell)
	return cells


func update_active_cell(index: int) -> void:
	# remove active tag from previous cell, and change it to current cell
	active_cell.active = false
	active_cell = hotbar_cells[index]
	active_cell.active = true
	GameState.selected_index = index
	active_changed.emit()
	update_selected_item_info()


func update_selected_item_info() -> void:
	var active_item: Item = GameState.selected_item
	if active_item is Tool:
		ToolManager.select_tool((active_item as Tool).tool_type)
	else:
		ToolManager.select_tool(DataTypes.Tools.None)
	if active_item is Seeds:
		mouse_location_component.is_planting_preview = true
		var planting_sprite: Texture2D = (active_item as Seeds).planting_sprite
		active_seeds.emit(planting_sprite)
	else:
		mouse_location_component.is_planting_preview = false
	
