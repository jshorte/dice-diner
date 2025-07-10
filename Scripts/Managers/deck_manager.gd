extends Node

var _dice_scene = preload("res://Scenes/dice.tscn")
var _pizza_dice_template_path = "res://Resources/Dice_types/pizza_dice.tres"
var _garlic_dice_template_path = "res://Resources/Dice_types/garlic_dice.tres"

var _deck : Array = []
var _next : Array = []
var _current : Array = []
var _discard : Array = []
var _draw_amount : int = 5
var _transfer_amount : int = 2
var _player_inventory : Array = [
	G_ENUM.DiceType.PIZZA, 
	G_ENUM.DiceType.PIZZA, 
	G_ENUM.DiceType.PIZZA, 
	G_ENUM.DiceType.PIZZA, 
	G_ENUM.DiceType.GARLIC, 
	G_ENUM.DiceType.GARLIC,
	G_ENUM.DiceType.GARLIC,
]

func _ready():
	SignalManager.request_deck_load.connect(_on_load_deck)
	SignalManager.request_deck_draw.connect(_on_request_deck_draw)
	SignalManager.emit_ready.connect(_emit_ready)


func _emit_ready():
	SignalManager.deck_manager_ready.emit()


func _draw_to_next():
	if _deck.size() < _draw_amount and _discard.size() > 0:
		_reshuffle_discard_into_deck()
	var drawn = []
	for i in min(_draw_amount, _deck.size()):
		var dice = _deck.pop_back()
		SignalManager.remove_from_deck_panel.emit(G_ENUM.DeckArea.DECK, dice)
		_next.append(dice)
		drawn.append(dice)
		SignalManager.add_to_deck_panel.emit(G_ENUM.DeckArea.NEXT, dice)
	return drawn


func _transfer_next_to_current():
	for i in min(_transfer_amount, _next.size()):
		var dice = _next.pop_front()
		SignalManager.remove_from_deck_panel.emit(G_ENUM.DeckArea.NEXT, dice)
		_current.append(dice)
		SignalManager.add_to_deck_panel.emit(G_ENUM.DeckArea.CURRENT, dice)


func _reshuffle_discard_into_deck():
	_deck = _discard.duplicate()
	_discard.clear()
	_deck.shuffle()


func _on_load_deck():
	_deck.clear()
	_next.clear()
	_current.clear()
	_discard.clear()

	for type in _player_inventory:
		var blank_dice = _dice_scene.instantiate()
		match type:
			G_ENUM.DiceType.PIZZA:
				blank_dice.dice_template = load(_pizza_dice_template_path)
			G_ENUM.DiceType.GARLIC:
				blank_dice.dice_template = load(_garlic_dice_template_path)
		blank_dice.initialise_values_from_template()  # Ensure the dice is initialized with its template
		_deck.append(blank_dice)
		SignalManager.add_to_deck_panel.emit(G_ENUM.DeckArea.DECK, blank_dice)
	# TODO: Dice which have face values need to have new random values assigned when going into discard/draw pile
	_deck.shuffle()
	_on_request_deck_draw()


func _on_request_deck_draw():
	_draw_to_next()
	_transfer_next_to_current()
