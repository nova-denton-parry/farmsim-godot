extends Control

var active_index: int = 0

@onready var hotbar_cells: Array[Node]  = create_hotbar_array()
@onready var active_cell: InventorySquare = hotbar_cells[active_index]
@onready var active_item: Item = active_cell.current_item

@onready var game_screen: CanvasLayer = UtilFunctions.find_first_in_parents_by_name_and_type(self, "GameScreen", "CanvasLayer")
@onready var inventory: InventoryScreen = game_screen.find_child("InventoryScreen")
@onready var inventory_cells: Array[Node] = inventory.inventory_cells[0]
@onready var mouse_location_component: MouseLocationComponent = UtilFunctions.find_first_in_parents_by_name_and_type(self, "MouseLocationComponent", "MouseLocationComponent")

signal active_changed
signal active_seeds

func _ready() -> void:
	InventoryManager.inventory_changed.connect(on_inventory_changed)
	for cell in hotbar_cells:
		active_changed.connect(cell.on_active_changed)
	on_inventory_changed()
	update_active_cell(active_index)
	active_changed.emit()
	active_seeds.connect(mouse_location_component.on_active_seeds)


func on_inventory_changed():
	var i = 0
	while i < hotbar_cells.size():
		var cell = hotbar_cells[i]
		hotbar_cells[i].current_item = inventory_cells[i].current_item
		hotbar_cells[i].current_amount = inventory_cells[i].current_amount
		InventoryManager.update_cell_display(cell)
		i += 1
	update_selected_item_info()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("change_tool_up"):
		if active_index < hotbar_cells.size() - 1:
			active_index += 1
			update_active_cell(active_index)
		else:
			active_index = 0
			update_active_cell(active_index)
	
	if event.is_action_pressed("change_tool_down"):
		if active_index > 0:
			active_index -= 1
			update_active_cell(active_index)
		else:
			active_index = hotbar_cells.size() - 1
			update_active_cell(active_index)
	
	if event.is_action_pressed("use"):
		var i = 0
		while i < hotbar_cells.size():
			if hotbar_cells[i].get_global_rect().has_point(event.global_position):
				active_index = i
				update_active_cell(i)
			i += 1



func create_hotbar_array() -> Array[Node]:
	var inventory_row: MarginContainer = find_child("InventoryRow")
	var inventory_squares: Array[Node] = inventory_row.find_children("InventorySquare*", "InventorySquare")
	return inventory_squares


func update_active_cell(index: int) -> void:
	# remove active tag from previous cell, and change it to current cell
	active_cell.active = false
	active_cell = hotbar_cells[index]
	active_cell.active = true
	active_changed.emit()
	update_selected_item_info()


func update_selected_item_info() -> void:
	active_item = active_cell.current_item
	InventoryManager.selected_item = active_item
	if is_instance_valid(active_item):
		if active_item.type == DataTypes.ItemTypes.Tool:
			var tool = active_item.tool_type
			ToolManager.select_tool(tool)
		else:
			ToolManager.select_tool(DataTypes.Tools.None)
		if active_item.type == DataTypes.ItemTypes.Seeds:
			mouse_location_component.is_planting_preview = true
			var planting_sprite = active_item.planting_sprite
			active_seeds.emit(planting_sprite, inventory_cells[active_index])
		else:
			mouse_location_component.is_planting_preview = false
	else:
		ToolManager.select_tool(DataTypes.Tools.None)
		mouse_location_component.is_planting_preview = false
	
