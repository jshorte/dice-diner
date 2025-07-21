class_name PizzaDiceScoringStrategy extends ScoringStrategy

func get_score(dice: Dice) -> float:
	return dice.score

func get_score_mapped(dice: Dice) -> float:
	return dice.score * get_quality_multiplier(dice)


func get_score_with_flat(dice: Dice) -> float:
	return (get_score(dice) + get_flat(dice)) * get_quality_multiplier(dice)


func get_quality_multiplier(dice: Dice) -> float:
	return dice._base_quality_multipliers.get(dice._face_value, 1)


func get_reported_score(dice: Dice) -> float:
	return dice.score * get_quality_multiplier(dice)


func get_calculated_score(dice: Dice) -> float:
	return (get_score(dice) + get_flat(dice)) * get_quality_multiplier(dice) * dice.total_multiplier


func get_flat(dice: Dice) -> float:
	return dice._flat_value

func process_score(dice: Dice) -> void:
	var collision_log = create_ordered_log(dice)

	for entry in collision_log:
		var timestamp: int = entry.get("timestamp")
		var other_dice: Dice = entry.get("other_dice")
		if other_dice._score_type == G_ENUM.ScoreType.FLAT:
			dice.set_flat_value(get_flat(dice) + other_dice.strategy.get_flat_mapped(other_dice))
			other_dice.reported_score += other_dice.strategy.get_flat_mapped(other_dice) * get_quality_multiplier(dice)
		elif other_dice._score_type == G_ENUM.ScoreType.MULTIPLIER:
			if other_dice._type == G_ENUM.DiceType.GARLIC:
				process_garlic_interaction(dice, other_dice)							
			else:
				dice.total_multiplier *= other_dice.multiplier_value
				update_multiplier_reported_score(dice, other_dice)

			entry["processed"] = true
			update_other_dice_log(dice, other_dice, timestamp)

	dice.calculated_score = roundi(get_calculated_score(dice))
	dice.reported_score = roundi(get_reported_score(dice))

func calculate_contributions(dice: Dice):
	# dice.contributions[dice] = {
	# 	"type": G_ENUM.DiceType.keys()[dice._type],
	# 	"total_contribution": dice.get_base_score(),
	# 	"base_score": dice.get_type_score(),
	# 	"quality_multiplier": dice.get_base_quality_multiplier()
	# }
	dice.contributions_from[dice] = {
		"type": G_ENUM.DiceType.keys()[dice._type],
		"total_contribution": dice.strategy.get_score_mapped(dice),
		"base_score": get_score(dice),
		"quality_multiplier": dice.strategy.get_quality_multiplier(dice)
	}
