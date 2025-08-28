class_name Dice extends RigidBody2D


const LERP_SPEED: float = 2.0
const LERP_THRESHOLD: int = 30
const MAXIMUM_STRENGTH: float = 2000.0
const MINIMUM_STRENGTH: float = 100.0
const STRENGTH_MULTIPLIER: float = 10.0

@export var dice_selection: G_ENUM.DiceSelection = G_ENUM.DiceSelection.INACTIVE
@export var dice_state: G_ENUM.DiceState = G_ENUM.DiceState.STATIONARY
@export var dice_template: DiceTemplate = null
@export var unique_id : int

var strategy: ScoringStrategy = null
var collision_log: Array[Dictionary] = []
var environment_collision_log: Array[Dictionary] = []
var contributions: Dictionary = {}
var contributions_from: Dictionary = {}
var stored_scores: Dictionary[int, int] = {}

var _score: int = 0
var _calculated_score: int = 0
var _reported_score: int = 0
var _face_value: int
var _flat_value: int = 0
var _multiplier_value: float = 1.0
var _total_multiplier: float = 1.0
var _course_multiplier: float = 1.0
var _starter_bonus_applied: bool = false
var _dessert_bonus_applied: bool = false

var _score_map: Dictionary[G_ENUM.FoodQuality, float]
var _flat_map: Dictionary[G_ENUM.FoodQuality, float]
var _multiplier_map: Dictionary[G_ENUM.FoodQuality, float]
var _phase_state: G_ENUM.PhaseState = G_ENUM.PhaseState.PREPARE

var _dice_name: String
var _dice_type: G_ENUM.DiceType
var _score_type: G_ENUM.ScoreType
var _dice_taste: Array[G_ENUM.Tastes]
var _dice_preparation: Array[G_ENUM.Preparation]
var _dice_courses: Array[G_ENUM.Course]
var _available_values: Array[G_ENUM.FoodQuality]
var _available_values_index: int
var _preview_original_quality: G_ENUM.FoodQuality = G_ENUM.FoodQuality.INEDIBLE
var _is_previewing_quality: bool = false

@onready var visual: DiceVisual = $DiceVisual
@onready var vfx: DiceVFX = $DiceVFX
@onready var input: DiceInput = $DiceInput
@onready var preferences: DicePreferences = $DicePreferences
@onready var roll_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var _dice_radius: float = $CollisionShape2D.shape.radius
@onready var _dice_data_panel: Control = get_node("/root/main/Managers/GUIManager/DiceData")
@onready var _dice_options: DiceOptions = get_node("/root/main/Managers/GUIManager/DiceData/DiceDataVBox/DiceOptions")
@onready var _dice_score_panel: DiceScore = get_node("/root/main/Managers/GUIManager/DiceData/DiceDataVBox/DiceScore")


func initialise_values_from_template():
	if dice_template:
		_dice_name = dice_template.dice_name
		_score_map = dice_template.score_map
		_flat_map = dice_template.flat_map
		_multiplier_map = dice_template.multiplier_map
		_dice_type = dice_template.dice_type
		_score_type = dice_template.dice_score_type
		_dice_taste = dice_template.dice_taste.duplicate()
		_dice_preparation = dice_template.dice_preparation.duplicate()
		_dice_courses = dice_template.dice_course.duplicate()
		_available_values = dice_template.prepared_values.duplicate()
		_available_values_index = randi() % _available_values.size()
		_face_value = _available_values[_available_values_index]
		_create_custom_animation()


func _ready() -> void:
	collision_log.clear()
	environment_collision_log.clear()
	add_to_group("dice")
	SignalManager.reset_score.connect(_reset_score)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	connect("body_entered", _on_body_entered)
	visual._dice = self
	vfx._dice = self
	input._dice = self
	preferences._dice = self
	preferences.add_dice_icons()


func _physics_process(delta: float) -> void:
	stop_slow_dice(delta)

	var new_state = G_ENUM.DiceState.STATIONARY if linear_velocity.length() == 0 else G_ENUM.DiceState.MOVING
	
	if dice_state == new_state:
		return

	set_dice_state(new_state)

# TODO: Move food specific scoring logic to strategy files (compromise: may lose live updates)
func _on_body_entered(body: Node) -> void:
	if body is Dice:
		log_collision(body)
		var impact_point = (global_position + body.global_position) / 2
		var impact_normal = (global_position - body.global_position).normalized()
		var impact_strength = clamp((linear_velocity - body.linear_velocity).length() / 1000.0, 0, 1)
		vfx.spawn_impact_particles(impact_point, impact_normal, impact_strength)
	else:
		log_environment_collision(body)
		if _dice_type == G_ENUM.DiceType.NEAPOLITAN:
			_score = 5
			SignalManager.dice_score_updated.emit(self, _score)

	if _dice_type == G_ENUM.DiceType.PIZZA:
		_score += 1
		SignalManager.dice_score_updated.emit(self, _score)
		print("Score increased to: ", _score)

	if _dice_type == G_ENUM.DiceType.COOKIE:
		SignalManager.dice_score_updated.emit(self, _score)
		_score = max(_score - 2, 0)


func _on_phase_state_changed(new_phase: G_ENUM.PhaseState) -> void:
	_phase_state = new_phase

	if _phase_state == G_ENUM.PhaseState.DRAW or \
	_phase_state == G_ENUM.PhaseState.ROLLING or \
	_phase_state == G_ENUM.PhaseState.ROLL:
		_dice_data_panel.hide()


func _on_mouse_entered() -> void:
	if _phase_state == G_ENUM.PhaseState.SCORE or _score_type == G_ENUM.ScoreType.BASE:
		_dice_score_panel._dice = self
		_dice_options._dice = self
		_dice_data_panel.visible = true
		_dice_data_panel.show()
		_dice_score_panel.update_score_display()
		# TODO: This should be a signal which we then update the position of the score panel,
		# setting its position to the top/bottom of the sceen depending on the location of the dice.
	preferences.visible = true


func _on_mouse_exited() -> void:
	preferences.visible = false
	if _phase_state == G_ENUM.PhaseState.ROLLING or \
	_phase_state == G_ENUM.PhaseState.ROLL:
		_dice_data_panel.hide()
		_dice_score_panel.update_score_display()


func stop_slow_dice(delta: float) -> void:
	if linear_velocity.length() < LERP_THRESHOLD and linear_velocity.length() > 0.1:
		linear_velocity = linear_velocity.lerp(Vector2.ZERO, LERP_SPEED * delta)		
		if linear_velocity.length() < 1:
			linear_velocity = Vector2.ZERO


func get_impulse_strength() -> float:
	var distance: float = get_input_vector().length()

	return clampf((
		clampf(distance, _dice_radius, INF) - _dice_radius
		) * STRENGTH_MULTIPLIER, MINIMUM_STRENGTH, MAXIMUM_STRENGTH
	)


func get_input_direction() -> Vector2:
	return get_input_vector().normalized()


func get_input_vector() -> Vector2:
	return get_global_mouse_position() - global_position


func set_dice_selection(new_selection: G_ENUM.DiceSelection):
	if dice_selection == new_selection:
		return

	dice_selection = new_selection

	match dice_selection:
		G_ENUM.DiceSelection.ACTIVE:
			visual.display_arrow(true)
			visual.update_arrow(_dice_radius, global_position.angle_to_point(get_global_mouse_position()), global_position)
		G_ENUM.DiceSelection.INACTIVE:
			visual.display_arrow(false)

	visual.queue_redraw()


func set_dice_state(new_state):
	if dice_state == new_state:
		return

	dice_state = new_state

	match dice_state:
		G_ENUM.DiceState.STATIONARY:
			roll_animation.pause()
			_face_value = _available_values[roll_animation.frame]
			SignalManager.dice_finished_moving.emit()
			if dice_selection == G_ENUM.DiceSelection.ACTIVE:
				visual.update_arrow(_dice_radius, global_position.angle_to_point(get_global_mouse_position()), global_position)
		G_ENUM.DiceState.MOVING:
			SignalManager.dice_started_moving.emit()
			roll_animation.play("Roll")
			visual.display_arrow(false)

	visual.queue_redraw()

# TODO: Put repeated logic into helper functions
func increase_quality():
	var current_quality = _face_value
	var current_index = _available_values.find(current_quality)
	
	if current_index == -1 or current_index == _available_values.size() - 1:
		print("Already at maximum quality")
		return
	
	var next_index = current_index + 1
	while next_index < _available_values.size() and _available_values[next_index] == current_quality:
		next_index += 1
	
	if next_index >= _available_values.size():
		print("Already at maximum quality")
		return
	
	var new_quality = _available_values[next_index]
	print("Increased quality from %s to %s" % [str(current_quality), str(new_quality)])
	_face_value = new_quality
	roll_animation.frame = get_sprite_frame()
	SignalManager.dice_quality_changed.emit()


func start_quality_preview():
	if not _is_previewing_quality:
		_preview_original_quality = _face_value
		_is_previewing_quality = true
		var current_index = _available_values.find(_face_value)
		if current_index == -1 or current_index == _available_values.size() - 1:
			return
		var next_index = current_index + 1
		while next_index < _available_values.size() and _available_values[next_index] == _face_value:
			next_index += 1
		if next_index >= _available_values.size():
			return
		_face_value = _available_values[next_index]
		roll_animation.frame = get_sprite_frame()

func end_quality_preview():
	if _is_previewing_quality:
		_face_value = _preview_original_quality 
		roll_animation.frame = get_sprite_frame()
		_is_previewing_quality = false


func commit_quality_preview():
	if _is_previewing_quality:
		_is_previewing_quality = false
		_preview_original_quality = _face_value
		SignalManager.dice_quality_changed.emit()


func get_sprite_frame() -> int:
	return _available_values.find(_face_value)


func get_icon_texture(sprite_frame: int = 0) -> Texture2D:
	return roll_animation.sprite_frames.get_frame_texture("All", sprite_frame)


func log_collision(other_dice: Dice) -> void:
	collision_log.append({
		"name": _dice_name,
		"other_dice": other_dice,
		"processed": false,
		"timestamp": Time.get_ticks_msec(),
		"current_flat_value": _flat_value,
	})
	ScoreManager.global_collision_log.append({
		"timestamp": Time.get_ticks_msec(),
		"dice": self,
		"other_dice": other_dice,
	})


func log_environment_collision(body: Node) -> void:
	environment_collision_log.append({
		"name": _dice_name,
		"other_body": body,
		"processed": false,
		"timestamp": Time.get_ticks_msec(),
	})


func roll_face():
	if not dice_template:
		print("Error: Dice template not set up correctly.")
		return
	_available_values_index = randi() % _available_values.size()
	_face_value = _available_values[_available_values_index]
	
	if roll_animation:
		roll_animation.frame = get_sprite_frame()


func _create_custom_animation():
	if roll_animation and dice_template and dice_template.dice_sprite_animation_path:
		var all_frames = load(dice_template.dice_sprite_animation_path)
		var roll_frames = SpriteFrames.new()

		roll_frames.add_animation("All")
		for i in all_frames.get_frame_count("All"):
			var tex = all_frames.get_frame_texture("All", i)
			roll_frames.add_frame("All", tex)

		roll_frames.add_animation("Roll")
		for i in _available_values.size():
			var frame_index = _available_values[i] - 1
			var frame_sprite = all_frames.get_frame_texture("All", frame_index)
			roll_frames.add_frame("Roll", frame_sprite)

		roll_animation.sprite_frames = roll_frames
		roll_animation.frame = get_sprite_frame()
	else:
		print("Error: Roll animation or dice template not set up correctly.")
		return


func _reset_score():
	_score = 0
	_flat_value = 0
	_multiplier_value = 1.0
	_course_multiplier = 1.0
	_total_multiplier = 1.0
	_reported_score = 0
	_calculated_score = 0
	_starter_bonus_applied = false
	_dessert_bonus_applied = false
	collision_log.clear()
	environment_collision_log.clear()
	SignalManager.clear_global_collision_log.emit()


func recalulate_score():
	_flat_value = 0
	_multiplier_value = 1.0
	_course_multiplier = 1.0
	_total_multiplier = 1.0
	_reported_score = 0
	_calculated_score = 0
	_starter_bonus_applied = false
	_dessert_bonus_applied = false


func add_stored_score(round_num: int, score: int) -> void:
	stored_scores[round_num] = score


func get_total_stored_score() -> int:
	var total = 0
	for s in stored_scores.values():
		total += s
	return total


func reset_stored_scores():
	stored_scores.clear()


#region Getters and Setters
func get_food_quality() -> String:
	match self._face_value:
		G_ENUM.FoodQuality.INEDIBLE:
			return "INEDIBLE"
		G_ENUM.FoodQuality.POOR:
			return "POOR"
		G_ENUM.FoodQuality.OK:
			return "OK"
		G_ENUM.FoodQuality.GOOD:
			return "GOOD"
		G_ENUM.FoodQuality.EXCELLENT:
			return "EXCELLENT"
		_:
			return "INEDIBLE"


func get_dice_type() -> G_ENUM.DiceType:
	return _dice_type


func get_score() -> int:
	return _score


func set_score(value: int):
	_score = value
	SignalManager.dice_score_updated.emit(self, _score)







func get_score_type() -> G_ENUM.ScoreType:
	return _score_type


func get_reported_score() -> int:
	return _reported_score


func get_calculated_score() -> int:
	return _calculated_score


func get_dice_name() -> String:
	return _dice_name


func get_score_map() -> Dictionary[G_ENUM.FoodQuality, float]:
	return _score_map


func get_flat_map() -> Dictionary[G_ENUM.FoodQuality, float]:
	return _flat_map


func get_multiplier_map() -> Dictionary[G_ENUM.FoodQuality, float]:
	return _multiplier_map

func set_course_multiplier(value: float) -> void:
	_course_multiplier = value





func get_total_multiplier() -> float:
	return _total_multiplier


func set_reported_score(value: int):
	_reported_score = value


func set_calculated_score(value: int):
	_calculated_score = value


func set_flat_value(value: int):
	_flat_value = value


func set_total_multiplier(value: float):
	_total_multiplier = value
#endregion
