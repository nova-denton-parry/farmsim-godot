extends Node

const SAVE_PATH: String = "user://savegame.json"

func save_game(
	inventory_screen: InventoryScreen, 
	player: Player, 
	tilled_soil_layer: TileMapLayer) -> void:
		var save_data = {
			"inventory": get_inventory_data(inventory_screen),
			"player": get_player_data(player),
			"world": get_world_data(tilled_soil_layer)
		}
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify(save_data))
		file.close()


func load_game(inventory_screen: InventoryScreen, player: Player, 
	tilled_soil_layer: TileMapLayer, parent_node: Node2D) -> void:
		# load save file json data
		if not FileAccess.file_exists(SAVE_PATH):
			return
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var save_data = JSON.parse_string(file.get_as_text())
		file.close()
		
		# distribute data to the correct systems
		load_inventory_data(inventory_screen, save_data["inventory"])
		load_player_data(player, save_data["player"])
		load_world_data(save_data["world"], tilled_soil_layer, parent_node)

func get_player_data(player: Player) -> Dictionary:
	return {
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"direction_x": player.player_direction.x,
		"direction_y": player.player_direction.y
	}


func load_player_data(player: Player, data: Dictionary) -> void:
	player.global_position = Vector2(data["position_x"], data["position_y"])
	player.player_direction = Vector2(data["direction_x"], data["direction_y"])


func get_world_data(tilled_soil_layer: TileMapLayer) -> Dictionary:
	# create a dictionary to store world data
	var data = {
		"trees": [],
		"rocks": [],
		"crops": [],
		"tilled_tiles": get_tilled_tile_data(tilled_soil_layer),
		"animals": []
	}
	# add data for all trees
	for tree in get_tree().get_nodes_in_group("trees"):
		var damage_component = tree.get_node("DamageComponent")
		data["trees"].append({
			"position_x": tree.global_position.x,
			"position_y": tree.global_position.y,
			"scene_path": tree.scene_file_path,
			"current_damage": damage_component.current_damage
		})
	# add data for all rocks
	for rock in get_tree().get_nodes_in_group("rocks"):
		var damage_component = rock.get_node("DamageComponent")
		data["trees"].append({
			"position_x": rock.global_position.x,
			"position_y": rock.global_position.y,
			"scene_path": rock.scene_file_path,
			"current_damage": damage_component.current_damage
		})
	# add data for all crops
	for crop in get_tree().get_nodes_in_group("crops"):
		var growth_component = crop.get_node("GrowthCycleComponent")
		data["crops"].append({
			"position_x": crop.global_position.x,
			"position_y": crop.global_position.y,
			"scene_path": crop.scene_file_path,
			"current_growth_state": growth_component.current_growth_state,
			"is_watered": growth_component.is_watered
		})
	# add data for all animals
	for animal in get_tree().get_nodes_in_group("animals"):
		data["animals"].append({
			"position_x": animal.global_position.x,
			"position_y": animal.global_position.y,
			"scene_path": animal.scene_file_path
		})
	
	return data


func load_world_data(data: Dictionary, 
	tilled_soil_layer: TileMapLayer,
	parent_node: Node2D) -> void:
		# clear data to avoid duplicates
		clear_world(tilled_soil_layer)
		await get_tree().process_frame
		
		# load trees
		for tree_data in data["trees"]:
			var tree = load(tree_data["scene_path"]).instantiate()
			tree.global_position = Vector2(tree_data["position_x"], tree_data["position_y"])
			parent_node.add_child(tree)
			tree.get_node("DamageComponent").current_damage = tree_data["current_damage"]
		
		# load rocks
		for rock_data in data["rocks"]:
			var rock = load(rock_data["scene_path"]).instantiate()
			rock.global_position = Vector2(rock_data["position_x"], rock_data["position_y"])
			parent_node.add_child(rock)
			rock.get_node("DamageComponent").current_damage = rock_data["current_damage"]
		
		# load crops
		for crop_data in data["crops"]:
			var crop = load(crop_data["scene_path"]).instantiate()
			crop.global_position = Vector2(crop_data["position_x"], crop_data["position_y"])
			parent_node.add_child(crop)
			crop.set_watered(crop_data["is_watered"])
			crop.get_node("GrowthCycleComponent").current_growth_state = crop_data["current_growth_state"]
		
		# load tilled tiles
		for tile in data["tilled_tiles"]:
			tilled_soil_layer.set_cells_terrain_connect([Vector2i(tile["x"], tile["y"])], 0, 4, true)
		
		# load animals
		for animal_data in data["animals"]:
			var animal = load(animal_data["scene_path"]).instantiate()
			animal.global_position = Vector2(animal_data["position_x"], animal_data["position_y"])
			parent_node.add_child(animal)


func get_tilled_tile_data(tilled_soil_layer: TileMapLayer) -> Array:
	var data: Array = []
	for cell in tilled_soil_layer.get_used_cells():
		data.append({
			"x": cell.x,
			"y": cell.y
		})
	return data


func clear_world(tilled_soil_layer: TileMapLayer) -> void:
	# clear all grouped world objects
	for tree in get_tree().get_nodes_in_group("trees"):
		tree.queue_free()
	for rock in get_tree().get_nodes_in_group("rocks"):
		rock.queue_free()
	for crop in get_tree().get_nodes_in_group("crops"):
		crop.queue_free()
	for animal in get_tree().get_nodes_in_group("animals"):
		animal.queue_free()
	
	# clear tilled tiles
	tilled_soil_layer.clear()


func get_inventory_data(inventory_screen: InventoryScreen) -> Array:
	return inventory_screen.get_save_data()


func load_inventory_data(inventory_screen: InventoryScreen, data: Array) -> void:
	inventory_screen.load_save_data(data)


