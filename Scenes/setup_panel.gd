class_name SetupPanel extends PanelContainer

var _phase_state: G_ENUM.PhaseState

func _ready():
    SignalManager.phase_state_changed.connect(_on_phase_state_changed)
    _on_phase_state_changed(G_ENUM.PhaseState.SETUP)

func _on_phase_state_changed(new_phase: G_ENUM.PhaseState):
    print("SetupPanel: Phase changed to %s" % new_phase)
    _phase_state = new_phase

    match _phase_state:
        G_ENUM.PhaseState.SETUP:
            visible = true
        G_ENUM.PhaseState.PREPARE:
            visible = false
        _:
            visible = false
