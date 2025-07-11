class_name DiceTemplate extends Resource

var definitions = load("res://Scripts/g_enum.gd")

@export var dice_min : int
@export var dice_max : int
@export var dice_interval : int 
@export var dice_sprite_animation_path : String
@export var dice_type: G_ENUM.DiceType
@export var dice_name : String

func calculate_score(dice: Dice) -> int:
    if dice.special_interactions.has("garlic"):
        var garlic = dice.special_interactions["garlic"]
        
    return dice._face_value
