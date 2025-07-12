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
		_process_dice(dice)
		dice.calculated_score = dice.get_score()
		round_score += dice.calculated_score
		dice_scores.append(dice)
	total_score += round_score
	SignalManager.score_updated.emit(round_score, total_score, dice_scores)
	SignalManager.score_completed.emit()

## Modify dice scores based on unique dice interactions
func _process_dice(dice: Dice):
	for entry in dice.collision_log:
		if entry.get("processed", false):
			continue

		## Unique interaction logic

		var other_dice = entry.get("other_dice")
		entry["processed"] = true

		for other_entry in other_dice.collision_log:
			if other_entry.get("other_dice") == dice \
			and other_entry.get("timestamp") == entry.get("timestamp") \
			and not other_entry.get("processed", false):
				other_entry["processed"] = true
				break
