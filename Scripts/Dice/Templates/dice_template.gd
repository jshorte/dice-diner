class_name DiceTemplate extends Resource

var definitions = load("res://Scripts/g_enum.gd")

@export var dice_name : String
@export var dice_type: G_ENUM.DiceType
@export var prepared_values : Array[G_ENUM.FoodQuality] = [
    G_ENUM.FoodQuality.INEDIBLE, 
    G_ENUM.FoodQuality.POOR, 
    G_ENUM.FoodQuality.OK, 
    G_ENUM.FoodQuality.GOOD, 
    G_ENUM.FoodQuality.EXCELLENT
]
@export var dice_sprite_animation_path : String
@export var quality_multipliers: Dictionary[G_ENUM.FoodQuality, float] = {
    G_ENUM.FoodQuality.INEDIBLE: 0.0,
    G_ENUM.FoodQuality.POOR: 0.5,
    G_ENUM.FoodQuality.OK: 1.0,
    G_ENUM.FoodQuality.GOOD: 1.5,
    G_ENUM.FoodQuality.EXCELLENT: 2.0
}

func calculate_score(dice: Dice) -> int:
    var base_score = dice.score + dice.bonus_score
    var multiplier = quality_multipliers.get(dice._face_value, 1.0)
    return int(base_score * multiplier + dice.flat_score)
