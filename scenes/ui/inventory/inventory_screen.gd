class_name InventoryScreen
extends PanelContainer

@onready var inventory_rows: Array[Node] = self.find_children("InventoryRow*")
@onready var inventory_cells: Array = create_cell_array()
@onready var valid_inventory_cells: Array = update_valid_cell_array()

@onready var tooltip: PanelContainer = UtilFunctions.find_first_in_parents_by_name_and_type(self, "TooltipContainer", "PanelContainer")
@onready var tooltip_label: Label = tooltip.find_child("TooltipLabel")
@onready var texture_rect_container: CenterContainer = UtilFunctions.find_first_in_parents_by_name_and_type(self, "InventorySelectContainer", "CenterContainer")
@onready var texture_rect: TextureRect = texture_rect_container.find_child("InventorySelectSprite")

var last_selected_cell: InventorySquare = null

var _hover_timer: SceneTreeTimer = null

signal inventory_max
signal cell_claimed
signal cell_freed
signal cell_disabled_changed

func _ready() -> void:
	
	InventoryManager.item_added.connect(on_item_added)
	InventoryManager.item_removed.connect(on_item_removed)
	inventory_max.connect(InventoryManager.on_inventory_max)
	cell_claimed.connect(InventoryManager.on_cell_claimed)
	cell_freed.connect(InventoryManager.on_cell_freed)
	
	for row in inventory_cells:
		for cell in row:
			cell.hovered.connect(on_cell_hovered)
			cell.unhovered.connect(on_cell_unhovered)
			cell.item_selected.connect(on_cell_selected)
			cell_disabled_changed.connect(cell.on_cell_disabled_changed)
	
	# start with one row active
	make_cells_invalid(12)
	
	# signal max inventory for tracking
	var total_cells: int = 0
	for row in valid_inventory_cells:
		total_cells += row.size()
	inventory_max.emit(total_cells)
	
	# add tools
	InventoryManager.add_item(ItemManager.get_item("watering can"))
	InventoryManager.add_item(ItemManager.get_item("hoe"))
	InventoryManager.add_item(ItemManager.get_item("pickaxe"))
	InventoryManager.add_item(ItemManager.get_item("axe"))
	
	# add some seeds for testing
	for i in range(3):
		InventoryManager.add_item(ItemManager.get_item("corn seeds"))
	for i in range(3):
		InventoryManager.add_item(ItemManager.get_item("tomato seeds"))


func _process(_delta: float) -> void:
	texture_rect_container.global_position = get_viewport().get_mouse_position() - Vector2(8, 8)


func on_item_added(added_item: Item) -> void:
	var item: Item = added_item
	
	# check if inventory item is stackable
	if item.max_stack > 1:
		# if stackable, search for an existing stack
		for row in valid_inventory_cells:
			for cell in row:
				if cell.current_item != null:
					# if found (and not max amount), add to stack and break
					if item.item_name == cell.current_item.item_name:
						if cell.current_amount < item.max_stack:
							cell.current_amount += 1
							InventoryManager.update_cell_display(cell)
							return
		
	# if no existing stack or item not stackable, find empty cell
	var empty_cell = find_empty_cell()
	empty_cell.current_item = item
	empty_cell.current_amount = 1
	InventoryManager.update_cell_display(empty_cell)
	
	# let inventory_manager know a new cell has been claimed
	cell_claimed.emit()


func on_item_removed(removing_item: Item, selected_cell = null) -> void:
	var item: Item = removing_item
	
	# if given a specific cell (like by using item in hotbar), remove item there if present
	if is_instance_valid(selected_cell.current_item):
		if selected_cell.current_item.item_name == item.item_name:
			selected_cell.current_amount -= 1
			# if this empties the cell, emit the cell was freed
			if selected_cell.current_amount == 0:
				cell_freed.emit()
				selected_cell.current_item = null
			InventoryManager.update_cell_display(selected_cell)
			return
	
	# search for stack with item
	for row in valid_inventory_cells:
		for cell in row:
			if cell.current_item != null:
				if item.item_name == cell.current_item.item_name:
					# stack was found; remove item
					cell.current_amount -= 1
					# if this emptied cell, emit signal
					if cell.current_amount == 0:
						cell_freed.emit()
						cell.current_item = null
					InventoryManager.update_cell_display(cell)
					return


func find_empty_cell() -> Node:
	# search for empty cell
	for row in valid_inventory_cells:
		for cell in row:
			# return empty cell if found
			if not is_instance_valid(cell.current_item):
				return cell
	
	# if no empty cell, return null
	return null


func create_cell_array() -> Array:
	# create an array of all cells and return
	var cell_arrray: Array
	for row in inventory_rows:
		var current_row_array = row.find_children("InventorySquare*")
		cell_arrray.append(current_row_array)
	return cell_arrray


func update_valid_cell_array() -> Array:
	var valid_cell_array: Array
	for row in inventory_cells:
		var current_row_array: Array
		for cell in row:
			if cell.disabled == false:
				current_row_array.append(cell)
		valid_cell_array.append(current_row_array)
	return valid_cell_array


func on_cell_hovered(cell: InventorySquare):
	# do not display if cell has no item
	if not is_instance_valid(cell.current_item):
		return
	
	# if cell has item, update tooltip display
	tooltip_label.text = cell.current_item.item_name
	tooltip.global_position = cell.global_position + Vector2(30, 5)
	
	# update timer & run
	_hover_timer = get_tree().create_timer(1.0)
	await _hover_timer.timeout
	
	# display tooltip if timer is still valid (not cancelled by moving mouse)
	if _hover_timer != null:
		tooltip.visible = true


func on_cell_unhovered():
	# kill timer to prevent accidental display of invalid tooltip
	_hover_timer = null
	
	# clear tooltip to be safe
	tooltip.visible = false
	tooltip_label.text = ""


func on_cell_selected(cell: InventorySquare) -> void:
	if is_instance_valid(cell.current_item):
		# store the item from the clicked square
		last_selected_cell = cell
		
		# dim the selected cell
		cell.texture_rect.modulate.a = 0.5
		
		# create child texture & add to scene
		texture_rect.texture = cell.texture_rect.texture
		texture_rect_container.visible = true


func on_cell_deselected(cell: InventorySquare) -> void:
	# update values to before selection
	texture_rect.texture = null
	texture_rect_container.visible = false
	last_selected_cell.texture_rect.modulate.a = 1.0
	
	# return if previous selected cell is not valid
	if !is_instance_valid(last_selected_cell.current_item):
		return
	
	# if the new cell already has an item, swap them
	if is_instance_valid(cell.current_item):
		# store cell data for transfer
		var item = last_selected_cell.current_item
		var amount = last_selected_cell.current_amount
		
		# move the current cell's item to previous cell
		last_selected_cell.current_item = cell.current_item
		last_selected_cell.current_amount = cell.current_amount
		InventoryManager.update_cell_display(last_selected_cell)
		
		# update the current cell to the previous cell's item
		cell.current_item = item
		cell.current_amount = amount
		InventoryManager.update_cell_display(cell)
	
	# if the new cell is empty, move the item
	else:
		cell.current_item = last_selected_cell.current_item
		cell.current_amount = last_selected_cell.current_amount
		InventoryManager.update_cell_display(cell)
		
		# clear the previous cell
		last_selected_cell.current_item = null
		last_selected_cell.current_amount = 0
		InventoryManager.update_cell_display(last_selected_cell)
	
	# whatever happens, clear previous cell
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
			for row in valid_inventory_cells:
				for cell in row:
					if cell.get_global_rect().has_point(event.global_position):
						on_cell_deselected(cell)
						break


func make_cells_invalid(keep_active_cells: int) -> void:
	var i: int = 0
	for row in inventory_cells:
		for cell in row:
			if i < keep_active_cells:
				i += 1
				continue
			else:
				cell.disabled = true
				cell_disabled_changed.emit()
	valid_inventory_cells = update_valid_cell_array()


func get_save_data() -> Array:
	var data = []
	for row in valid_inventory_cells:
		for cell in row:
			data.append({
				"item_name": cell.current_item.item_name if is_instance_valid(cell.current_item) else "",
				"amount": cell.current_amount
			})
	return data


func load_save_data(data: Array) -> void:
	var i: int = 0
	for row in valid_inventory_cells:
		for cell in row:
			if i < data.size():
				var entry = data[i]
				if entry["item_name"] != "":
					cell.current_item = ItemManager.get_item(entry["item_name"])
					cell.current_amount = entry["amount"]
				else:
					cell.current_item = null
					cell.current_amount = 0
				InventoryManager.update_cell_display(cell)
				i += 1
