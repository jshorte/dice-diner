class_name FlatWhiteDiceScoringStrategy extends ScoringStrategy

func get_flat_map(dice: Dice) -> int:
	return dice.get_flat_map().get(get_face_value(dice), 1)

func get_flat_mapped(dice: Dice) -> int:
	return get_flat(dice) + get_flat_map(dice)

func calculate_contributions(dice: Dice):
	for entry in dice.collision_log:
		var other_dice: Dice = entry.get("other_dice")

		if other_dice.get_score_type() == G_ENUM.ScoreType.BASE:
			var flat_to_base_contribution = get_flat_mapped(dice) * \
			other_dice.strategy.get_score_map(other_dice) * \
			other_dice.strategy.get_course_multiplier(other_dice)

			if not dice.contributions.has(other_dice):
				# First dice interaction between these two
				dice.contributions[other_dice] = {
					"type": G_ENUM.DiceType.keys()[other_dice.get_dice_type()],
					"total_contribution": 0,
					"flat_value": get_flat_mapped(dice), 
					"base_quality": other_dice.strategy.get_score_map(other_dice), 
					"course_multiplier": other_dice.strategy.get_course_multiplier(other_dice),
					"collisions": 0
				}
				other_dice.contributions_from[dice] = {
					"type": G_ENUM.DiceType.keys()[dice.get_dice_type()],
					"total_contribution": 0,
					"flat_value": get_flat_mapped(dice), 
					"base_quality": other_dice.strategy.get_score_map(other_dice),
					"course_multiplier": other_dice.strategy.get_course_multiplier(other_dice),
					"collisions": 0
				}

			# Multiply the contribution by the number of collisions
			dice.contributions[other_dice]["collisions"] += 1
			dice.contributions[other_dice]["total_contribution"] += flat_to_base_contribution
			other_dice.contributions_from[dice]["collisions"] += 1
			other_dice.contributions_from[dice]["total_contribution"] += flat_to_base_contribution

func get_score_breakdown(dice: Dice) -> Dictionary:
	var applied_str = ""
	for pizza in dice.contributions.keys():
		var details = dice.contributions[pizza]
		var pizza_name = pizza.get_dice_name()
		var course_multiplier = pizza.strategy.get_course_multiplier(pizza)
		var quality_multiplier = details.get("base_quality", 1)
		var collisions = details.get("collisions", 1)
		var collision_str = "collision" if collisions == 1 else "collisions"
		var contribution = details.get("total_contribution", 0)

		applied_str += "Flat value [%d] multiplied by %s's quality [x%d] and bonus [x%d] and %s [x%d] = %d\n" % [
			get_flat_mapped(dice), pizza_name, quality_multiplier, course_multiplier, collision_str, collisions, contribution]

	var total_contribution = 0

	for details in dice.contributions.values():
		total_contribution += details.get("total_contribution", 0)

	return {
		# "flat": get_flat_mapped(dice),
		"applied": applied_str,
		"total": total_contribution
	}
