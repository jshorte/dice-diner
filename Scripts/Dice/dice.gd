class_name Dice extends RigidBody2D


const LERP_SPEED: float = 2.0
const LERP_THRESHOLD: int = 30
const MAXIMUM_STRENGTH: float = 3000.0
const MINIMUM_STRENGTH: float = 100.0
const STRENGTH_MULTIPLIER: float = 10.0

@export var dice_selection: G_ENUM.DiceSelection = G_ENUM.DiceSelection.INACTIVE
@export var dice_state: G_ENUM.DiceState = G_ENUM.DiceState.STATIONARY
@export var dice_template: DiceTemplate = null
@export var unique_id : int

var strategy: ScoringStrategy = null
var collision_log: Array[Dictionary] = []
var contributions: Dictionary = {}
var contributions_from: Dictionary = {}

var _score: int = 0
var _calculated_score: int = 0
var _reported_score: int = 0
var _face_value: int
var _flat_value: int = 0
var _multiplier_value: float = 1.0
var _total_multiplier: float = 1.0

var _score_map: Dictionary[G_ENUM.FoodQuality, float]
var _flat_map: Dictionary[G_ENUM.FoodQuality, float]
var _multiplier_map: Dictionary[G_ENUM.FoodQuality, float]
var _phase_state: G_ENUM.PhaseState = G_ENUM.PhaseState.PREPARE

var _dice_name: String
var _dice_type: G_ENUM.DiceType
var _score_type: G_ENUM.ScoreType
var _available_values: Array[G_ENUM.FoodQuality]
var _available_values_index: int

@onready var visual: DiceVisual = $DiceVisual
@onready var vfx: DiceVFX = $DiceVFX
@onready var input: DiceInput = $DiceInput
@onready var roll_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var _dice_radius: float = $CollisionShape2D.shape.radius
@onready var _dice_score_panel: DiceScore = get_node("/root/main/Managers/HUD/DiceScore")


func initialise_values_from_template():
	if dice_template:
		_dice_name = dice_template.dice_name
		_score_map = dice_template.score_map
		_flat_map = dice_template.flat_map
		_multiplier_map = dice_template.multiplier_map
		_dice_type = dice_template.dice_type
		_score_type = dice_template.dice_score_type
		_available_values = dice_template.prepared_values.duplicate()
		_available_values_index = randi() % _available_values.size()
		_face_value = _available_values[_available_values_index]
		_create_custom_animation()


func _ready() -> void:
	SignalManager.reset_dice_score.connect(_reset_score)
	SignalManager.phase_state_changed.connect(_on_phase_state_changed)
	connect("body_entered", _on_body_entered)
	visual._dice = self
	vfx._dice = self
	input._dice = self


func _physics_process(delta: float) -> void:
	stop_slow_dice(delta)

	var new_state = G_ENUM.DiceState.STATIONARY if linear_velocity.length() == 0 else G_ENUM.DiceState.MOVING
	
	if dice_state == new_state:
		return

	set_dice_state(new_state)


func _on_body_entered(body: Node) -> void:
	if body is Dice:
		log_collision(body)
		var impact_point = (global_position + body.global_position) / 2
		var impact_normal = (global_position - body.global_position).normalized()
		var impact_strength = clamp((linear_velocity - body.linear_velocity).length() / 1000.0, 0, 1)
		vfx.spawn_impact_particles(impact_point, impact_normal, impact_strength)

	if _dice_type == G_ENUM.DiceType.PIZZA:
		_score += 1
		SignalManager.dice_score_updated.emit(self, _score)
		print("Score increased to: ", _score)


func _on_phase_state_changed(new_phase: G_ENUM.PhaseState) -> void:
	_phase_state = new_phase

	if _phase_state == G_ENUM.PhaseState.DRAW:
		_dice_score_panel.hide()


func _on_mouse_entered() -> void:
	if _phase_state != G_ENUM.PhaseState.SCORE:
		return

	_dice_score_panel._dice = self
	_dice_score_panel.update_score_display()
	_dice_score_panel.global_position = global_position + Vector2(0, -50)
	_dice_score_panel.show()


func _on_mouse_exited() -> void:
	if _phase_state != G_ENUM.PhaseState.SCORE:
		return

	_dice_score_panel.hide()


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


func get_sprite_frame() -> int:
	return _face_value - 1


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
	_total_multiplier = 1.0
	_reported_score = 0
	_calculated_score = 0
	collision_log.clear()


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
