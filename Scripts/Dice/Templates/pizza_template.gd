class_name PizzaTemplate extends DiceTemplate

func calculate_score(dice: Dice) -> int:
	return dice._face_value + dice.bonus_score
