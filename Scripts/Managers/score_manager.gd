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
	var dice_scores: Array[Dice] = []

	for dice in dice_to_score:
		dice.contributions = {}
		dice.contributions_from = {}

	for dice in dice_to_score:
		if dice.strategy:
			dice.strategy.process_score(dice)

	# Calculate contributions after processing scores
	for dice in dice_to_score:
		if dice.strategy:
			dice.strategy.calculate_contributions(dice)

		dice_scores.append(dice)
		
	for dice in dice_to_score:
		round_score += dice.calculated_score
	
	total_score += round_score

	for dice in dice_scores:
		print("Dice: ", dice.dice_name, " Score: ", dice.calculated_score, " Reported: ", dice.reported_score, " Base: ", dice.get_base_score(), " Multiplier: ", dice.get_multiplier_value(), " Flat: ", dice.get_flat_value())

	SignalManager.score_updated.emit(round_score, total_score, dice_scores)
