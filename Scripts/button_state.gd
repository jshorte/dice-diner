extends Button

var _phase_state: G_ENUM.PhaseState
var SCORE_PANEL_SHOWN_POS: Vector2
var SCORE_PANEL_HIDDEN_POS: Vector2

func _ready():
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	var score_panel = get_parent()
	SCORE_PANEL_SHOWN_POS = score_panel.position
	SCORE_PANEL_HIDDEN_POS = Vector2(score_panel.position.x + score_panel.size.x, score_panel.position.y)

func _on_score_button_toggled(toggled_on: bool) -> void:
	var score_panel = get_parent()
	var target_position = SCORE_PANEL_HIDDEN_POS if toggled_on else SCORE_PANEL_SHOWN_POS

	var tween = create_tween().bind_node(self)
	tween.tween_property(
		score_panel,
		"position",
		target_position,
		1
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	self.release_focus()

func _on_phase_state_changed(new_state: G_ENUM.PhaseState) -> void:
	_phase_state = new_state

	if _phase_state == G_ENUM.PhaseState.ROLL:
		_on_score_button_toggled(true)
		return

	if _phase_state == G_ENUM.PhaseState.SCORE:
		_on_score_button_toggled(false)
		return
