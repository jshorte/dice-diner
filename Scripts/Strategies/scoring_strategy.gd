class_name ScoringStrategy

func process_score(_dice: Dice) -> void:
	pass

func calculate_contributions(_dice: Dice):
	pass

func sort_log_by_timestamp(collision_log: Array[Dictionary]):
	collision_log.sort_custom(func(a, b): return a["timestamp"] < b["timestamp"])
	return collision_log

func create_ordered_log(dice: Dice):
	var score_type_filtered_log = []
	var score_types: Array[G_ENUM.ScoreType] = [
		G_ENUM.ScoreType.BASE,
		G_ENUM.ScoreType.FLAT,
		G_ENUM.ScoreType.MULTIPLIER,
	]

	for entry in dice.collision_log:
		if entry.get("processed", false):
			continue		

	var time_sorted_log = sort_log_by_timestamp(dice.collision_log)		

	for score_type in score_types:				
		for log_entry in time_sorted_log:
			var other_dice = log_entry.get("other_dice")
			if other_dice._score_type == score_type and not log_entry.get("processed", false):
				score_type_filtered_log.append(log_entry)

	return score_type_filtered_log

func update_other_dice_log(dice: Dice, other_dice: Dice, timestamp: int):
	# Flag the corresponding entry in the other dice's log
	for other_entry in other_dice.collision_log:
		if other_entry.get("other_dice") == dice \
		and other_entry.get("timestamp") == timestamp \
		and not other_entry.get("processed", false):
			other_entry["processed"] = true
			break

func process_garlic_interaction(dice: Dice, garlic_dice: Dice):
	# Find all unprocessed collision log entries between these two dice
	var found_unprocessed := false
	for entry in garlic_dice.collision_log:
		if entry.get("other_dice") == dice:
			if not entry.get("processed", false) and not found_unprocessed:
				dice.total_multiplier *= garlic_dice.get_multiplier_value()
				update_multiplier_reported_score(dice, garlic_dice)
				found_unprocessed = true

			entry["processed"] = true

	for entry in dice.collision_log:
		if entry.get("other_dice") == garlic_dice:
			entry["processed"] = true

func get_multiplier_contribution(base_dice: Dice, multiplier_dice: Dice) -> float:
	return base_dice.get_base_score() * multiplier_dice.get_multiplier_value() - base_dice.get_base_score()

func update_flat_reported_score(base_dice: Dice, flat_dice: Dice):
	flat_dice.reported_score = flat_dice.get_flat_flat_value() * base_dice.get_base_quality_multiplier()

func update_multiplier_reported_score(base_dice: Dice, multiplier_dice: Dice):
	multiplier_dice.reported_score += get_multiplier_contribution(base_dice, multiplier_dice)
