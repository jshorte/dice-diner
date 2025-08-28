extends Node

var dice_to_score: Array[Dice] = []
var customer_to_score: Array[Customer] = []
var global_collision_log: Array[Dictionary] = []
var total_scores: Dictionary[int, int] = {}
var current_round: int = 1

func _ready() -> void:
	global_collision_log.clear()
	dice_to_score.clear()
	customer_to_score.clear()

	SignalManager.emit_ready.connect(_emit_ready)
	SignalManager.dice_placed.connect(_on_dice_placed)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	SignalManager.clear_global_collision_log.connect(_clear_global_collision_log)
	SignalManager.customer_added.connect(_on_customer_added)
	SignalManager.dice_quality_changed.connect(_on_dice_quality_changed)
	SignalManager.round_incremented.connect(_on_round_incremented)


func _emit_ready():
	SignalManager.score_manager_ready.emit()

func _on_round_incremented(new_round: int):
	current_round = new_round

func _on_dice_quality_changed():
	for d in dice_to_score:
		d.recalulate_score()
	_calculate_score()


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
		for customer in customer_to_score:
			customer.reset_last_mapped_scores()
			customer.snapshot_appetite()
		_calculate_score()
		

func get_global_collision_log() -> Array[Dictionary]:
	return global_collision_log


func _clear_global_collision_log():
	global_collision_log.clear()


func _calculate_score(preview: bool = false):
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

	if not preview:
		for customer in customer_to_score:
			customer.restore_appetite()
			
	for dice in dice_to_score:
		var used_by_customer = false
		for customer in customer_to_score:
			var unique_dice := {}
			for entry in customer.consumption_log:
				var consumed_dice = entry["dice"]
				unique_dice[consumed_dice] = true

			if dice in unique_dice.keys():
				used_by_customer = true
				if dice.get_score_type() == G_ENUM.ScoreType.BASE:
					var mapped_score = customer.get_mapped_appetite_value(dice)
					var last_score = customer.get_last_mapped_score(dice)
					var diff = mapped_score - last_score
					if not preview:
						var appetite_sated = max(0, customer.get_appetite() - diff)
						customer.set_appetite(appetite_sated)
						customer.update_last_mapped_score(dice, mapped_score)
						dice.reset_stored_scores()
	
		if not used_by_customer:
			# dice.set_stored_score(dice.get_calculated_score())
			dice.add_stored_score(current_round, dice.get_calculated_score())

	if not preview:
		for customer in customer_to_score:
			customer.snapshot_appetite()
			
	total_scores[current_round] = round_score
	var total_score = 0
	for score in total_scores.values():
		total_score += score
	SignalManager.score_updated.emit(round_score, total_score, dice_scores)
