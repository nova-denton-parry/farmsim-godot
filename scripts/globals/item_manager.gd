extends Node

var database: ItemDatabase = load("uid://brwrejc2k7kxq")

func get_item(item_name: String) -> Item:
	for item in database.items:
		if item.item_name == item_name:
			return item.duplicate()
	return null
