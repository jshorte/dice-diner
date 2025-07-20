class_name FlatWhiteDiceScoringStrategy extends ScoringStrategy

func calculate_contributions(dice: Dice):
	for entry in dice.collision_log:
		var other_dice: Dice = entry.get("other_dice")

		if other_dice._score_type == G_ENUM.ScoreType.BASE:
			var flat_to_base_contribution = dice.get_flat_flat_value() * other_dice.strategy.get_quality_multiplier(other_dice)
			
			if not dice.contributions.has(other_dice):
				# First dice interaction between these two
				dice.contributions[other_dice] = {
					"type": G_ENUM.DiceType.keys()[other_dice._type],
					"total_contribution": 0,
					"flat_value": dice.get_flat_flat_value(), 
					"base_quality": other_dice.strategy.get_quality_multiplier(other_dice), 
					"collisions": 0
				}
				other_dice.contributions_from[dice] = {
					"type": G_ENUM.DiceType.keys()[dice._type],
					"total_contribution": 0,
					"flat_value": dice.get_flat_flat_value(), 
					"base_quality": other_dice.strategy.get_quality_multiplier(other_dice), 
					"collisions": 0
				}
				print("Added to contributions_from for ", other_dice.dice_name, " from ", dice.dice_name)
				print("Here it is:", other_dice.contributions_from)

			# Multiply the contribution by the number of collisions
			dice.contributions[other_dice]["collisions"] += 1
			dice.contributions[other_dice]["total_contribution"] += flat_to_base_contribution
			other_dice.contributions_from[dice]["collisions"] += 1
			other_dice.contributions_from[dice]["total_contribution"] += flat_to_base_contribution
