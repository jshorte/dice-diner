extends Node

var _dice_scene = preload("res://Scenes/dice.tscn")
var _pizza_dice_template_path = "res://Resources/Dice_types/pizza_dice.tres"
var _garlic_dice_template_path = "res://Resources/Dice_types/garlic_dice.tres"

var _deck : Array = []
var _next : Array = []
var _current : Array = []
var _discard : Array = []
var _draw_amount : int = 3

var _player_inventory : Array = [
	G_ENUM.DiceType.PIZZA, 
	G_ENUM.DiceType.PIZZA, 
	G_ENUM.DiceType.PIZZA, 
	G_ENUM.DiceType.PIZZA,
	G_ENUM.DiceType.PIZZA, 
	G_ENUM.DiceType.GARLIC,
	G_ENUM.DiceType.GARLIC,
]

@onready var _pending_dice_node = get_node("%PendingDice")


func _ready():
	SignalManager.request_deck_load.connect(_on_load_deck)
	SignalManager.request_deck_draw.connect(_on_request_deck_draw)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	SignalManager.remove_placed_dice.connect(_remove_from_current)
	SignalManager.emit_ready.connect(_emit_ready)


func _emit_ready():
	SignalManager.deck_manager_ready.emit()


func _on_phase_state_changed(new_state: G_ENUM.PhaseState):
	if new_state == G_ENUM.PhaseState.DRAW:
		_transfer_current_to_discard()
		_transfer_next_to_current()
		_transfer_draw_to_next()
		SignalManager.draw_completed.emit()


func _transfer_draw_to_next():
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
	for i in _next.size():
		var dice = _next.pop_front()
		SignalManager.remove_from_deck_panel.emit(G_ENUM.DeckArea.NEXT, dice)
		_current.append(dice)
		SignalManager.add_to_deck_panel.emit(G_ENUM.DeckArea.CURRENT, dice)


func _transfer_current_to_discard():
	for dice in _current:
		SignalManager.remove_from_deck_panel.emit(G_ENUM.DeckArea.CURRENT, dice)
		_discard.append(dice)
		SignalManager.add_to_deck_panel.emit(G_ENUM.DeckArea.DISCARD, dice)
	_current.clear()


func _reshuffle_discard_into_deck():
	for dice in _deck:
		_discard.append(dice)
		SignalManager.remove_from_deck_panel.emit(G_ENUM.DeckArea.DECK, dice)
		SignalManager.add_to_deck_panel.emit(G_ENUM.DeckArea.DISCARD, dice)
	_deck.clear()

	for dice in _discard:
		SignalManager.remove_from_deck_panel.emit(G_ENUM.DeckArea.DISCARD, dice)
		SignalManager.add_to_deck_panel.emit(G_ENUM.DeckArea.DECK, dice)
	_deck = _discard.duplicate()
	_discard.clear()
	_deck.shuffle()

	for dice in _deck:
		dice.roll_face()


func _remove_from_current(dice: Dice):
	if dice in _current:
		_current.erase(dice)


func _on_load_deck():
	_deck.clear()
	_next.clear()
	_current.clear()
	_discard.clear()

	for type in _player_inventory:
		var blank_dice: Dice = _dice_scene.instantiate()
		blank_dice.sleeping = true
		blank_dice.contact_monitor = false
		_pending_dice_node.add_child(blank_dice)
		match type:
			G_ENUM.DiceType.PIZZA:
				blank_dice.dice_template = load(_pizza_dice_template_path)
				blank_dice.strategy = PizzaDiceScoringStrategy.new()
			G_ENUM.DiceType.GARLIC:
				blank_dice.dice_template = load(_garlic_dice_template_path)
				blank_dice.strategy = GarlicDiceScoringStrategy.new()
		blank_dice.initialise_values_from_template()  # Ensure the dice is initialized with its template
		_deck.append(blank_dice)
		SignalManager.add_to_deck_panel.emit(G_ENUM.DeckArea.DECK, blank_dice)
	# TODO: Dice which have face values need to have new random values assigned when going into discard/draw pile
	_deck.shuffle()
	_on_request_deck_draw()


func _on_request_deck_draw():
	_transfer_draw_to_next()
	_transfer_next_to_current()
	_transfer_draw_to_next()
