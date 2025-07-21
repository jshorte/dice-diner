class_name ScoreBar extends Node

var dice_score_label_scene: PackedScene = preload("res://Scenes/dice_score_label.tscn")

var dice_to_score: Array[Dice] = []
var dice_score_labels: Array[DiceScoreLabel] = []

@onready var round_score_text: Label = get_node("%RoundScoreText")
@onready var total_score_text: Label = get_node("%TotalScoreText")
@onready var dice_score_vbox: VBoxContainer = get_node("%DiceScoreVBox")
@onready var next_round_button: Button = get_node("%NextRoundButton")

func _ready() -> void:
	SignalManager.emit_ready.connect(_emit_ready)
	SignalManager.dice_placed.connect(_on_dice_placed)
	SignalManager.dice_launched.connect(_on_dice_launched)
	SignalManager.score_updated.connect(_on_score_updated)
	SignalManager.dice_score_updated.connect(_on_dice_score_updated)
	SignalManager.update_highlight_related_dice.connect(_on_highlight_related_dice)
	next_round_button.pressed.connect(_on_next_round_button_pressed)


func _emit_ready():
	SignalManager.score_bar_manager_ready.emit()


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
	for i in range(dice_score_labels.size()):
		var label = dice_score_labels[i]
		label.set_dice_score(dice_scores[i], false)
	
	round_score_text.text = "Round: %d" % round_score
	total_score_text.text = "Total: %d" % total_score
	next_round_button.visible = true
	next_round_button.disabled = false

func _on_highlight_related_dice(dice: Dice, highlight: bool):
	var dice_to_highlight_to = dice.contributions.keys()
	var dice_to_highlight_from = dice.contributions_from.keys()
	for contributing_dice in dice_to_highlight_to:
		for label in dice_score_labels:
			if label._dice == contributing_dice:
				if highlight:
					label.name_label.add_theme_color_override("font_color", Color.GREEN)
					contributing_dice.highlight_contributing(true)
				else:
					label.name_label.remove_theme_color_override("font_color")
					contributing_dice.highlight_contributing(false)

	for contributed_dice in dice_to_highlight_from:
		if contributed_dice.get_dice_type() == G_ENUM.DiceType.PIZZA:
			continue
			
		for label in dice_score_labels:
			if label._dice == contributed_dice:
				if highlight:
					label.name_label.add_theme_color_override("font_color", Color.BLUE)
					contributed_dice.highlight_contributed(true)
				else:
					label.name_label.remove_theme_color_override("font_color")
					contributed_dice.highlight_contributed(false)


# TODO: Put in bottom bar
func _on_next_round_button_pressed():
	for label in dice_score_labels:
		label.name_label.remove_theme_color_override("font_color")
	SignalManager.score_completed.emit()
	next_round_button.visible = false
	next_round_button.disabled = true
