extends PanelContainer

@onready var tool_axe: Button = $MarginContainer/HBoxContainer/ToolAxe
@onready var tool_tilling: Button = $MarginContainer/HBoxContainer/ToolTilling
@onready var tool_watering: Button = $MarginContainer/HBoxContainer/ToolWatering
@onready var tool_corn: Button = $MarginContainer/HBoxContainer/ToolCorn
@onready var tool_tomato: Button = $MarginContainer/HBoxContainer/ToolTomato

func _on_tool_axe_pressed() -> void:
	if !ToolManager.selected_tool == DataTypes.Tools.AxeWood:
		ToolManager.select_tool(DataTypes.Tools.AxeWood)
	else:
		ToolManager.select_tool(DataTypes.Tools.None)


func _on_tool_pickaxe_pressed() -> void:
	if !ToolManager.selected_tool == DataTypes.Tools.MineRock:
		ToolManager.select_tool(DataTypes.Tools.MineRock)
	else:
		ToolManager.select_tool(DataTypes.Tools.None)
	

func _on_tool_tilling_pressed() -> void:
	if !ToolManager.selected_tool == DataTypes.Tools.TillGround:
		ToolManager.select_tool(DataTypes.Tools.TillGround)
	else:
		ToolManager.select_tool(DataTypes.Tools.None)


func _on_tool_watering_pressed() -> void:
	if !ToolManager.selected_tool == DataTypes.Tools.WaterCrops:
		ToolManager.select_tool(DataTypes.Tools.WaterCrops)
	else:
		ToolManager.select_tool(DataTypes.Tools.None)


func _on_tool_corn_pressed() -> void:
	if !ToolManager.selected_tool == DataTypes.Tools.PlantCorn:
		ToolManager.select_tool(DataTypes.Tools.PlantCorn)
	else:
		ToolManager.select_tool(DataTypes.Tools.None)

func _on_tool_tomato_pressed() -> void:
	if !ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
		ToolManager.select_tool(DataTypes.Tools.PlantTomato)
	else:
		ToolManager.select_tool(DataTypes.Tools.None)
