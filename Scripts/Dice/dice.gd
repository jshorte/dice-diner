class_name Dice extends RigidBody2D

@export var dice_selection: G_ENUM.DiceSelection = G_ENUM.DiceSelection.INACTIVE
@export var dice_state: G_ENUM.DiceState = G_ENUM.DiceState.STATIONARY
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

var arrow: Node2D = null
var arrow_scene = preload("res://Scenes/arrow.tscn")
	
func _ready() -> void:
	arrow = arrow_scene.instantiate()
	add_child(arrow)
	hide_arrow()

func _physics_process(delta: float) -> void:
	if linear_velocity.length() < LERP_THRESHOLD and linear_velocity.length() > 0.1:
		linear_velocity = linear_velocity.lerp(Vector2.ZERO, LERP_SPEED * delta)		
		if linear_velocity.length() < 1:
			linear_velocity = Vector2.ZERO

	var new_state = G_ENUM.DiceState.STATIONARY if linear_velocity.length() == 0 else G_ENUM.DiceState.MOVING
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
		hide_arrow()
		SignalManager.request_dice_impulse.emit(self, direction, strength)
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
	arrow.visible = true

func hide_arrow():
	arrow.visible = false

func update_arrow():
	show_arrow()
	var center = global_position
	var current_angle = center.angle_to_point(get_global_mouse_position())
	var point_on_circle = calculate_circle_point(dice_radius, current_angle, center)
	arrow.global_position = point_on_circle
	arrow.rotation = current_angle - rotation

func set_dice_state(new_state):
	if dice_state == new_state:
		return

	dice_state = new_state

	match dice_state:
		G_ENUM.DiceState.STATIONARY:
			roll_animation.pause()
			if dice_selection == G_ENUM.DiceSelection.ACTIVE:
				update_arrow()
		G_ENUM.DiceState.MOVING:
			roll_animation.play()
			hide_arrow()

	queue_redraw()

func get_input_vector() -> Vector2:
	return get_global_mouse_position() - global_position
