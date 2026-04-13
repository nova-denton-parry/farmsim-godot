extends CanvasLayer


@onready var tree: SceneTree = get_tree()
@onready var tab_container: TabContainer = self.find_child("TabContainer")
@onready var tooltip: PanelContainer = self.find_child("TooltipContainer")


func _input(event: InputEvent) -> void:	
	if event.is_action_pressed("inventory"):
		if !tree.paused:
			tree.paused = true
			tab_container.visible = true
		
		else:
			close_inventory()
			
	if event.is_action_pressed("ui_cancel"):
		if tab_container.visible == true:
			close_inventory()


func close_inventory():
	tree.paused = false
	tab_container.visible = false
	tooltip.visible = false # fallback because of occassional visual glitch
