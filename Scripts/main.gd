extends Node

var _isHUDReady: bool = false
var _isDeckReady: bool = false

func _ready():
	SignalManager.hud_manager_ready.connect(_on_hud_manager_ready)
	SignalManager.deck_manager_ready.connect(_on_deck_manager_ready)
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