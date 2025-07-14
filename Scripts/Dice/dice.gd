class_name Dice extends RigidBody2D

@export var dice_selection: G_ENUM.DiceSelection = G_ENUM.DiceSelection.INACTIVE
@export var dice_state: G_ENUM.DiceState = G_ENUM.DiceState.STATIONARY
@export var dice_template: DiceTemplate = null
@export var unique_id : int

# Template values
var dice_name: String

var _is_flat_preset: bool = false
var _flat_value: int = 0
var _flat_conditional: int = 0
var _flat_quality_multipliers: Dictionary[G_ENUM.FoodQuality, float]

var _is_multiplier_preset: bool = false
var _multiplier_value: float = 1.0
var _multiplier_quality_multipliers: Dictionary[G_ENUM.FoodQuality, float]

var _base_quality_multipliers: Dictionary[G_ENUM.FoodQuality, float]

var _type: G_ENUM.DiceType
var _score_type: G_ENUM.ScoreType
var _available_values: Array[G_ENUM.FoodQuality]
var _available_values_index: int
var _face_value: int

@onready var roll_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var dice_radius: float = $CollisionShape2D.shape.radius

const LERP_SPEED: float = 2.0
const LERP_THRESHOLD: int = 30
const MAXIMUM_STRENGTH: float = 3000.0
const MINIMUM_STRENGTH: float = 100.0
const PIXELS_TO_UNITS : float = 1/3.2
const PREDICT_LINE_WIDTH: float = 2.0
const STRENGTH_MULTIPLIER: float = 10.0
const UNITS_TO_PIXELS : float = 3.2

var base_score: int = 0
var total_multiplier: float = 1.0
var calculated_score: int = 0
var reported_score: int = 0
var strategy: ScoringStrategy = null

var score: int = 0
var bonus_score: int = 0
var flat_score: int = 0
var collision_log: Array[Dictionary] = []
var _arrow: Node2D = null
var _arrow_scene = preload("res://Scenes/arrow.tscn")

func initialise_values_from_template():
	if dice_template:
		dice_name = dice_template.dice_name
		_base_quality_multipliers = dice_template.base_quality_multipliers
		_flat_quality_multipliers = dice_template.flat_quality_multipliers
		_multiplier_quality_multipliers = dice_template.multiplier_quality_multipliers
		_type = dice_template.dice_type
		_score_type = dice_template.dice_score_type
		_available_values = dice_template.prepared_values.duplicate()
		_available_values_index = randi() % _available_values.size()
		_face_value = _available_values[_available_values_index]
		_create_custom_animation()

func _ready() -> void:
	SignalManager.reset_dice_score.connect(_reset_score)
	# update_animation_from_values()
	_arrow = _arrow_scene.instantiate()
	add_child(_arrow)
	hide_arrow()
	connect("body_entered", _on_body_entered)


func _physics_process(delta: float) -> void:
	if linear_velocity.length() < LERP_THRESHOLD and linear_velocity.length() > 0.1:
		linear_velocity = linear_velocity.lerp(Vector2.ZERO, LERP_SPEED * delta)		
		if linear_velocity.length() < 1:
			linear_velocity = Vector2.ZERO

	var new_state = G_ENUM.DiceState.STATIONARY if linear_velocity.length() == 0 else G_ENUM.DiceState.MOVING
	
	if dice_state == new_state:
		return

	set_dice_state(new_state)

func _draw():	
	if (dice_selection == G_ENUM.DiceSelection.ACTIVE and dice_state == G_ENUM.DiceState.STATIONARY):
		var mouse_to_dice_position: Vector2 = get_global_mouse_position() - global_position
		var dir: Vector2 = mouse_to_dice_position.normalized()
		var impulse_strength: float = get_impulse_strength()
		var space_state = get_world_2d().direct_space_state
		var global_points = DicePredict.predict_path(global_position, dir, impulse_strength, mass, space_state)
		var local_points = []

		for p in global_points:
			local_points.append(to_local(p))

		draw_polyline(local_points, Color.GREEN, PREDICT_LINE_WIDTH)

func _input(event):
	if dice_selection != G_ENUM.DiceSelection.ACTIVE:
		return
	if _handle_launch_input(event):
		return
	if _handle_prediction_input(event):
		return

func _handle_launch_input(event) -> bool:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var direction: Vector2 = -get_input_direction()
		var strength: float = get_impulse_strength()
		set_dice_selection(G_ENUM.DiceSelection.INACTIVE)
		SignalManager.request_dice_impulse.emit(self, direction, strength)
		SignalManager.dice_launched.emit()
		return true
	return false

func _handle_prediction_input(event) -> bool:
	if dice_state == G_ENUM.DiceState.STATIONARY and (event is InputEventMouseMotion or event is InputEventMouseButton):
		update_arrow()
		queue_redraw()
		return true
	return false
	
func get_impulse_strength() -> float:
	var distance: float = get_input_vector().length()

	return clampf((
		clampf(distance, dice_radius, INF) - dice_radius
		) * STRENGTH_MULTIPLIER, MINIMUM_STRENGTH, MAXIMUM_STRENGTH
	)

func calculate_circle_point(radius : float, angle : float, offset : Vector2) -> Vector2:
	return offset + Vector2(radius * cos(angle), radius * sin(angle))

func get_input_direction() -> Vector2:
	return get_input_vector().normalized()

func show_arrow():
	_arrow.visible = true

func hide_arrow():
	_arrow.visible = false

func update_arrow():
	show_arrow()
	var center = global_position
	var current_angle = center.angle_to_point(get_global_mouse_position())
	var point_on_circle = calculate_circle_point(dice_radius, current_angle, center)
	_arrow.global_position = point_on_circle
	_arrow.rotation = current_angle - rotation

func set_dice_selection(new_selection: G_ENUM.DiceSelection):
	if dice_selection == new_selection:
		return

	dice_selection = new_selection

	match dice_selection:
		G_ENUM.DiceSelection.ACTIVE:
			show_arrow()
			update_arrow()
		G_ENUM.DiceSelection.INACTIVE:
			hide_arrow()

	queue_redraw()

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
				update_arrow()
		G_ENUM.DiceState.MOVING:
			SignalManager.dice_started_moving.emit()
			roll_animation.play("Roll")
			hide_arrow()

	queue_redraw()

func get_input_vector() -> Vector2:
	return get_global_mouse_position() - global_position

## Returns the current sprite frame associated with the dice face value.
func get_sprite_frame() -> int:
	return _face_value - 1


func get_icon_texture(sprite_frame: int = 0) -> Texture2D:
	return roll_animation.sprite_frames.get_frame_texture("All", sprite_frame)


func get_score() -> int:
	if not dice_template:
		return 0
	
	return dice_template.calculate_score(self)

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


func _reset_score():
	_multiplier_value = 1.0
	score = 0
	bonus_score = 0
	flat_score = 0
	base_score = 0
	total_multiplier = 1.0
	reported_score = 0
	calculated_score = 0
	
	if _type == G_ENUM.DiceType.GARLIC:
		for entry in collision_log:
			print("Garlic Log Entry:", entry)

	collision_log.clear()
	print("Log Cleared:", collision_log)


func _on_body_entered(body: Node) -> void:
	if body is Dice:
		log_collision(body)
		var impact_point = (global_position + body.global_position) / 2
		var impact_normal = (global_position - body.global_position).normalized()
		var impact_strength = clamp((linear_velocity - body.linear_velocity).length() / 1000.0, 0, 1)
		spawn_impact_particles(impact_point, impact_normal, impact_strength)

	if _type == G_ENUM.DiceType.PIZZA:
		score += 1
		SignalManager.dice_score_updated.emit(self, score)
		print("Score increased to: ", score)

func _debug_draw_impact_point(point: Vector2):
	var indicator = ColorRect.new()
	indicator.color = Color(1, 0, 0, 0.7)
	indicator.size = Vector2(10, 10)
	indicator.position = to_local(point) - indicator.size / 2
	add_child(indicator)

	indicator.set_z_as_relative(false)
	indicator.z_index = 1000
	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(func(): indicator.queue_free())
	add_child(timer)
	timer.start()


func _debug_draw_normal(point: Vector2, normal: Vector2, length: float = 40.0):
	var line = Line2D.new()
	line.width = 2
	line.default_color = Color(0, 0.7, 1, 1)
	var start = to_local(point)
	var end = to_local(point + normal.normalized() * length)
	line.points = [start, end]
	add_child(line)

	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(func(): line.queue_free())
	add_child(timer)
	timer.start()


func log_collision(other_dice: Dice) -> void:
	collision_log.append({
		"other_dice": other_dice,
		"processed": false,
		"timestamp": Time.get_ticks_msec()
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

func highlight(active: bool):
	if active:
		$HighlightParticles.emitting = true
	else:
		$HighlightParticles.emitting = false


func spawn_impact_particles(position: Vector2, normal: Vector2, impact_strength: float = 1.0) -> void:
	var particles = $ImpactParticles
	particles.global_position = position
	particles.rotation = normal.angle() + PI

	var min_amount = 5
	var max_amount = 30

	impact_strength = clamp(impact_strength, 0, 1)
	print("Impact strength: ", impact_strength)
	particles.amount = int(lerp(min_amount, max_amount, impact_strength))

	var min_velocity = lerp(100.0, 300.0, impact_strength)
	var max_velocity = lerp(200.0, 1000.0, impact_strength)

	var particle_material: ParticleProcessMaterial = particles.process_material
	if particle_material is ParticleProcessMaterial:
		particle_material.initial_velocity_min = min_velocity
		particle_material.initial_velocity_max = max_velocity

	particles.emitting = false # Reset
	particles.emitting = true


func set_flat_value(value: int):
	_flat_value = value


func get_flat_value() -> int:
	if _is_flat_preset:
		return clamp(_flat_quality_multipliers.get(_flat_value + _flat_conditional), 0, _flat_quality_multipliers[_flat_quality_multipliers.size() - 1])
	else:
		return _flat_value


func get_multiplier_value() -> float:
	if _is_multiplier_preset:
		return _multiplier_value
	else:
		return _multiplier_value * _multiplier_quality_multipliers.get(_face_value, 1)


func get_base_quality_multiplier() -> float:
	if dice_template.base_quality_multipliers:
		return dice_template.base_quality_multipliers.get(_face_value, 1.0)
	return 1.0


func get_reported_score() -> float:
	print("Reported score: ", score * _base_quality_multipliers.get(_face_value, 1))
	return score * _base_quality_multipliers.get(_face_value, 1)


func get_base_score() -> float:
	return (score + _flat_value) * _base_quality_multipliers.get(_face_value, 1)


func get_calculated_score() -> float:
	return (score + _flat_value) * _base_quality_multipliers.get(_face_value, 1) * total_multiplier


func get_quality_multiplier() -> float:
	return _base_quality_multipliers.get(_face_value, 1)
