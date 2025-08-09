extends Node
class_name G_ENUM

enum DeckArea { DECK, NEXT, CURRENT, DISCARD }
enum DiceType { PIZZA, GARLIC, FLATWHITE, NEAPOLITAN, COOKIE }
enum ScoreType { BASE, FLAT, MULTIPLIER }
enum DiceSelection { DISABLED, ACTIVE, INACTIVE }
enum DiceState { MOVING, STATIONARY }
enum GameState { SELECT, PLAY, SCORE }
enum FoodQuality { INEDIBLE, POOR, OK, GOOD, EXCELLENT }
enum PhaseState { SETUP, PREPARE, ROLL, ROLLING, SCORE, DRAW }
enum Tastes { NONE, SWEET, SALTY, BITTER, SOUR, UMAMI }
enum Preparation { NONE, BAKED, FRIED, GRILLED, RAW }
enum Course { NONE, STARTER, MAIN, DESSERT }
static var COURSE_ICON_PATHS = {
    G_ENUM.Course.STARTER: "res://Art/Course/starter.aseprite",
    G_ENUM.Course.MAIN: "res://Art/Course/main.aseprite",
    G_ENUM.Course.DESSERT: "res://Art/Course/dessert.aseprite"
}
static var TASTE_ICON_PATHS = {
    G_ENUM.Tastes.SWEET: "res://Art/Tastes/sweet.aseprite",
    G_ENUM.Tastes.SALTY: "res://Art/Tastes/salty.aseprite",
    G_ENUM.Tastes.BITTER: "res://Art/Tastes/bitter.aseprite",
    G_ENUM.Tastes.SOUR: "res://Art/Tastes/sour.aseprite",
    G_ENUM.Tastes.UMAMI: "res://Art/Tastes/umami.aseprite"
}
static var PREPARATION_ICON_PATHS = {
    G_ENUM.Preparation.BAKED: "res://Art/Preparation/baked.aseprite",
    G_ENUM.Preparation.FRIED: "res://Art/Preparation/fried.aseprite",
    G_ENUM.Preparation.GRILLED: "res://Art/Preparation/grilled.aseprite",
    G_ENUM.Preparation.RAW: "res://Art/Preparation/grilled.aseprite"
}
