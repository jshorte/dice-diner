class_name DiceScoreLabel extends HBoxContainer

var _dice: Dice

@onready var name_label: Label = get_node("%DiceNameLabel")
@onready var score_label: Label = get_node("%DiceScoreLabel")
@onready var quality_label: Label = get_node("%DiceQualityLabel")

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pass
	

func set_dice(d: Dice):
	_dice = d


func set_dice_score(d: Dice, initial: bool = false):
	name_label.text = d.dice_name
	print("Setting score for dice: ", d.dice_name, " Score: ", d.reported_score)
	score_label.text = str(d.reported_score)
	# quality_label.text = ""
	quality_label.visible = false

	if not initial:
		quality_label.visible = true
		var quality_text := d.get_food_quality()
		var value_text := ""

		match d._score_type:
			G_ENUM.ScoreType.BASE:
				value_text = "(x" + str(d.get_base_quality_multiplier()) + ")"
			G_ENUM.ScoreType.MULTIPLIER:
				value_text = "(x" + str(d.get_multiplier_value()) + ")"
			G_ENUM.ScoreType.FLAT:
				value_text =  "(+" + str(d.get_flat_value()) + ")"
			_:
				value_text = ""

		quality_label.text = quality_text + " " + value_text

		var face_color = Color.BLACK

		match d._face_value:
			G_ENUM.FoodQuality.INEDIBLE:
				face_color = Color.BLACK
			G_ENUM.FoodQuality.POOR:
				face_color = Color.RED
			G_ENUM.FoodQuality.OK:
				face_color = Color("FFA500") # Amber (orange)
			G_ENUM.FoodQuality.GOOD:
				face_color = Color.GREEN
			G_ENUM.FoodQuality.EXCELLENT:
				face_color = Color.CYAN

		quality_label.add_theme_color_override("font_color", face_color)

		

func set_dice_live_score(d: Dice):
	if d:
		name_label.text = d.dice_name
		score_label.text = str(d.score)


func _on_mouse_entered():
	if _dice:
		name_label.add_theme_color_override("font_color", Color.YELLOW)
		_dice.highlight(true)


func _on_mouse_exited():
	if _dice:
		name_label.remove_theme_color_override("font_color")
		_dice.highlight(false)
