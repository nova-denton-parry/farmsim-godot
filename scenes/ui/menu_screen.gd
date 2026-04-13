extends PanelContainer

@onready var save_button: Button = $MarginContainer/VBoxContainer/SaveButton
@onready var load_button: Button = $MarginContainer/VBoxContainer/LoadButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton
@onready var status_panel: PanelContainer = $StatusPanel
@onready var status_label: Label = $StatusPanel/MarginContainer/StatusLabel
@onready var quit_dialog: PanelContainer = $QuitDialog
@onready var save_quit_button: Button = $QuitDialog/MarginContainer/VBoxContainer/SaveQuitButton
@onready var just_quit_button: Button = $QuitDialog/MarginContainer/VBoxContainer/JustQuitButton
@onready var cancel_button: Button = $QuitDialog/MarginContainer/VBoxContainer/CancelButton

var _status_timer: SceneTreeTimer = null

signal save_requested
signal load_requested

func _ready() -> void:
	save_button.pressed.connect(on_save_pressed)
	load_button.pressed.connect(on_load_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	
	save_quit_button.pressed.connect(on_save_quit_pressed)
	just_quit_button.pressed.connect(on_just_quit_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)


func on_save_pressed() -> void:
	save_requested.emit()
	show_status("Game saved successfully!")

func on_load_pressed() -> void:
	load_requested.emit()
	show_status("Game loaded successfully!")

func on_quit_pressed() -> void:
	quit_dialog.visible = true


func show_status(message: String) -> void:
	status_label.text = message
	status_panel.visible = true
	_status_timer = get_tree().create_timer(2.0)
	await _status_timer.timeout
	status_panel.visible = false


func on_save_quit_pressed() -> void:
	save_requested.emit()
	await get_tree().process_frame
	get_tree().quit()

func on_just_quit_pressed() -> void:
	get_tree().quit()

func on_cancel_pressed() -> void:
	quit_dialog.visible = false
