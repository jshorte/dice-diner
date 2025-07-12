class_name DiceTemplate extends Resource

var definitions = load("res://Scripts/g_enum.gd")

@export var dice_name : String
@export var dice_type: G_ENUM.DiceType
@export var prepared_values : Array[G_ENUM.FoodQuality] = []
@export var dice_sprite_animation_path : String

func calculate_score(dice: Dice) -> int:
    # if dice.special_interactions.has("garlic"):
    #     var garlic = dice.special_interactions["garlic"]
        
    return dice._face_value
