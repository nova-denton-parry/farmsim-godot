extends PanelContainer
class_name InventorySquare

var active: bool = false
@export var disabled: bool = false
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var label: Label = $Label

signal hovered
signal unhovered

signal item_selected

func _ready() -> void:
	if disabled == true:
		self.theme_type_variation = "DisabledInventoryItemPanel"
	if active == true:
		self.theme_type_variation = "ActiveHotbarItem"

func _on_mouse_entered() -> void:
	hovered.emit(self)


func _on_mouse_exited() -> void:
	unhovered.emit()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("use"):
		item_selected.emit(self)


func on_cell_disabled_changed() -> void:
	if disabled == true:
		self.theme_type_variation = "DisabledInventoryItemPanel"
	else:
		self.theme_type_variation = "InventoryItemPanel"


func on_active_changed() -> void:
	if active == true:
		self.theme_type_variation = "ActiveHotbarItem"
	else:
		self.theme_type_variation = "InventoryItemPanel"

func show_entry(entry: InventoryEntry) -> void:
	if entry != null and entry.item != null:
		texture_rect.texture = entry.item.sprite
		if entry.item.max_stack > 1:
			label.text = str(entry.amount)
		else:
			label.text = ''
	else:
		texture_rect.texture = null
		label.text = ''
