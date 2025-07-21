class_name GarlicDiceScoringStrategy extends ScoringStrategy

func get_multiplier(dice: Dice) -> float:
	return dice._multiplier_value


func get_multiplier_map(dice: Dice) -> float:
	return dice.get_multiplier_map().get(get_face_value(dice), 1)


func get_multiplier_mapped(dice: Dice) -> float:
	return get_multiplier(dice) * get_multiplier_map(dice)
