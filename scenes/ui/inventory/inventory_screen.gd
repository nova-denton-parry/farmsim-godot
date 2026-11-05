class_name InventoryScreen
extends PanelContainer

@onready var all_cells: Array[InventorySquare] = get_all_cells()

@onready var tooltip: PanelContainer = UtilFunctions.find_first_in_parents_by_name_and_type(self, "TooltipContainer", "PanelContainer")
@onready var tooltip_label: Label = tooltip.find_child("TooltipLabel")
@onready var texture_rect_container: CenterContainer = UtilFunctions.find_first_in_parents_by_name_and_type(self, "InventorySelectContainer", "CenterContainer")
@onready var texture_rect: TextureRect = texture_rect_container.find_child("InventorySelectSprite")

var last_selected_cell: InventorySquare = null
var _hover_timer: SceneTreeTimer = null

signal cell_disabled_changed

func _ready() -> void:
	# connect game state inventory signals
	GameState.inventory_resized.connect(on_inventory_resized)
	GameState.inventory_changed.connect(refresh_display)
	
	# connect inventory_cell hover/select/disable signals
	for cell in all_cells:
		cell.hovered.connect(on_cell_hovered)
		cell.unhovered.connect(on_cell_unhovered)
		cell.item_selected.connect(on_cell_selected)
		cell_disabled_changed.connect(cell.on_cell_disabled_changed)
	
	# set starting inventory size (activates first 12 cells - one row - and disables the rest)
	GameState.set_max_inventory(12)
	
	# add tools
	GameState.add_item(ItemManager.get_item("watering can"))
	GameState.add_item(ItemManager.get_item("hoe"))
	GameState.add_item(ItemManager.get_item("pickaxe"))
	GameState.add_item(ItemManager.get_item("axe"))
	
	# add some seeds for testing
	for i in range(3):
		GameState.add_item(ItemManager.get_item("corn seeds"))
	for i in range(3):
		GameState.add_item(ItemManager.get_item("tomato seeds"))


func _process(_delta: float) -> void:
	texture_rect_container.global_position = get_viewport().get_mouse_position() - Vector2(8, 8)


func get_all_cells() -> Array:
	var cells: Array[InventorySquare] = []
	for row in self.find_children('InventoryRow*'):
		for cell in row.find_children('InventorySquare*'):
			cells.append(cell)
	return cells


func on_inventory_resized(new_max: int) -> void:
	for i in range(all_cells.size()):
		all_cells[i].disabled = i >= new_max
		cell_disabled_changed.emit()


func refresh_display() -> void:
	for i in range(all_cells.size()):
		var entry: InventoryEntry = GameState.inventory[i] if i < GameState.inventory.size() else null
		all_cells[i].show_entry(entry)


func on_cell_hovered(cell: InventorySquare):
	var index: int = all_cells.find(cell)
	# do nothing for empty cells
	if index < 0 or index > GameState.inventory.size():
		return
	if GameState.inventory[index].item == null:
		return
	
	# update & display tooltip when hovering over a cell w/ an item
	tooltip_label.text = GameState.inventory[index].item.item_name
	tooltip.global_position = cell.global_position + Vector2(30, 5)
	
	_hover_timer = get_tree().create_timer(1.0)
	await _hover_timer.timeout
	
	# cancel displaying the tooltip if cell has been unhovered
	if _hover_timer != null:
		tooltip.visible = true


func on_cell_unhovered():
	# kill timer to prevent accidental display of invalid tooltip
	_hover_timer = null
	
	# clear tooltip to be safe
	tooltip.visible = false
	tooltip_label.text = ""


func on_cell_selected(cell: InventorySquare) -> void:
	var index: int = all_cells.find(cell)
	# do nothing for empty cells
	if index == -1 or GameState.inventory[index].item == null:
		return
	
	last_selected_cell = cell
	cell.texture_rect.modulate.a = 0.5
	texture_rect.texture = cell.texture_rect.texture
	texture_rect_container.visible = true


func on_cell_deselected(cell: InventorySquare) -> void:
	# update values to before selection
	texture_rect.texture = null
	texture_rect_container.visible = false
	last_selected_cell.texture_rect.modulate.a = 1.0
	
	# if still hovering over the same cell, reset the last selected cell & return
	if cell == last_selected_cell:
		last_selected_cell = null
		return
	
	var from_index: int = all_cells.find(last_selected_cell)
	var to_index: int = all_cells.find(cell)
	
	# reset the last selected cell if empty/doesn't exist
	if from_index == -1 or GameState.inventory[from_index].item == null:
		last_selected_cell = null
		return
	
	# swap entries in GameState, then refresh display
	var temp: InventoryEntry = GameState.inventory[from_index]
	GameState.inventory[from_index] = GameState.inventory[to_index]
	GameState.inventory[to_index] = temp
	GameState.inventory_changed.emit()
	
	#reset last_selected_cell
	last_selected_cell = null


func _on_visibility_changed() -> void:
	if self.visible == true:
		# remove exclusion when visible to allow grabbing input
		GameInputEvents.excluded_gui.erase(self)
	if self.visible == false:
		# exclude when not visible to allow tool use
		GameInputEvents.excluded_gui.append(self)


func _input(event: InputEvent) -> void:
	if event.is_action_released("use"):
		if last_selected_cell != null:
			for cell in all_cells:
				if cell.get_global_rect().has_point(event.global_position):
					on_cell_deselected(cell)
					break
