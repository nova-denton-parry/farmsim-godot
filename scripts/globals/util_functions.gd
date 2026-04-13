extends Node

func find_all_in_parents_by_type(node: Node, type: String) -> Array[Node]:
	var current = node.get_parent()
	while current:
		var results = current.find_children("*", type)
		if results.size() > 0:
			return results
		current = current.get_parent()
	return []


func find_first_in_parents_by_type(node: Node, type: String) -> Node:
	var node_array = find_all_in_parents_by_type(node, type)
	if node_array.size() > 0:
		return node_array[0]
	return null


func find_all_in_parents_by_name_and_type(node: Node, searchName: String, type: String) -> Array[Node]:
	var current = node.get_parent()
	while current:
		var results = current.find_children("*%s*" %searchName, type)
		if results.size() > 0:
			return results
		current = current.get_parent()
	return []


func find_first_in_parents_by_name_and_type(node: Node, searchName: String, type: String) -> Node:
	var node_array = find_all_in_parents_by_name_and_type(node, searchName, type)
	if node_array.size() > 0:
		return node_array[0]
	return null
