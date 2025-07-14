class_name ScoreBar extends Node

var dice_score_label_scene: PackedScene = preload("res://Scenes/dice_score_label.tscn")

var dice_to_score: Array[Dice] = []
var dice_score_labels: Array[DiceScoreLabel] = []

@onready var round_score_text: Label = get_node("%RoundScoreText")
@onready var total_score_text: Label = get_node("%TotalScoreText")
@onready var dice_score_vbox: VBoxContainer = get_node("%DiceScoreVBox")

func _ready() -> void:
	SignalManager.emit_ready.connect(_emit_ready)
	SignalManager.dice_placed.connect(_on_dice_placed)
	SignalManager.dice_launched.connect(_on_dice_launched)
	SignalManager.score_updated.connect(_on_score_updated)
	SignalManager.dice_score_updated.connect(_on_dice_score_updated)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)


func _emit_ready():
	SignalManager.score_bar_manager_ready.emit()


func _on_phase_state_changed(new_state: G_ENUM.PhaseState):
	if new_state == G_ENUM.PhaseState.ROLL:
		print("Resetting score display for new round")
		_reset_score_display()


func _on_dice_placed(dice: Dice, position: Vector2):
	dice_to_score.append(dice)
	var label = dice_score_label_scene.instantiate()
	dice_score_vbox.add_child(label)
	dice_score_labels.append(label)
	label.set_dice(dice)

	for i in range(dice_to_score.size()):
		var l = dice_score_labels[i]
		l.set_dice_score(dice_to_score[i], true)
		l.visible = true

func _on_dice_launched():
	for label in dice_score_labels:
		label.visible = true
	

func _on_dice_score_updated(dice: Dice, score: int):
	for label in dice_score_labels:
		if label._dice == dice:
			label.set_dice_live_score(dice)


func _on_score_updated(round_score: int, total_score: int, dice_scores: Array[Dice]):
	print("Size Compare (Labels vs Scores): ", dice_score_labels.size(), " vs ", dice_scores.size())
	for i in range(dice_score_labels.size()):
		var label = dice_score_labels[i]
		label.set_dice_score(dice_scores[i], false)
	
	round_score_text.text = "Round: %d" % round_score
	total_score_text.text = "Total: %d" % total_score


func _reset_score_display():
	return
	# round_score_text.visible = false
	# for label in dice_score_labels:
	# 	label.visible = false
