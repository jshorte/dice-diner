class_name Deck_Bar extends Control

var _sprite_to_dice : Dictionary = {}
var _dice_to_sprite : Dictionary = {}

@onready var _current_hbox: HBoxContainer = get_node("%CurrentHBox")
@onready var _next_hbox: HBoxContainer = get_node("%NextHBox")
@onready var _deck_hbox: HBoxContainer = get_node("%DeckHBox")
@onready var _discard_hbox: HBoxContainer = get_node("%DiscardHBox")

func _ready():
	SignalManager.add_to_deck_panel.connect(_on_add_to_deck_panel)
	SignalManager.remove_from_deck_panel.connect(_on_remove_from_deck_panel)
	SignalManager.emit_ready.connect(_emit_ready)

func _emit_ready():
	SignalManager.hud_manager_ready.emit()

func _on_add_to_deck_panel(area: int, dice: Dice) -> void:
	var dice_sprite = TextureRect.new()
	dice_sprite.texture = dice.get_icon_texture()
	match area:
		G_ENUM.DeckArea.CURRENT:
			_current_hbox.add_child(dice_sprite)
		G_ENUM.DeckArea.NEXT:
			_next_hbox.add_child(dice_sprite)
		G_ENUM.DeckArea.DECK:
			_deck_hbox.add_child(dice_sprite)
		G_ENUM.DeckArea.DISCARD:
			_discard_hbox.add_child(dice_sprite)
	_sprite_to_dice[dice_sprite] = dice
	_dice_to_sprite[dice] = dice_sprite
	print("Added dice to area: ", area, " dice: ", dice, " icon: ", dice_sprite)

func _on_remove_from_deck_panel(area: int, dice: Dice) -> void:
	if _dice_to_sprite.has(dice):
		var sprite = _dice_to_sprite[dice]
		match area:
			G_ENUM.DeckArea.CURRENT:
				_current_hbox.remove_child(sprite)
			G_ENUM.DeckArea.NEXT:
				_next_hbox.remove_child(sprite)
			G_ENUM.DeckArea.DECK:
				_deck_hbox.remove_child(sprite)
			G_ENUM.DeckArea.DISCARD:
				_discard_hbox.remove_child(sprite)
		sprite.queue_free()
		_dice_to_sprite.erase(dice)
		_sprite_to_dice.erase(sprite)
