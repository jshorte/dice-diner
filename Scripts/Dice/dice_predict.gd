class_name DicePredict extends Node

static func predict_path(start_pos: Vector2, direction: Vector2, strength: float, mass, space_state, steps: int = 30, timestep: float = 0.1) -> Array:
	var points = [start_pos]
	var velocity = (strength / mass) * -direction * 100
	var line_start = start_pos

	for i in steps:	
		var line_end = line_start + (velocity * timestep)
		var query = PhysicsRayQueryParameters2D.create(line_start, line_end, 1)
		var result = space_state.intersect_ray(query)

		if not result.is_empty():
			velocity = velocity.bounce(result.normal)
			points.append(result.position)
			break

		points.append(line_end)
		line_start = line_end
	return points