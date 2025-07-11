extends Node

var dice_to_score: Array[Dice] = []
var total_score: int = 0

func _ready() -> void:
	SignalManager.emit_ready.connect(_emit_ready)
	SignalManager.dice_placed.connect(_on_dice_placed)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)

func _emit_ready():
	SignalManager.score_manager_ready.emit()

func _on_dice_placed(dice: Dice, position: Vector2):
	dice_to_score.append(dice)

func _on_phase_state_changed(new_state: G_ENUM.PhaseState):
	if new_state == G_ENUM.PhaseState.SCORE:
		_calculate_score()

func _calculate_score():
	var round_score: int = 0

	for dice in dice_to_score:
		round_score += dice.get_score()

	total_score += round_score
	print("Round Score: ", round_score)
	print("Total Score: ", total_score)
	SignalManager.score_completed.emit()
