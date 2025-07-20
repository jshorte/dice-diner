class_name GarlicDiceScoringStrategy extends ScoringStrategy

func calculate_contributions(dice: Dice):
	for entry in dice.collision_log:
		var other_dice: Dice = entry.get("other_dice")

		if other_dice._score_type == G_ENUM.ScoreType.BASE:
			var contribution = get_multiplier_contribution(other_dice, dice)
			
			if not dice.contributions.has(other_dice):
				# First dice interaction between these two
				dice.contributions[other_dice] = {
					"type": G_ENUM.DiceType.keys()[other_dice._type],
					"contribution": contribution, 
					"base_score": other_dice.strategy.get_score_with_flat(other_dice), 
					"multiplier": dice.get_multiplier_value(), 
				}
				other_dice.contributions_from[dice] = {
					"type": G_ENUM.DiceType.keys()[dice._type],
					"contribution": contribution, 
					"base_score": other_dice.strategy.get_score_with_flat(other_dice),
					"multiplier": dice.get_multiplier_value(),
				}
				print("Added to contributions_from for ", other_dice.dice_name, " from ", dice.dice_name)
				print("Here it is:", other_dice.contributions_from)
