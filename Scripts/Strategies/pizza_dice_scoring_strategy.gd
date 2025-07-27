class_name PizzaDiceScoringStrategy extends ScoringStrategy

func get_score(dice: Dice) -> float:
	return dice.get_score()


func get_score_map(dice: Dice) -> float:
	return dice.get_score_map().get(get_face_value(dice), 1)


func get_score_mapped(dice: Dice) -> float:
	return dice.get_score() * get_score_map(dice)


func get_score_with_flat(dice: Dice) -> float:
	return (get_score(dice) + get_flat(dice)) * get_score_map(dice) * get_course_multiplier(dice)


func get_course_multiplier(dice: Dice) -> float:
	var course_multiplier: float = 1.0
	if dice._starter_bonus_applied:
		course_multiplier *= get_starter_multiplier()
	if dice._dessert_bonus_applied:
		course_multiplier *= get_dessert_multiplier()
	return course_multiplier


func get_total_multiplier(dice: Dice) -> float:
	return dice.get_total_multiplier()


func get_reported_score(dice: Dice) -> float:
	return get_score(dice) * get_score_map(dice) * get_course_multiplier(dice)


func get_calculated_score(dice: Dice) -> float:
	return (get_score(dice) + get_flat(dice)) * get_course_multiplier(dice) * get_score_map(dice) * get_total_multiplier(dice)


func process_score(dice: Dice) -> void:
	var collision_log = create_ordered_log(dice)

	# set_course_multiplier_flags(dice, collision_log)
	set_course_multiplier_flags_from_global_log()
	process_flat_in_log(dice, collision_log)
	process_multiplier_in_log(dice, collision_log)

	dice.set_calculated_score(roundi(get_calculated_score(dice)))
	dice.set_reported_score(roundi(get_reported_score(dice)))

func calculate_contributions(dice: Dice):
	dice.contributions_from[dice] = {
		"type": G_ENUM.DiceType.keys()[dice.get_dice_type()],
		"total_contribution": get_score_mapped(dice),
		"base_score": get_score(dice),
		"quality_multiplier": get_score_map(dice)
	}

func get_score_breakdown(dice: Dice) -> Dictionary:
	var base = get_score(dice)
	var quality = get_score_map(dice)
	var course_multi = get_course_multiplier(dice)
	var total = get_reported_score(dice)

	var course_str = ""
	if dice._starter_bonus_applied and dice._dessert_bonus_applied:
		course_str = "Starter and Dessert bonus: (x%.1f + x%.1f)\n" % [get_starter_multiplier(), get_dessert_multiplier()]
	elif dice._starter_bonus_applied:
		course_str = "Starter bonus: x%.1f\n" % [get_starter_multiplier()]
	elif dice._dessert_bonus_applied:
		course_str = "Dessert bonus: x%.1f\n" % [get_dessert_multiplier()]

	return {
		"base": base,
		"quality": quality,
		"course": course_str,
		"total": total,
	}


func set_course_multiplier_flags_from_global_log() -> void:
	var global_collision_log = ScoreManager.get_global_collision_log()

	if not global_collision_log:
		print("No global collision log available.")
		return

	for entry in global_collision_log:
		entry["dice"]._starter_bonus_applied = false
		entry["other_dice"]._starter_bonus_applied = false

	if global_collision_log.size() > 0:
		var first_entry = global_collision_log[0]
		var dice_a = first_entry["dice"]
		var dice_b = first_entry["other_dice"]

		for d in [dice_a, dice_b]:
			if G_ENUM.Course.STARTER in d._dice_courses:
				d._starter_bonus_applied = true
				print("Starter bonus applied to: ", d.get_dice_name())

	if global_collision_log.size() > 0:
		var last_entry = global_collision_log[global_collision_log.size() - 1]
		var dice_a = last_entry["dice"]
		var dice_b = last_entry["other_dice"]

		for d in [dice_a, dice_b]:
			if G_ENUM.Course.DESSERT in d._dice_courses:
				d._dessert_bonus_applied = true
				print("Dessert bonus applied to: ", d.get_dice_name())


func process_flat_in_log(dice: Dice, collision_log: Array) -> void:
		for entry in collision_log:
			var other_dice: Dice = entry.get("other_dice")
			if other_dice.get_score_type() == G_ENUM.ScoreType.FLAT:
				dice.set_flat_value(get_flat(dice) + other_dice.strategy.get_flat_mapped(other_dice))
				other_dice.set_reported_score(
					other_dice.get_reported_score() + (
						other_dice.strategy.get_flat_mapped(other_dice) *
						get_score_map(dice) *
						get_course_multiplier(dice)
					)
				)


func process_multiplier_in_log(dice: Dice, collision_log: Array) -> void:
		var processed_garlic: Dictionary[Dice, bool] = {}
		var multipliers: Array[Dice] = []

		for entry in collision_log:
			var other_dice: Dice = entry.get("other_dice")
			if other_dice.get_score_type() == G_ENUM.ScoreType.MULTIPLIER:
				if not processed_garlic.has(other_dice):
					multipliers.append(other_dice)
					processed_garlic[other_dice] = true

		var running_multiplier = 1.0
		var base_score = (get_score(dice) + get_flat(dice)) * get_score_map(dice) * get_course_multiplier(dice)
		var score_before = base_score
		for garlic in multipliers:
			var garlic_multiplier = garlic.strategy.get_multiplier_mapped(garlic)
			running_multiplier *= garlic_multiplier
			var score_after = base_score * running_multiplier
			var garlic_contribution = score_after - score_before

			garlic.contributions[dice] = {
				"type": G_ENUM.DiceType.keys()[dice.get_dice_type()],
				"contribution": garlic_contribution,
				"base_score": score_before,
				"multiplier": garlic_multiplier
			}
			dice.contributions_from[garlic] = {
				"type": G_ENUM.DiceType.keys()[garlic.get_dice_type()],
				"contribution": garlic_contribution,
				"base_score": score_before,
				"multiplier": garlic_multiplier
			}
			garlic.set_reported_score(garlic.get_reported_score() + garlic_contribution)
			score_before = score_after

		dice.set_total_multiplier(running_multiplier)
