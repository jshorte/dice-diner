class_name DiceScore extends PanelContainer

var _dice: Dice

@onready var base_label: Label = get_node("%BaseLabel")
@onready var flat_label: Label = get_node("%FlatLabel")
@onready var quality_label: Label = get_node("%QualityLabel")
@onready var multiplier_label: Label = get_node("%MultiplierLabel")
@onready var course_label: Label = get_node("%CourseLabel")
@onready var applied_label: Label = get_node("%AppliedLabel")
@onready var total_label: Label = get_node("%TotalLabel")
@onready var vbox: VBoxContainer = get_node("%DiceBreakdownVBox")

const ABOVE_OFFSET: float = 50
const BELOW_OFFSET: float = 50

var _current_phase: G_ENUM.PhaseState = G_ENUM.PhaseState.PREPARE

func _ready():
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	

func _process(delta: float) -> void:
	if _current_phase == G_ENUM.PhaseState.SCORE:
		update_score_position()


func update_score_display() -> void:
	if _current_phase == G_ENUM.PhaseState.SCORE:
		update_score_labels()


func update_score_position() -> void:
	var screen_rect = get_viewport_rect().size
	var panel_size = size
	# Center the panel in the viewport
	global_position = Vector2(
		(screen_rect.x - panel_size.x) / 2,
		screen_rect.y * 0.75 - panel_size.y
	)

func update_score_labels():
	if _dice and _dice.strategy:        
		var breakdown = _dice.strategy.get_score_breakdown(_dice)

		var label_map: Dictionary = {
			"base": [base_label, "Base: %s"],
			"flat": [flat_label, "Flat Value: +%d"],
			"quality": [quality_label, "Quality: x%d"],
			"multiplier": [multiplier_label, "Multiplier: x%d"],
			"applied": [applied_label, "%s"],
			"course": [course_label, "%s"],
		}

		for key in label_map.keys():
			var label = label_map[key][0]
			var formattedText = label_map[key][1]
			if breakdown.has(key):
				label.visible = true
				label.text = formattedText % breakdown[key]
			else:
				label.visible = false

		total_label.text = "Total: %d" % breakdown["total"]

		size.x = 0
		size.y = 0
		vbox.queue_sort()


func _on_phase_state_changed(new_state: G_ENUM.PhaseState) -> void:
	_current_phase = new_state
