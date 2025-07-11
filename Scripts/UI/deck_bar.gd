class_name Deck_Bar extends Control

var _sprite_to_dice : Dictionary = {}
var _dice_to_sprite : Dictionary = {}
var _selected_dice_rb: Dice = null
var _selected_dice_sprite: TextureRect = null
var _phase_state: G_ENUM.PhaseState = G_ENUM.PhaseState.PREPARE
var _input_enabled: bool = true
var _deck_preview_locked: bool = false
var _discard_preview_locked: bool = false

@onready var _current_hbox: HBoxContainer = get_node("%CurrentHBox")
@onready var _next_hbox: HBoxContainer = get_node("%NextHBox")
@onready var _deck_hbox: HBoxContainer = get_node("%DeckHBox")
@onready var _discard_hbox: HBoxContainer = get_node("%DiscardHBox")
@onready var _current_dice_panel: PanelContainer = get_node("%CurrentDice")
@onready var _play_area_panel: Panel = get_node("%PlayArea")

## Deck Panels
@onready var _deck_panel: PanelContainer = get_node("%Deck")
@onready var _deck_preview_panel: PanelContainer = get_node("%DeckPreview")

## Discard Panels
@onready var _discard_panel: PanelContainer = get_node("%Discard")
@onready var _discard_preview_panel: PanelContainer = get_node("%DiscardPreview")




func _ready():
	SignalManager.add_to_deck_panel.connect(_on_add_to_deck_panel)
	SignalManager.remove_from_deck_panel.connect(_on_remove_from_deck_panel)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	SignalManager.emit_ready.connect(_emit_ready)

	## Deck Panel Signals
	_deck_panel.mouse_entered.connect(_on_deck_mouse_entered)
	_deck_panel.mouse_exited.connect(_on_deck_mouse_exited)
	_deck_panel.gui_input.connect(_on_deck_panel_gui_input)
	_deck_preview_panel.visible = false

	## Discard Panel Signals
	_discard_panel.mouse_entered.connect(_on_discard_mouse_entered)
	_discard_panel.mouse_exited.connect(_on_discard_mouse_exited)
	_discard_panel.gui_input.connect(_on_discard_panel_gui_input)
	_discard_preview_panel.visible = false

func _emit_ready():
	SignalManager.hud_manager_ready.emit()

func _process(delta):
	if _selected_dice_sprite:
		_selected_dice_sprite.position = get_global_mouse_position() - _selected_dice_sprite.size / 2

func _input(event):
	if not _input_enabled:
		return

	if _selected_dice_sprite and \
		event is InputEventMouseButton and \
		event.pressed:
		if _is_over_play_area(get_global_mouse_position()):
			var dice_to_remove = _sprite_to_dice.get(_selected_dice_sprite, null)

			if dice_to_remove:
				_dice_to_sprite.erase(dice_to_remove)

			_sprite_to_dice.erase(_selected_dice_sprite)

			if is_instance_valid(_selected_dice_sprite):
				_selected_dice_sprite.queue_free()

			SignalManager.dice_placed.emit(_selected_dice_rb, get_global_mouse_position())
		elif _is_over_current_bar(get_global_mouse_position()):
			remove_child(_selected_dice_sprite)
			_current_hbox.add_child(_selected_dice_sprite)
		else:
			remove_child(_selected_dice_sprite)
			_current_hbox.add_child(_selected_dice_sprite)

		_selected_dice_sprite = null
		_selected_dice_rb = null
		set_process(false)


func _on_dice_sprite_input(event: InputEvent, sprite: TextureRect, dice: Dice, area: int) -> void:
	if not _input_enabled:
		return

	if area == G_ENUM.DeckArea.CURRENT and \
		event is InputEventMouseButton and \
		event.pressed:
		if dice and _dice_to_sprite.has(dice) and _sprite_to_dice.has(sprite):
			_selected_dice_rb = dice
			_selected_dice_sprite = sprite
			if sprite.get_parent() == _current_hbox:
				_current_hbox.remove_child(sprite)
				add_child(sprite)
			sprite.z_index = 100
			sprite.position = get_global_mouse_position() - sprite.size / 2
			set_process(true)
		else:
			_selected_dice_rb = null
			_selected_dice_sprite = null


func _on_add_to_deck_panel(area: int, dice: Dice) -> void:
	var dice_sprite = TextureRect.new()
	var sprite_frame = dice.get_sprite_frame()
	dice_sprite.texture = dice.get_icon_texture(sprite_frame)
	dice_sprite.mouse_filter = Control.MOUSE_FILTER_STOP
	dice_sprite.gui_input.connect(_on_dice_sprite_input.bind(dice_sprite, dice, area))
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


func _is_over_play_area(pos: Vector2) -> bool:
	return _play_area_panel.get_global_rect().has_point(pos)


func _is_over_current_bar(pos: Vector2) -> bool:
	return _current_dice_panel.get_global_rect().has_point(pos)


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
		_dice_to_sprite.erase(dice)
		_sprite_to_dice.erase(sprite)
		sprite.queue_free()

func _on_phase_state_changed(new_state: G_ENUM.PhaseState) -> void:
	_phase_state = new_state
	_input_enabled = (new_state == G_ENUM.PhaseState.PREPARE)

## DECK PANEL FUNCTIONS
func _on_deck_mouse_entered():
	_deck_preview_panel.visible = true


func _on_deck_mouse_exited():
	if not _deck_preview_locked:
		_deck_preview_panel.visible = false	


func _on_deck_panel_gui_input(event):
	if event is InputEventMouseButton and \
	event.pressed and \
	event.button_index == MOUSE_BUTTON_LEFT:
		_deck_preview_locked = not _deck_preview_locked
		_deck_preview_panel.visible = _deck_preview_locked

## DISCARD PANEL FUNCTIONS
func _on_discard_mouse_entered():
	_discard_preview_panel.visible = true	


func _on_discard_mouse_exited():
	if not _discard_preview_locked:
		_discard_preview_panel.visible = false


func _on_discard_panel_gui_input(event):
	if event is InputEventMouseButton and \
	event.pressed and \
	event.button_index == MOUSE_BUTTON_LEFT:
		_discard_preview_locked = not _discard_preview_locked
		_discard_preview_panel.visible = _discard_preview_locked
