class_name DiceVisual extends Node2D

var _dice: Dice
var _arrow: Node2D = null
var _arrow_scene = preload("res://Scenes/arrow.tscn")
var _ghost_sprite: Sprite2D = null

func _ready():	
	_arrow = _arrow_scene.instantiate()
	add_child(_arrow)
	display_arrow(false)
	

func _draw():
	if not _dice:
		return

	if _dice.dice_selection == G_ENUM.DiceSelection.ACTIVE and _dice.dice_state == G_ENUM.DiceState.STATIONARY:
		var direction: Vector2 = -_dice.get_input_direction()
		var strength: float = _dice.get_impulse_strength()
		var mass = 1

		var result = DicePredict.get_prediction_points(
			global_position,
			direction,
			strength,
			mass,
			_dice._dice_radius,
			_dice.linear_damp,
			_dice.get_node("%PredictCast"),
		)

		for i in result.path_points.size():
			draw_circle(to_local(result.path_points[i]), _dice._dice_radius * 0.1, Color(1, 1, 1, 0.5))

		if result.collided:
			show_ghost_sprite(result.ghost_pos)
		elif _ghost_sprite and is_instance_valid(_ghost_sprite):
			_ghost_sprite.queue_free()
			_ghost_sprite = null


func show_ghost_sprite(collision_position: Vector2):
	if _ghost_sprite == null or not is_instance_valid(_ghost_sprite):
		_ghost_sprite = Sprite2D.new()
		_ghost_sprite.texture = _dice.roll_animation.sprite_frames.get_frame_texture("All", _dice.get_sprite_frame())
		_ghost_sprite.modulate = Color(1, 1, 1, 0.35)
		_ghost_sprite.z_index = 999
		add_child(_ghost_sprite)
	_ghost_sprite.global_position = collision_position


func reset_ghost_sprite():
	if _ghost_sprite and is_instance_valid(_ghost_sprite):
			_ghost_sprite.queue_free()
			_ghost_sprite = null


func display_arrow(display: bool):
	if _arrow:
		_arrow.visible = display


func update_arrow(radius: float = 0.0, angle: float = 0.0, offset: Vector2 = Vector2.ZERO, ):
	display_arrow(true)
	var center = global_position
	var current_angle = center.angle_to_point(get_global_mouse_position())
	var point_on_circle = offset + Vector2(radius * cos(angle), radius * sin(angle))
	_arrow.global_position = point_on_circle
	_arrow.rotation = current_angle - rotation

func _exit_tree():
	reset_ghost_sprite()
