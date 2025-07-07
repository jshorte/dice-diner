extends Node

var _dice_scene = preload("res://Scenes/dice.tscn")
var _pizza_dice_template_path = "res://Resources/Dice_types/pizza_dice.tres"
var _garlic_dice_template_path = "res://Resources/Dice_types/garlic_dice.tres"

var _player_inventory := [G_ENUM.DiceType.PIZZA, G_ENUM.DiceType.GARLIC, G_ENUM.DiceType.PIZZA]

func _ready():
	SignalManager.request_deck_load.connect(_on_request_deck_load)
	SignalManager.emit_ready.connect(_emit_ready)

func _emit_ready():
	SignalManager.deck_manager_ready.emit()

func _load_player_dice(dice_type_array):
	var _dice_to_display = []
	var uid = 1
	for type in dice_type_array:
		var _blank_dice = _dice_scene.instantiate()
		match type:
			G_ENUM.DiceType.PIZZA:
				_blank_dice.dice_template = load(_pizza_dice_template_path)
			G_ENUM.DiceType.GARLIC:
				_blank_dice.dice_template = load(_garlic_dice_template_path)
		_blank_dice.unique_id = uid
		uid += 1
		_dice_to_display.append(_blank_dice)
		print("Dice to display: ", _dice_to_display)
		if _dice_to_display.size() == 2:
			break
	for dice in _dice_to_display:
		SignalManager.add_to_playable_panel.emit(dice)

func _on_request_deck_load():
	print("Deck load requested, loading player dice")
	_load_player_dice(_player_inventory)
