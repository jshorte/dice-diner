class_name CustomerScoreLabel extends HBoxContainer

var _customer: Customer

@onready var name_label: Label = get_node("%CustomerNameLabel")
@onready var score_label: Label = get_node("%CustomerScoreLabel")
@onready var course_list_label: Label = get_node("%CoursePreferenceListLabel")
@onready var taste_list_label: Label = get_node("%TastePreferenceListLabel")
@onready var preparation_list_label: Label = get_node("%PreparationPreferenceListLabel")
# @onready var vfx: DiceVFX

func _ready() -> void:
	# mouse_entered.connect(_on_mouse_entered)
	# mouse_exited.connect(_on_mouse_exited)
	pass
	

func set_customer(c: Customer):
	_customer = c


func set_customer_score(c: Customer):
	# name_label.text = "Customer: "
	score_label.text = "Customer: " + c.get_appetite_string()

	_set_course_label(c)
	_set_taste_label(c)
	_set_preparation_label(c)


func update_customer_score():
	if _customer:
		score_label.text = "Customer: " + _customer.get_appetite_string()


func _set_course_label(c: Customer):
	if c._course_preferences.size() == 0 or (
		c._course_preferences.size() == 1 and 
		c._course_preferences[0] == G_ENUM.Course.NONE
		):
		course_list_label.get_parent().hide()
	else:
		var course_text = ""
		for course in c._course_preferences:
			if course == G_ENUM.Course.NONE:
				continue
			var course_key = G_ENUM.Course.keys()[course]
			var course_name = str(course_key).capitalize()
			var course_multiplier = c._course_map[course] if c._course_map.has(course) else 1.0
			course_text += "%s x%s, " % [course_name, str(course_multiplier)]
		course_text = course_text.trim_suffix(", ")
		course_list_label.text = "Courses: %s" % course_text
		course_list_label.get_parent().show()

func _set_taste_label(c: Customer):
	if c._taste_preferences.size() == 0 or (
		c._taste_preferences.size() == 1 and 
		c._taste_preferences[0] == G_ENUM.Tastes.NONE
		):
		taste_list_label.get_parent().hide()
	else:
		var taste_text = ""
		for taste in c._taste_preferences:
			if taste == G_ENUM.Tastes.NONE:
				continue
			var taste_key = G_ENUM.Tastes.keys()[taste]
			var taste_name = str(taste_key).capitalize()
			var taste_multiplier = c._taste_map[taste] if c._taste_map.has(taste) else 1.0
			taste_text += "%s x%s, " % [taste_name, str(taste_multiplier)]
		taste_text = taste_text.trim_suffix(", ")
		taste_list_label.text = "Tastes: %s" % taste_text
		taste_list_label.get_parent().show()

func _set_preparation_label(c: Customer):
	if c._preparation_preferences.size() == 0 or (
		c._preparation_preferences.size() == 1 and 
		c._preparation_preferences[0] == G_ENUM.Preparation.NONE
		):
		preparation_list_label.get_parent().hide()
	else:
		var prep_text = ""
		for prep in c._preparation_preferences:
			if prep == G_ENUM.Preparation.NONE:
				continue
			var prep_key = G_ENUM.Preparation.keys()[prep]
			var prep_name = str(prep_key).capitalize()
			var prep_multiplier = c._preparation_map[prep] if c._preparation_map.has(prep) else 1.0
			prep_text += "%s x%s, " % [prep_name, str(prep_multiplier)]
		prep_text = prep_text.trim_suffix(", ")
		preparation_list_label.text = "Preparation: %s" % prep_text
		preparation_list_label.get_parent().show()

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
