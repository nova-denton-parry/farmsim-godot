extends Node

static var direction: Vector2

# make diagonal direction constant-based to avoid retyping
const diag_direction = 0.65
const neg_diag_direction = 0 - diag_direction
const up_left: Vector2 = Vector2(neg_diag_direction, neg_diag_direction)
const up_right: Vector2 = Vector2(diag_direction, neg_diag_direction)
const down_left: Vector2 = Vector2(neg_diag_direction, diag_direction)
const down_right: Vector2 = Vector2(diag_direction, diag_direction)
static var excluded_gui: Array[Control] = []

func check_mouse_over_gui() -> bool:
	var hovered = Engine.get_main_loop().root.get_viewport().gui_get_hovered_control()
	if hovered == null:
		return false
	for excluded in excluded_gui:
		if excluded != null && (excluded == hovered || excluded.is_ancestor_of(hovered)):
			return false
	return true

func movement_input() -> Vector2:
	if Input.is_action_pressed("walk_up") && Input.is_action_pressed("walk_left"):
		direction = up_left
	elif Input.is_action_pressed("walk_up") && Input.is_action_pressed("walk_right"):
		direction = up_right
	elif Input.is_action_pressed("walk_down") && Input.is_action_pressed("walk_left"):
		direction = down_left
	elif Input.is_action_pressed("walk_down") && Input.is_action_pressed("walk_right"):
		direction = down_right
	elif Input.is_action_pressed("walk_left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("walk_right"):
		direction = Vector2.RIGHT
	elif Input.is_action_pressed("walk_up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("walk_down"):
		direction = Vector2.DOWN
	else:
		direction = Vector2.ZERO
	
	return direction


func is_movement_input() -> bool:
	if direction == Vector2.ZERO:
		return false
	else:
		return true


func use_tool() -> bool:
	if check_mouse_over_gui():
		return false
	if get_tree().paused == true:
		return false
	else:
		var use_tool_value: bool = Input.is_action_pressed("use")
		return use_tool_value


func interact() -> bool:
	if check_mouse_over_gui():
		return false
	else:
		var interact_value: bool = Input.is_action_pressed("interact")
		return interact_value
