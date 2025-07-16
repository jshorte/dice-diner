extends Node

var _total_dice_in_play: int = 0
var _stationary_dice_count: int = 0
var _isHUDReady: bool = false
var _isDeckReady: bool = false
var _isScoreReady: bool = false
var _isScoreBarReady: bool = false
var _phase_state: G_ENUM.PhaseState = G_ENUM.PhaseState.PREPARE

@onready var _active_dice_tree_node = get_node("%ActiveDice")
@onready var _pending_dice_node = get_node("%PendingDice")

#region Initialisation
############################################################
####					Initialisation					####
############################################################
func _ready():
	SignalManager.hud_manager_ready.connect(_on_hud_manager_ready)
	SignalManager.deck_manager_ready.connect(_on_deck_manager_ready)
	SignalManager.score_manager_ready.connect(_on_score_manager_ready)
	SignalManager.score_bar_manager_ready.connect(_on_score_bar_manager_ready)
	SignalManager.dice_placed.connect(_on_dice_placed)
	SignalManager.dice_started_moving.connect(_on_dice_started_moving)
	SignalManager.dice_finished_moving.connect(_on_dice_finished_moving)
	SignalManager.score_completed.connect(_on_score_completed)
	SignalManager.draw_completed.connect(_on_draw_completed)
	SignalManager.emit_ready.emit() # Tell children that the main node is ready


func _on_hud_manager_ready():
	_isHUDReady = true
	_check_all_ready()


func _on_deck_manager_ready():
	_isDeckReady = true
	_check_all_ready()


func _on_score_manager_ready():
	_isScoreReady = true
	_check_all_ready()

func _on_score_bar_manager_ready():
	_isScoreBarReady = true
	_check_all_ready()


func _check_all_ready():
	if _isHUDReady and _isDeckReady and _isScoreReady and _isScoreBarReady:
		_phase_state = G_ENUM.PhaseState.PREPARE
		SignalManager.request_deck_load.emit()
#endregion Initialisation
#region Dice Logic
########################################################
####					Dice Logic					####
########################################################
func _on_dice_started_moving():
	_stationary_dice_count -= 1
	print("Stationary dice count: ", _stationary_dice_count, "/", _total_dice_in_play)


func _reset_dice_counters():
	_total_dice_in_play = 0
	_stationary_dice_count = 0
#endregion Dice Logic
#region State Management
################################################################
####					STATE MANAGEMENT					####
################################################################
func set_phase_state(state: G_ENUM.PhaseState):
	if _phase_state == state:
		return

	_phase_state = state

	await get_tree().create_timer(1.0).timeout

	print("Phase state changed to: ", _phase_state)
	
		
	SignalManager.phase_state_changed.emit(_phase_state)


func _on_dice_placed(dice: Dice, position: Vector2):
	SignalManager.remove_placed_dice.emit(dice)
	set_phase_state(G_ENUM.PhaseState.ROLL)
	_pending_dice_node.remove_child(dice)
	_active_dice_tree_node.add_child(dice)
	dice.sleeping = false
	dice.contact_monitor = true
	dice.call_deferred("set_dice_selection", G_ENUM.DiceSelection.ACTIVE)
	dice.call_deferred("set_dice_state", G_ENUM.DiceState.STATIONARY)
	dice.position = position

	_total_dice_in_play = _active_dice_tree_node.get_child_count()
	_stationary_dice_count = 0
	for d in _active_dice_tree_node.get_children():
		if d.dice_state == G_ENUM.DiceState.STATIONARY:
			_stationary_dice_count += 1


func _on_dice_finished_moving():
	_stationary_dice_count += 1

	if _stationary_dice_count == _total_dice_in_play:
		set_phase_state(G_ENUM.PhaseState.SCORE)


func _on_score_completed():
	SignalManager.reset_dice_score.emit()
	set_phase_state(G_ENUM.PhaseState.DRAW)


func _on_draw_completed():
	set_phase_state(G_ENUM.PhaseState.PREPARE)
#endregion State Management