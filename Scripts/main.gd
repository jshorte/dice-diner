extends Node

var _isHUDReady: bool = false
var _isDeckReady: bool = false

func _ready():
	SignalManager.hud_manager_ready.connect(_on_hud_manager_ready)
	SignalManager.deck_manager_ready.connect(_on_deck_manager_ready)
	SignalManager.dice_placed.connect(_on_dice_placed)
	SignalManager.emit_ready.emit() # Tell children that the main node is ready

# Initialisation
func _on_hud_manager_ready():
	_isHUDReady = true
	_check_all_ready()

func _on_deck_manager_ready():
	_isDeckReady = true
	_check_all_ready()

func _check_all_ready():
	if _isHUDReady and _isDeckReady:
		SignalManager.request_deck_load.emit()

func _on_dice_placed(dice: Dice, position: Vector2):
	$Dice.add_child(dice)
	dice.call_deferred("set_dice_selection", G_ENUM.DiceSelection.ACTIVE)
	dice.call_deferred("set_dice_state", G_ENUM.DiceState.STATIONARY)
	print("Placing dice with template: ", dice.dice_template, " path: ", dice.dice_template.resource_path, " dice: ", dice)
	dice.position = position
