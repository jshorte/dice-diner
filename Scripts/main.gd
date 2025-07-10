extends Node

var _total_dice_in_play: int = 0
var _stationary_dice_count: int = 0
var _isHUDReady: bool = false
var _isDeckReady: bool = false
var _phase_state: G_ENUM.PhaseState = G_ENUM.PhaseState.PREPARE

@onready var _dice_tree_node = get_node("%Dice")

func _ready():
	SignalManager.hud_manager_ready.connect(_on_hud_manager_ready)
	SignalManager.deck_manager_ready.connect(_on_deck_manager_ready)
	SignalManager.dice_placed.connect(_on_dice_placed)
	SignalManager.dice_started_moving.connect(_on_dice_started_moving)
	SignalManager.dice_finished_moving.connect(_on_dice_finished_moving)
	SignalManager.emit_ready.emit() # Tell children that the main node is ready

# Initialisation
func _on_hud_manager_ready():
	_isHUDReady = true
	_check_all_ready()

func _on_deck_manager_ready():
	_isDeckReady = true
	_check_all_ready()

func _check_all_ready():
	if _isHUDReady and _isDeckReady:
		_phase_state = G_ENUM.PhaseState.PREPARE
		SignalManager.request_deck_load.emit()

func _on_dice_placed(dice: Dice, position: Vector2):
	set_phase_state(G_ENUM.PhaseState.ROLL)
	_dice_tree_node.add_child(dice)
	dice.call_deferred("set_dice_selection", G_ENUM.DiceSelection.ACTIVE)
	dice.call_deferred("set_dice_state", G_ENUM.DiceState.STATIONARY)
	dice.position = position

	_total_dice_in_play = _dice_tree_node.get_child_count()
	_stationary_dice_count = 0
	for d in _dice_tree_node.get_children():
		if d.dice_state == G_ENUM.DiceState.STATIONARY:
			_stationary_dice_count += 1

func set_phase_state(state: G_ENUM.PhaseState):
	if _phase_state == state:
		return

	_phase_state = state
	print("Phase state changed to: ", _phase_state)
	SignalManager.phase_state_changed.emit(_phase_state)


func _on_dice_started_moving():
	_stationary_dice_count -= 1
	print("Stationary dice count: ", _stationary_dice_count, "/", _total_dice_in_play)


func _on_dice_finished_moving():
	_stationary_dice_count += 1
	print("Stationary dice count: ", _stationary_dice_count, "/", _total_dice_in_play)

	if _stationary_dice_count == _total_dice_in_play:
		print("All dice are stationary, setting phase to DRAW")
		# TODO: Work out if we want to draw or select remaining dice
		set_phase_state(G_ENUM.PhaseState.PREPARE)


func _all_dice_stationary() -> bool:
	for dice in _dice_tree_node.get_children():
		if dice.dice_state != G_ENUM.DiceState.STATIONARY:
			return false
	return true


func _reset_dice_counters():
	_total_dice_in_play = 0
	_stationary_dice_count = 0