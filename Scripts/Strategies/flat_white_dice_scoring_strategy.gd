class_name FlatWhiteDiceScoringStrategy extends ScoringStrategy

func get_flat_map(dice: Dice) -> int:
	return dice.get_flat_map().get(get_face_value(dice), 1)

func get_flat_mapped(dice: Dice) -> int:
	return get_flat(dice) + get_flat_map(dice)

func calculate_contributions(dice: Dice):
	for entry in dice.collision_log:
		var other_dice: Dice = entry.get("other_dice")

		if other_dice.get_score_type() == G_ENUM.ScoreType.BASE:
			var flat_to_base_contribution = get_flat_mapped(dice) * other_dice.strategy.get_score_map(other_dice)
			
			if not dice.contributions.has(other_dice):
				# First dice interaction between these two
				dice.contributions[other_dice] = {
					"type": G_ENUM.DiceType.keys()[other_dice.get_dice_type()],
					"total_contribution": 0,
					"flat_value": get_flat_mapped(dice), 
					"base_quality": other_dice.strategy.get_score_map(other_dice), 
					"collisions": 0
				}
				other_dice.contributions_from[dice] = {
					"type": G_ENUM.DiceType.keys()[dice.get_dice_type()],
					"total_contribution": 0,
					"flat_value": get_flat_mapped(dice), 
					"base_quality": other_dice.strategy.get_score_map(other_dice), 
					"collisions": 0
				}

			# Multiply the contribution by the number of collisions
			dice.contributions[other_dice]["collisions"] += 1
			dice.contributions[other_dice]["total_contribution"] += flat_to_base_contribution
			other_dice.contributions_from[dice]["collisions"] += 1
			other_dice.contributions_from[dice]["total_contribution"] += flat_to_base_contribution
