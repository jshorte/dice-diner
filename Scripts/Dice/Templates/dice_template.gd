class_name DiceTemplate extends Resource

var definitions = load("res://Scripts/g_enum.gd")

@export var dice_name : String
@export var is_flat_preset: bool = false
@export var is_multiplier_preset: bool = false
@export var base_flat: int = 0
@export var base_multiplier: float = 1.0
@export var dice_type: G_ENUM.DiceType
@export var dice_score_type: G_ENUM.ScoreType
@export var prepared_values : Array[G_ENUM.FoodQuality] = [
    G_ENUM.FoodQuality.INEDIBLE, 
    G_ENUM.FoodQuality.POOR, 
    G_ENUM.FoodQuality.OK, 
    G_ENUM.FoodQuality.GOOD, 
    G_ENUM.FoodQuality.EXCELLENT
]
@export var dice_sprite_animation_path : String
@export var base_quality_multipliers: Dictionary[G_ENUM.FoodQuality, float] = {
    G_ENUM.FoodQuality.INEDIBLE: 0.0,
    G_ENUM.FoodQuality.POOR: 1.0,
    G_ENUM.FoodQuality.OK: 2.0,
    G_ENUM.FoodQuality.GOOD: 3.0,
    G_ENUM.FoodQuality.EXCELLENT: 4.0,
}
@export var multiplier_quality_multipliers: Dictionary[G_ENUM.FoodQuality, float] = {
    G_ENUM.FoodQuality.INEDIBLE: 0.0,
    G_ENUM.FoodQuality.POOR: 0.5,
    G_ENUM.FoodQuality.OK: 1.0,
    G_ENUM.FoodQuality.GOOD: 1.5,
    G_ENUM.FoodQuality.EXCELLENT: 2.0
}
@export var flat_quality_multipliers: Dictionary[G_ENUM.FoodQuality, float] = {
    G_ENUM.FoodQuality.INEDIBLE: 1.0,
    G_ENUM.FoodQuality.POOR: 1.0,
    G_ENUM.FoodQuality.OK: 1.0,
    G_ENUM.FoodQuality.GOOD: 1.0,
    G_ENUM.FoodQuality.EXCELLENT: 1.0
}
func calculate_score(dice: Dice) -> int:
    var _flat_value = dice._flat_value
    var _multiplier_value = dice._multiplier_value
    # var multiplier = quality_multipliers.get(dice._face_value, 1.0)
    return int((dice.base_score + dice.get_flat_value()) * dice.get_multiplier_value())
