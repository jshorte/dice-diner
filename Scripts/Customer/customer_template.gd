class_name CustomerTemplate extends Resource

var definitions = load("res://Scripts/g_enum.gd")

@export var customer_course_preferences: Array[G_ENUM.Course] = []
@export var customer_taste_preferences: Array[G_ENUM.Tastes] = []
@export var customer_preparation_preferences: Array[G_ENUM.Preparation] = []

@export var customer_preference_map: Dictionary[G_ENUM.Course, float] = {
    G_ENUM.Course.STARTER: 1.0,
    G_ENUM.Course.MAIN: 1.0,
    G_ENUM.Course.DESSERT: 1.0
}

@export var customer_taste_map: Dictionary[G_ENUM.Tastes, float] = {
    G_ENUM.Tastes.SWEET: 1.0,
    G_ENUM.Tastes.SALTY: 1.0,
    G_ENUM.Tastes.BITTER: 1.0,
    G_ENUM.Tastes.SOUR: 1.0,
    G_ENUM.Tastes.UMAMI: 1.0
}

@export var customer_preparation_map: Dictionary[G_ENUM.Preparation, float] = {
    G_ENUM.Preparation.BAKED: 1.0,
    G_ENUM.Preparation.FRIED: 1.0,
    G_ENUM.Preparation.GRILLED: 1.0,
    G_ENUM.Preparation.RAW: 1.0
}