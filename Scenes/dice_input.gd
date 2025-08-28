class_name DiceInput extends Node2D


var _dice: Dice
var _phase_state: G_ENUM.PhaseState

func _ready():
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)

func _on_phase_state_changed(new_state):
	_phase_state = new_state


func _input(event):
	if _dice.dice_selection != G_ENUM.DiceSelection.ACTIVE:
		if handle_mouse_click(event):
			return
		return
	if handle_launch_input(event):
		return
	if handle_prediction_input(event):
		return


func handle_launch_input(event) -> bool:
	# Use _dice's methods and properties as needed
	if event is InputEventMouseButton and \
	event.button_index == MOUSE_BUTTON_LEFT and \
	event.pressed and \
	_phase_state == G_ENUM.PhaseState.ROLL:
		var direction: Vector2 = -_dice.get_input_direction()
		var strength: float = _dice.get_impulse_strength()
		_dice.set_dice_selection(G_ENUM.DiceSelection.INACTIVE)
		_dice.visual.reset_ghost_sprite()
		SignalManager.request_dice_impulse.emit(_dice, direction, strength)
		SignalManager.dice_launched.emit()
		return true
	return false


func handle_prediction_input(event) -> bool:
	if _dice.dice_state == G_ENUM.DiceState.STATIONARY and (event is InputEventMouseMotion or event is InputEventMouseButton):
		_dice.visual.update_arrow(_dice._dice_radius, _dice.global_position.angle_to_point(get_global_mouse_position()), _dice.global_position)
		_dice.visual.queue_redraw()
		return true
	return false


func handle_mouse_click(event) -> bool:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var options_hbox: HBoxContainer = _dice._dice_options
		var mouse_pos: Vector2 = options_hbox.get_global_mouse_position()
		if not options_hbox.get_global_rect().has_point(mouse_pos):
			_dice._dice_data_panel.hide()
			return true
	return false
