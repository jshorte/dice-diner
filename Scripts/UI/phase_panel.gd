class_name SetupPanel extends PanelContainer

var _phase_state: G_ENUM.PhaseState

@onready var _phase_label: Label = get_node("%PhaseLabel")
@onready var _phase_instruction_label: Label = get_node("%PhaseInstructionLabel")

func _ready():
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	_on_phase_state_changed(G_ENUM.PhaseState.SETUP)

func _on_phase_state_changed(new_phase: G_ENUM.PhaseState):
	print("SetupPanel: Phase changed to %s" % new_phase)
	_phase_state = new_phase

	match _phase_state:
		G_ENUM.PhaseState.SETUP:
			_phase_label.text = "Setup Phase"
			_phase_instruction_label.text = "Select food from the current area to place on a plate"
		G_ENUM.PhaseState.PREPARE:
			_phase_label.text = "Prepare Phase"
			_phase_instruction_label.text = "Select food from the current area to place on the table."
		G_ENUM.PhaseState.ROLL:
			_phase_label.text = "Roll Phase"
			_phase_instruction_label.text = "Launch your food!"
		G_ENUM.PhaseState.SCORE:
			_phase_label.text = "Score Phase"
			_phase_instruction_label.text = "Press \"Next Course\" to go to the next course."
