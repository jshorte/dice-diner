extends Node

var dice_to_score: Array[Dice] = []
var customer_to_score: Array[Customer] = []
var total_score: int = 0
var global_collision_log: Array[Dictionary] = []

func _ready() -> void:
	SignalManager.emit_ready.connect(_emit_ready)
	SignalManager.dice_placed.connect(_on_dice_placed)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	SignalManager.clear_global_collision_log.connect(_clear_global_collision_log)
	SignalManager.customer_added.connect(_on_customer_added)


func _emit_ready():
	SignalManager.score_manager_ready.emit()


func _on_dice_placed(dice: Dice, position: Vector2):
	dice_to_score.append(dice)

func _on_customer_added(customer: Customer):
	customer_to_score.append(customer)
	

func _on_phase_state_changed(new_state: G_ENUM.PhaseState):
	if new_state == G_ENUM.PhaseState.ROLLING:
		for dice in dice_to_score:
			if dice.strategy:
				dice.strategy.set_initial_score(dice)
				
	if new_state == G_ENUM.PhaseState.SCORE:
		_calculate_score()
		

func get_global_collision_log() -> Array[Dictionary]:
	return global_collision_log


func _clear_global_collision_log():
	global_collision_log.clear()


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
		round_score += dice.get_calculated_score()

	for customer in customer_to_score:
		var unique_dice := {}
		for entry in customer.consumption_log:
			var dice = entry["dice"]
			unique_dice[dice] = true

		for dice in unique_dice.keys():
			if dice in dice_scores:
				if dice.get_score_type() == G_ENUM.ScoreType.BASE:
					var mapped_score = customer.get_mapped_appetite_value(dice)
					var appetite_sated = max(0, customer.get_appetite() - mapped_score)
					print("Customer ", customer.name, " consumed ", dice.get_dice_name(), " with score", dice.get_calculated_score() + dice.get_stored_score(), " with mapped score", mapped_score, ". Remaining appetite: ", appetite_sated)
					customer.set_appetite(appetite_sated)

	total_score += round_score

	SignalManager.score_updated.emit(round_score, total_score, dice_scores)
