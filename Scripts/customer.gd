class_name Customer extends Node2D

@export var customer_template: CustomerTemplate = null

var consumption_log: Array[Dictionary] = []
var _phase_state: G_ENUM.PhaseState

var _course_preferences: Array[G_ENUM.Course]
var _taste_preferences: Array[G_ENUM.Tastes]
var _preparation_preferences: Array[G_ENUM.Preparation]

var _course_map: Dictionary[G_ENUM.Course, float]
var _taste_map: Dictionary[G_ENUM.Tastes, float]
var _preparation_map: Dictionary[G_ENUM.Preparation, float]

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

func initialise_values_from_template() -> void:
	if not customer_template:
		push_error(false, "No template provided for customer initialisation.")
		return

	_course_preferences = customer_template.customer_course_preferences.duplicate()
	_taste_preferences = customer_template.customer_taste_preferences.duplicate()
	_preparation_preferences = customer_template.customer_preparation_preferences.duplicate()

	_course_map = customer_template.customer_preference_map.duplicate()
	_taste_map = customer_template.customer_taste_map.duplicate()
	_preparation_map = customer_template.customer_preparation_map.duplicate()
