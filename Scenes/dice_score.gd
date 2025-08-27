class_name DiceScore extends PanelContainer

var _dice: Dice

@onready var base_label: Label = get_node("%BaseLabel")
@onready var flat_label: Label = get_node("%FlatLabel")
@onready var quality_label: Label = get_node("%QualityLabel")
@onready var multiplier_label: Label = get_node("%MultiplierLabel")
@onready var course_label: Label = get_node("%CourseLabel")
@onready var applied_label: Label = get_node("%AppliedLabel")
@onready var stored_label: Label = get_node("%StoredLabel")
@onready var total_label: Label = get_node("%TotalLabel")
@onready var vbox: VBoxContainer = get_node("%DiceDataVBox")

const ABOVE_OFFSET: float = 50
const BELOW_OFFSET: float = 50

var _current_phase: G_ENUM.PhaseState = G_ENUM.PhaseState.PREPARE

func _ready():
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	

func _process(delta: float) -> void:
	update_score_position()	


func update_score_display() -> void:
	update_score_labels()


func update_score_position() -> void:
	var screen_rect = get_viewport_rect().size
	var group_size = vbox.size
	var parent = vbox.get_parent()

	parent.global_position = Vector2(
		(screen_rect.x - group_size.x) / 2,
		screen_rect.y * 0.75 - group_size.y
	)

func update_score_labels():
	if _dice and _dice.strategy:
		var breakdown = _dice.strategy.get_score_breakdown(_dice)

		if _current_phase != G_ENUM.PhaseState.SCORE:
			stored_label.visible = breakdown.has("stored")
			if breakdown.has("stored"):
				stored_label.text = "Stored: %d" % breakdown["stored"]

			base_label.visible = false
			flat_label.visible = false
			quality_label.visible = false
			multiplier_label.visible = false
			applied_label.visible = false
			course_label.visible = false
			total_label.visible = false
			return

		var label_map: Dictionary = {
			"base": [base_label, "Base: %s"],
			"flat": [flat_label, "Flat Value: +%d"],
			"quality": [quality_label, "Quality: x%d"],
			"multiplier": [multiplier_label, "Multiplier: x%d"],
			"applied": [applied_label, "%s"],
			"course": [course_label, "%s"],
			"stored": [stored_label, "Stored: %d"],
		}

		for key in label_map.keys():
			var label = label_map[key][0]
			var formattedText = label_map[key][1]
			if breakdown.has(key):
				label.visible = true
				label.text = formattedText % breakdown[key]
			else:
				label.visible = false

		total_label.visible = true
		total_label.text = "Total: %s" % breakdown["total"]


func _on_phase_state_changed(new_state: G_ENUM.PhaseState) -> void:
	_current_phase = new_state
