class_name Customer extends Node2D

var consumption_log: Array[Dictionary] = []
var _phase_state: G_ENUM.PhaseState

@onready var _area: Area2D = $Area2D

func _ready():
	_area.body_entered.connect(_on_body_entered)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)

func _on_body_entered(body: Node) -> void:
	if body is Dice:
		print("Dice entered customer area: ", body)
		add_consumption_log_entry(body)


func _on_phase_state_changed(new_state: G_ENUM.PhaseState) -> void:
	print("Phase state changed: ", new_state)
	_phase_state = new_state

	match _phase_state:
		G_ENUM.PhaseState.PREPARE:
			# Handle prepare phase logic if needed
			pass
		G_ENUM.PhaseState.SCORE:           
			for entry in consumption_log:
				print("Consumed ", entry["dice"].get_dice_name(), " worth ", entry["dice"].strategy.get_calculated_score(entry["dice"]))
		G_ENUM.PhaseState.PREPARE:
			consumption_log.clear()

func add_consumption_log_entry(dice: Dice) -> void:
	if dice:
		consumption_log.append({
			"dice": dice,
			"timestamp": Time.get_ticks_msec()
		})
