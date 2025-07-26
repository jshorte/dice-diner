class_name GarlicDiceScoringStrategy extends ScoringStrategy

func get_multiplier(dice: Dice) -> float:
	return dice._multiplier_value


func get_multiplier_map(dice: Dice) -> float:
	return dice.get_multiplier_map().get(get_face_value(dice), 1)


func get_multiplier_mapped(dice: Dice) -> float:
	return get_multiplier(dice) * get_multiplier_map(dice)

func get_score_breakdown(dice: Dice) -> Dictionary:
	var applied_str = ""
	var total_contribution = 0.0
	for other_dice in dice.contributions.keys():
		var multiplier = other_dice.strategy.get_multiplier_mapped(other_dice)
		var details = dice.contributions[other_dice]
		var pizza_name = other_dice.get_dice_name()
		var base_score = details.get("base_score", 0)
		var contribution = details.get("contribution", 0)

		applied_str += ("Multiplied %s's score [%d] by [x%.1f] for an increase of: %d\n" % [
			pizza_name, base_score, dice.strategy.get_multiplier_mapped(dice), contribution])
			
		total_contribution += contribution

	return {
		# "multiplier": dice.strategy.get_multiplier_mapped(dice),
		"applied": applied_str,
		"total": total_contribution
	}
