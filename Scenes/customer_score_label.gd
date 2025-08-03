class_name CustomerScoreLabel extends HBoxContainer

var _customer: Customer

@onready var name_label: Label = get_node("%CustomerNameLabel")
@onready var score_label: Label = get_node("%CustomerScoreLabel")
# @onready var vfx: DiceVFX

func _ready() -> void:
	# mouse_entered.connect(_on_mouse_entered)
	# mouse_exited.connect(_on_mouse_exited)
	pass
	

func set_customer(c: Customer):
	_customer = c


func set_customer_score(c: Customer):
	name_label.text = "Customer: "  # TODO: Replace with actual customer name logic
	score_label.text = c.get_appetite_string()
		

# func set_dice_live_score(d: Dice):
# 	if d:
# 		name_label.text = d.get_dice_name()
# 		score_label.text = str(d.get_score())


# func _on_mouse_entered():
# 	if _dice:
# 		name_label.add_theme_color_override("font_color", Color.YELLOW)
# 		_dice.vfx.highlight(true)
# 		SignalManager.update_highlight_related_dice.emit(_dice, true)

# func _on_mouse_exited():
# 	if _dice:
# 		name_label.remove_theme_color_override("font_color")
# 		_dice.vfx.highlight(false)
# 		SignalManager.update_highlight_related_dice.emit(_dice, false)
