extends Node

var current_inventory_total: int = 0
var max_inventory: int
var selected_item: Item

signal item_added
signal inventory_changed
signal item_removed

func add_item(item: Item):
	item_added.emit(item)

func remove_item(item: Item, cell: InventorySquare = null):
	item_removed.emit(item, cell)
	inventory_changed.emit()


func on_inventory_max(inventory_max: int) -> void:
	# set max inventory to be compared w/ current inventory
	max_inventory = inventory_max


func on_cell_claimed() -> void:
	# each time a new cell is claimed, add one to current inventory amount
	current_inventory_total += 1


func on_cell_freed() -> void:
	# each time a cell is freed, lower the current inventory amount
	current_inventory_total -= 1


func update_cell_display(cell: InventorySquare):
	var texture = cell.find_child("TextureRect")
	var label = cell.find_child("Label")
	if is_instance_valid(cell.current_item):
		texture.texture = cell.current_item.sprite
		if cell.current_item.type != DataTypes.ItemTypes.Tool:
			label.text = str(cell.current_amount)
		else:
			label.text = ""
	else:
		texture.texture = null
		label.text = ""
	if cell.find_parent("Hotbar") == null:
		inventory_changed.emit()
