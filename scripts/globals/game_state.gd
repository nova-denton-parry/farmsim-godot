extends Node


# --- Inventory Data ---

var inventory: Array[InventoryEntry] = []

var max_inventory: int = 0
var selected_index: int = 0
var selected_item: Item:
	# check what item is in the selected slot every time data is accessed
	get:
		if selected_index < 0 or selected_index >= inventory.size():
			return null
		return inventory[selected_index].item
	# don't allow attempts to manually set the selected item; it should always be looked
	# up by its index to prevent bugs
	set(_value):
		push_error('GameState: attempted to set selected_item which is read-only; set selected_index instead')

# inventory signals
signal item_added(item: Item)
signal item_removed(item: Item)
signal inventory_changed
signal inventory_resized(new_max: int)


# --- Inventory Management ---

func add_item(item: Item) -> bool:
	# if stackable, look for an existing partial stack first
	if item.max_stack > 1:
		for entry in inventory:
			if entry.item != null and entry.item.item_name == item.item_name:
				if entry.amount < item.max_stack:
					entry.amount += 1
					inventory_changed.emit()
					item_added.emit(item)
					return true
					
	# no stack found (or not stackable) - claim a new slot
	for i in range(inventory.size()):
		if inventory[i].item == null:
			inventory[i] = (InventoryEntry.new(item, 1))
			inventory_changed.emit()
			item_added.emit(item)
			return true
	
	push_warning('GameState: inventory is full, could not add "%s"' % item.item_name)
	return false

func remove_item_at(index: int) -> void:
	# prevent out of range exceptions
	if index < 0 or index >= inventory.size():
		push_error('GameState: tried to remove item at index %d which is out of range' %index)
		return
	# can't remove a non-existent item
	if inventory[index].item == null:
		push_warning('GameState: tried to remove item at index % which contains nothing' %index)
		return
	# if all checks pass, remove item and emit signal before clearing the slot
	inventory[index].amount -= 1
	item_removed.emit(inventory[index].item)
	# if now 0, remove entry (less than 0 shouldn't be possible, but better to be safe)
	if inventory[index].amount <= 0:
		inventory[index].item = null
		inventory[index].amount = 0
	inventory_changed.emit()
	

#func remove_item(item: Item) -> void:
	#for entry in inventory:
		#if entry.item != null and entry.item.item_name == item.item_name:
			#entry.amount -= 1
			#if entry.amount <= 0:
				#entry.item = null
				#entry.amount = 0 # shouldn't be able to go below 0, but better to be safe
			#inventory_changed.emit()
			#item_removed.emit(item)
			#return
	#
	#push_warning('GameState: tried to remove "%s" but it wasn\'t found' % item.item_name)

func set_max_inventory(new_max: int) -> void:
	max_inventory = new_max
	inventory.resize(new_max)
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = InventoryEntry.new(null, 0)
	inventory_resized.emit(new_max)


# --- Save/Load ---

func get_save_data() -> Array:
	# create fixed-size array w/ one entry per slot (to preserve item positioning)
	var data: Array = []
	for entry in inventory:
		if entry.item != null:
			data.append({
				'item_name': entry.item.item_name,
				'amount': entry.amount
			})
		else:
			# empty slot - save a blank entry to preserve position
			data.append({
				'item_name': '',
				'amount': 0
			})
	return data

func load_save_data(data: Array) -> void:
	inventory.clear()
	for entry in data:
		if entry['item_name'] != '':
			var item = ItemManager.get_item(entry['item_name'])
			if item != null:
				inventory.append(InventoryEntry.new(item, entry['amount']))
			else:
				# item name not found in database - preserve empty slot
				push_warning('GameState: attempted to load "%s" into inventory, but could not locate it in the item database' % entry['item_name'])
				inventory.append(InventoryEntry.new(null, 0))
		else:
			# empty slot
			inventory.append(InventoryEntry.new(null, 0))
	# update the inventory size to the loaded array
	max_inventory = inventory.size()
	inventory_changed.emit()
