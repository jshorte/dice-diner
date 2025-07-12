class_name DiceScoreLabel extends HBoxContainer

var dice: Dice

@onready var name_label: Label = get_node("%DiceNameLabel")
@onready var score_label: Label = get_node("%DiceScoreLabel")

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pass

func set_dice(d: Dice):
	dice = d
	set_dice_score(d)

func set_dice_score(d: Dice):
	name_label.text = d.dice_name
	score_label.text = str(d.calculated_score)

func reset_dice_score():
	if dice:
		name_label.text = ""
		score_label.text = ""

func _on_mouse_entered():
	if dice:
		print("Mouse entered dice: ", dice.dice_name)
		# dice.highlight(true)

func _on_mouse_exited():
	if dice:
		print("Mouse exited dice: ", dice.dice_name)
		# dice.highlight(false)
