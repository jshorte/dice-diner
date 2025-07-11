class_name GarlicTemplate extends DiceTemplate

func calculate_score(dice: Dice) -> int:
    if dice.first_collision_dice:
        var other = dice.first_collision_dice
        return (other._face_value + other.bonus_score) * dice._face_value
    return 0