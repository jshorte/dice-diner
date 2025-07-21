class_name PizzaDiceScoringStrategy extends ScoringStrategy

func get_score(dice: Dice) -> float:
	return dice.score

func get_score_mapped(dice: Dice) -> float:
	return dice.score * get_score_map(dice)

func get_score_with_flat(dice: Dice) -> float:
	return (get_score(dice) + get_flat(dice)) * get_score_map(dice)

func get_total_multiplier(dice: Dice) -> float:
	return dice._total_multiplier

func get_score_map(dice: Dice) -> float:
	return dice._score_map.get(get_face_value(dice), 1)

func get_reported_score(dice: Dice) -> float:
	return dice.score * get_score_map(dice)

func get_calculated_score(dice: Dice) -> float:
	print("get_calculated_score called for ", dice.name, " with score: ", get_score(dice), " and flat: ", get_flat(dice), " and score map: ", get_score_map(dice), " and total multiplier: ", get_total_multiplier(dice))
	return (get_score(dice) + get_flat(dice)) * get_score_map(dice) * get_total_multiplier(dice)


func process_score(dice: Dice) -> void:
	var collision_log = create_ordered_log(dice)
	var multipliers = []
	var processed_garlic = {}

	for entry in collision_log:
		var other_dice: Dice = entry.get("other_dice")
		if other_dice._score_type == G_ENUM.ScoreType.FLAT:
			dice.set_flat_value(get_flat(dice) + other_dice.strategy.get_flat_mapped(other_dice))
			other_dice.reported_score += other_dice.strategy.get_flat_mapped(other_dice) * get_score_map(dice)

	for entry in collision_log:
		var other_dice: Dice = entry.get("other_dice")
		if other_dice._score_type == G_ENUM.ScoreType.MULTIPLIER:
			if not processed_garlic.has(other_dice):
				multipliers.append(other_dice)
				processed_garlic[other_dice] = true

	var running_multiplier = 1.0
	var base_score = (get_score(dice) + get_flat(dice)) * get_score_map(dice)
	var score_before = base_score
	for garlic in multipliers:
		var garlic_multiplier = garlic.strategy.get_multiplier_mapped(garlic)
		running_multiplier *= garlic_multiplier
		var score_after = base_score * running_multiplier
		var garlic_contribution = score_after - score_before

		garlic.contributions[dice] = {
			"type": G_ENUM.DiceType.keys()[dice._dice_type],
			"contribution": garlic_contribution,
			"base_score": score_before,
			"multiplier": garlic_multiplier
		}
		dice.contributions_from[garlic] = {
			"type": G_ENUM.DiceType.keys()[garlic._dice_type],
			"contribution": garlic_contribution,
			"base_score": score_before,
			"multiplier": garlic_multiplier
		}
		garlic.reported_score += garlic_contribution
		score_before = score_after

	dice.set_total_multiplier(running_multiplier)
	dice.calculated_score = roundi(get_calculated_score(dice))
	dice.reported_score = roundi(get_reported_score(dice))

func calculate_contributions(dice: Dice):
	dice.contributions_from[dice] = {
		"type": G_ENUM.DiceType.keys()[dice._dice_type],
		"total_contribution": get_score_mapped(dice),
		"base_score": get_score(dice),
		"quality_multiplier": get_score_map(dice)
	}
