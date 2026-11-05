class_name InventoryEntry
extends Node

var item: Item
var amount: int

func _init(item: Item = null, amount: int = 0) -> void:
	self.item = item
	self.amount = amount
