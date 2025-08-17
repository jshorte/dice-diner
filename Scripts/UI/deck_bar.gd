class_name DeckBar extends Control

var _sprite_to_dice : Dictionary = {}
var _dice_to_sprite : Dictionary = {}
var _selected_dice_rb: Dice = null
var _selected_dice_sprite: TextureRect = null
var _phase_state: G_ENUM.PhaseState = G_ENUM.PhaseState.SETUP
var _input_enabled: bool = true
var _deck_preview_locked: bool = false
var _discard_preview_locked: bool = false

@onready var _current_hbox: HBoxContainer = get_node("%CurrentHBox")
@onready var _next_hbox: HBoxContainer = get_node("%NextHBox")
@onready var _deck_hbox: HBoxContainer = get_node("%DeckHBox")
@onready var _discard_hbox: HBoxContainer = get_node("%DiscardHBox")
@onready var _current_dice_panel: PanelContainer = get_node("%CurrentDice")
@onready var _next_round_panel: PanelContainer = get_node("%NextRoundPanel")
@onready var next_round_button: Button = get_node("%NextRoundButton")
@onready var _play_area_boundary: Node = get_node("/root/main/PlayBoundary")
@onready var _setup_area_boundary: Node = get_node("/root/main/SetupBoundary")
var _play_area_panels: Array = []
var _setup_area_panels: Array = []

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
	SignalManager.score_updated.connect(_on_score_updated)
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

	for child in _play_area_boundary.get_children():
		if child is Panel:
			_play_area_panels.append(child)

	for child in _setup_area_boundary.get_children():
		if child is Panel:
			_setup_area_panels.append(child)

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
		if not _is_overlapping_other_dice(get_global_mouse_position()):
			if _phase_state == G_ENUM.PhaseState.SETUP:				
				if _is_over_setup_area(get_global_mouse_position()):
					_place_dice()
					_update_sprite_selection()
				elif _is_over_play_area(get_global_mouse_position()):
					print("Error: Cannot place dice in play area during setup phase")
				else:
					_update_sprite_selection()
				return

			if _is_over_play_area(get_global_mouse_position()):
				if _is_overlapping_other_dice(get_global_mouse_position()):
					print("Error: Cannot place dice over other dice in play area")
					return

				_place_dice()
			else:
				_update_sprite_selection()

			set_process(false)


func _place_dice():
	var dice_to_remove = _sprite_to_dice.get(_selected_dice_sprite, null)

	if dice_to_remove:
		_dice_to_sprite.erase(dice_to_remove)

	_sprite_to_dice.erase(_selected_dice_sprite)

	if is_instance_valid(_selected_dice_sprite):				
		_selected_dice_sprite.queue_free()

	SignalManager.dice_placed.emit(_selected_dice_rb, get_global_mouse_position())


func _is_overlapping_other_dice(pos: Vector2) -> bool:
	for dice in get_tree().get_nodes_in_group("dice"):
		if dice.has_node("Area2D"):
			var area = dice.get_node("Area2D")
			var shape_node = area.get_node("CollisionShape2D")
			if shape_node and shape_node.shape is CircleShape2D:
				var circle_shape = shape_node.shape
				var center = area.global_position
				var radius = circle_shape.radius
				if pos.distance_to(center) <= radius:
					return true
	return false

func _update_sprite_selection():
	remove_child(_selected_dice_sprite)
	_current_hbox.add_child(_selected_dice_sprite)				
	_selected_dice_sprite = null
	_selected_dice_rb = null


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

	var dice_preferences_scene = preload("res://Scenes/dice_preferences.tscn")
	var preferences_panel = dice_preferences_scene.instantiate()
	preferences_panel._dice = dice
	preferences_panel.visible = false
	preferences_panel.add_dice_icons()
	dice_sprite.add_child(preferences_panel)
	preferences_panel.position = Vector2(dice._dice_radius, dice._dice_radius) # Position above the sprite

	dice_sprite.gui_input.connect(_on_dice_sprite_input.bind(dice_sprite, dice, area))
	dice_sprite.mouse_entered.connect(_on_dice_sprite_mouse_entered.bind(dice_sprite, dice, preferences_panel))
	dice_sprite.mouse_exited.connect(_on_dice_sprite_mouse_exited.bind(dice_sprite, dice, preferences_panel))
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


func _on_dice_sprite_mouse_entered(sprite: TextureRect, dice: Dice, preferences_panel: Node) -> void:
	preferences_panel.visible = true
	# preferences_panel.position = Vector2(0, -sprite.size.y) # Adjust as needed
	# preferences_panel._dice = dice
	# preferences_panel.add_dice_icons()

func _on_dice_sprite_mouse_exited(sprite: TextureRect, dice: Dice, preferences_panel: Node) -> void:
	preferences_panel.visible = false


func _is_over_setup_area(pos: Vector2) -> bool:
	if _setup_area_boundary == null:
		print("Setup area boundary not initialized.")
		return false

	for panel in _setup_area_panels:
		if panel.get_global_rect().has_point(pos):
			return true
	return false

func _is_over_play_area(pos: Vector2) -> bool:
	if _play_area_panels == null:
		print("Play area panels not initialized.")
		return false

	for panel in _play_area_panels:
		if panel.get_global_rect().has_point(pos):
			return true
	return false


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
	_input_enabled = (new_state == G_ENUM.PhaseState.PREPARE or new_state == G_ENUM.PhaseState.SETUP)

	match new_state:
		G_ENUM.PhaseState.SETUP:
			for panel in _setup_area_panels:
				panel.visible = true
		_:
			for panel in _setup_area_panels:
				panel.visible = false

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


func _on_score_updated(_round_score: int, _total_score: int, _dice_scores: Array[Dice]):
	_next_round_panel.visible = true


func _on_next_round_button_pressed():
	_next_round_panel.visible = false
	SignalManager.score_completed.emit()
