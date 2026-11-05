extends Node2D

@onready var player: Player = $World/Player
@onready var tilled_soil_layer: TileMapLayer = $World/GameTileMap/TilledSoil
@onready var parent_node: Node2D = $World/GameTileMap
@onready var menu_screen: PanelContainer = $UI/GameScreen/MarginContainer/TabContainer/MenuScreen

func _ready() -> void:
	SaveManager.load_game(player, tilled_soil_layer, parent_node)
	menu_screen.save_requested.connect(on_save_requested)
	menu_screen.load_requested.connect(on_load_requested)


func on_save_requested() -> void:
	SaveManager.save_game(player, tilled_soil_layer)

func on_load_requested() -> void:
	SaveManager.load_game(player, tilled_soil_layer, parent_node)
