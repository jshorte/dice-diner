class_name DiceTemplate extends Resource

var definitions = load("res://Scripts/g_enum.gd")

@export var dice_name : String
@export var is_flat_preset: bool = false
@export var is_multiplier_preset: bool = false
@export var base_flat: int = 0
@export var base_multiplier: float = 1.0
@export var dice_type: G_ENUM.DiceType
@export var dice_score_type: G_ENUM.ScoreType
@export var dice_taste: Array[G_ENUM.Tastes]
@export var dice_preparation: Array[G_ENUM.Preparation]
@export var dice_course: Array[G_ENUM.Course]
@export var prepared_values : Array[G_ENUM.FoodQuality] = [
    G_ENUM.FoodQuality.INEDIBLE, 
    G_ENUM.FoodQuality.POOR, 
    G_ENUM.FoodQuality.OK, 
    G_ENUM.FoodQuality.GOOD, 
    G_ENUM.FoodQuality.EXCELLENT
]
@export var dice_sprite_animation_path : String
@export var score_map: Dictionary[G_ENUM.FoodQuality, float] = {
    G_ENUM.FoodQuality.INEDIBLE: 0.0,
    G_ENUM.FoodQuality.POOR: 1.0,
    G_ENUM.FoodQuality.OK: 2.0,
    G_ENUM.FoodQuality.GOOD: 3.0,
    G_ENUM.FoodQuality.EXCELLENT: 4.0,
}
@export var multiplier_map: Dictionary[G_ENUM.FoodQuality, float] = {
    G_ENUM.FoodQuality.INEDIBLE: 0.0,
    G_ENUM.FoodQuality.POOR: 0.5,
    G_ENUM.FoodQuality.OK: 1.0,
    G_ENUM.FoodQuality.GOOD: 1.5,
    G_ENUM.FoodQuality.EXCELLENT: 2.0
}
@export var flat_map: Dictionary[G_ENUM.FoodQuality, float] = {
    G_ENUM.FoodQuality.INEDIBLE: 1.0,
    G_ENUM.FoodQuality.POOR: 1.0,
    G_ENUM.FoodQuality.OK: 1.0,
    G_ENUM.FoodQuality.GOOD: 1.0,
    G_ENUM.FoodQuality.EXCELLENT: 1.0
}
