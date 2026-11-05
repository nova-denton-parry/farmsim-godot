class_name CollectibleComponent
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var item: Item = get_parent().item
		if GameState.add_item(item):
			get_parent().queue_free()
