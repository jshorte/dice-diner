class_name Customer extends Node2D

@export var customer_template: CustomerTemplate = null

var consumption_log: Array[Dictionary] = []
var _phase_state: G_ENUM.PhaseState

var _appetite: int
var _course_preferences: Array[G_ENUM.Course]
var _taste_preferences: Array[G_ENUM.Tastes]
var _preparation_preferences: Array[G_ENUM.Preparation]

var _course_map: Dictionary[G_ENUM.Course, float]
var _taste_map: Dictionary[G_ENUM.Tastes, float]
var _preparation_map: Dictionary[G_ENUM.Preparation, float]

@onready var _area: Area2D = $Area2D
@onready var _appetite_label: Label = get_node("%AppetiteLabel")

@onready var _customer_hbox = get_node("%CustomerHBox")
@onready var _customer_icons_hbox = get_node("%CustomerIconsHBox")

func _ready():
	_area.body_entered.connect(_on_body_entered)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	SignalManager.reset_score.connect(_reset_values)
	update_appetite_label()
	_add_icons()
	_customer_hbox.visible = true


func _on_body_entered(body: Node) -> void:
	if body is Dice:
		print("Dice entered customer area: ", body)
		add_consumption_log_entry(body)


func _on_phase_state_changed(new_state: G_ENUM.PhaseState) -> void:
	print("Phase state changed: ", new_state)
	_phase_state = new_state

	match _phase_state:
		G_ENUM.PhaseState.PREPARE:
			# Handle prepare phase logic if needed
			pass
		G_ENUM.PhaseState.SCORE:           
			for entry in consumption_log:
				print("Consumed ", entry["dice"].get_dice_name(), " worth ", entry["dice"].strategy.get_calculated_score(entry["dice"]))
		G_ENUM.PhaseState.PREPARE:
			consumption_log.clear()


func add_consumption_log_entry(dice: Dice) -> void:
	if dice:
		consumption_log.append({
			"dice": dice,
			"timestamp": Time.get_ticks_msec()
		})


func initialise_values_from_template() -> void:
	if not customer_template:
		push_error(false, "No template provided for customer initialisation.")
		return

	_appetite = customer_template.customer_appetite
	
	_course_preferences = customer_template.customer_course_preferences.duplicate()
	_taste_preferences = customer_template.customer_taste_preferences.duplicate()
	_preparation_preferences = customer_template.customer_preparation_preferences.duplicate()

	_course_map = customer_template.customer_preference_map.duplicate()
	_taste_map = customer_template.customer_taste_map.duplicate()
	_preparation_map = customer_template.customer_preparation_map.duplicate()


func update_appetite_label() -> void:
	if not _appetite_label:
		push_error(false, "Appetite label not found.")
		return

	_appetite_label.text = get_appetite_string()


func get_appetite_string() -> String:
	return str(_appetite)

		
func get_appetite() -> int:
	return _appetite


func get_mapped_appetite_value(dice: Dice) -> int:
	var base_value = dice.get_calculated_score() + dice.get_stored_score()
	var course_multi = 1.0
	var taste_multi = 1.0
	var prep_multi = 1.0

	for course in dice._dice_courses:
		if _course_map.has(course):
			course_multi *= _course_map[course]

	for taste in dice._dice_taste:
		if _taste_map.has(taste):
			taste_multi *= _taste_map[taste]

	for prep in dice._dice_preparation:
		if _preparation_map.has(prep):
			prep_multi *= _preparation_map[prep]

	var mapped_value = int(round(base_value * (course_multi * taste_multi * prep_multi)))
	return mapped_value


func set_appetite(value: int) -> void:
	_appetite = value
	update_appetite_label()


func _reset_values() -> void:
	consumption_log.clear()


func _add_icons() -> void:
	for course in _course_preferences:
		if course == G_ENUM.Course.NONE:
			continue

		if G_ENUM.COURSE_ICON_PATHS.has(course):
			var icon = load(G_ENUM.COURSE_ICON_PATHS[course])
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_customer_icons_hbox.add_child(tex_rect)

	for taste in _taste_preferences:
		if taste == G_ENUM.Tastes.NONE:
			continue

		if G_ENUM.TASTE_ICON_PATHS.has(taste):
			var icon = load(G_ENUM.TASTE_ICON_PATHS[taste])
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_customer_icons_hbox.add_child(tex_rect)

	for prep in _preparation_preferences:
		if prep == G_ENUM.Preparation.NONE:
			continue

		if G_ENUM.PREPARATION_ICON_PATHS.has(prep):
			var icon = load(G_ENUM.PREPARATION_ICON_PATHS[prep])
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_customer_icons_hbox.add_child(tex_rect)


# func _on_area_2d_mouse_entered() -> void:
# 	_customer_hbox.visible = true


# func _on_area_2d_mouse_exited() -> void:
# 	_customer_hbox.visible = false
