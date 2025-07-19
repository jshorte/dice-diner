class_name DicePredict extends Node

static func get_prediction_points(
		start_pos: Vector2,
		direction: Vector2,
		strength: float,
		mass: float,
		dice_radius: float,
		linear_damp: float,
		predict_cast: ShapeCast2D,
		circle_spacing: float = 20.0,
		min_multiplier: float = 0.75,
		max_multiplier: float = 0.9,
		min_strength: float = 100.0,
	) -> Dictionary:

	var velocity = (strength / mass) * direction
	var t = (strength - min_strength) / (min_strength * 2 - min_strength)
	t = clampf(t, 0.0, 1.0)
	var distance_multiplier = lerp(min_multiplier, max_multiplier, t)
	var max_distance = (velocity.length() / linear_damp) * distance_multiplier

	# var predict_cast = ShapeCast2D.new()
	predict_cast.shape = CircleShape2D.new()
	predict_cast.shape.radius = dice_radius
	predict_cast.target_position = direction.normalized() * max_distance
	predict_cast.global_position = start_pos

	predict_cast.force_shapecast_update()
	var end_point = start_pos + predict_cast.target_position
	var ghost_pos = end_point
	var collided = false
	var normal = Vector2.ZERO

	if predict_cast.is_colliding():
		var collision_point = predict_cast.get_collision_point(0)
		normal = predict_cast.get_collision_normal(0)
		ghost_pos = collision_point + normal * dice_radius
		end_point = ghost_pos
		collided = true

	var path_points = []
	var total_length = (end_point - start_pos).length()
	var dir_norm = (end_point - start_pos).normalized()
	var steps = int(total_length / circle_spacing)
	for i in range(steps + 1):
		var point = start_pos + dir_norm * (i * circle_spacing)
		# Clamp to end_point to avoid overshooting
		if (point - start_pos).length() > total_length:
			break
		path_points.append(point)

	return {
		"path_points": path_points,
		"ghost_pos": ghost_pos,
		"collided": collided,
		"normal": normal
	}
