class_name PizzaDiceScoringStrategy extends ScoringStrategy

func process_score(dice: Dice) -> void:
	var collision_log = create_ordered_log(dice)

	for entry in collision_log:
		var timestamp: int = entry.get("timestamp")
		var other_dice: Dice = entry.get("other_dice")
		if other_dice._score_type == G_ENUM.ScoreType.FLAT:
			dice.set_flat_value(dice.get_base_flat_value() + other_dice.get_flat_flat_value())
			other_dice.reported_score += other_dice.get_flat_flat_value() * dice.get_base_quality_multiplier()
		elif other_dice._score_type == G_ENUM.ScoreType.MULTIPLIER:
			if other_dice._type == G_ENUM.DiceType.GARLIC:
				process_garlic_interaction(dice, other_dice)							
			else:
				dice.total_multiplier *= other_dice.multiplier_value
				update_multiplier_reported_score(dice, other_dice)

			entry["processed"] = true
			update_other_dice_log(dice, other_dice, timestamp)

	dice.calculated_score = roundi(dice.get_base_calculated_score())
	dice.reported_score = roundi(dice.get_base_reported_score())

func calculate_contributions(dice: Dice):
	# dice.contributions[dice] = {
	# 	"type": G_ENUM.DiceType.keys()[dice._type],
	# 	"total_contribution": dice.get_base_score(),
	# 	"base_score": dice.get_type_score(),
	# 	"quality_multiplier": dice.get_base_quality_multiplier()
	# }
	dice.contributions_from[dice] = {
		"type": G_ENUM.DiceType.keys()[dice._type],
		"total_contribution": dice.get_base_score(),
		"base_score": dice.get_type_score(),
		"quality_multiplier": dice.get_base_quality_multiplier()
	}
