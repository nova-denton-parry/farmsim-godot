class_name CollectibleComponent
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var item = get_parent().item
		if InventoryManager.current_inventory_total < InventoryManager.max_inventory:
			InventoryManager.add_item(item)
			get_parent().queue_free()
