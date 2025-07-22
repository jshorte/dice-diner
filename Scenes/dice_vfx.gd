class_name DiceVFX extends Node2D

var _dice: Dice

@onready var _impact_particles = get_node("%ImpactParticles")
@onready var _highlight_particles = get_node("%HighlightParticles")
@onready var _contributing_highlights = get_node("%ContributingHighlights")
@onready var _contributed_highlights = get_node("%ContributedHighlights")


func init_vfx():
	if not _dice:
		return


func _ready():
	if _impact_particles and _impact_particles.process_material:
		_impact_particles.process_material = _impact_particles.process_material.duplicate()


func spawn_impact_particles(impact_position: Vector2, normal: Vector2, impact_strength: float = 1.0) -> void:
	_impact_particles.global_position = impact_position
	_impact_particles.rotation = normal.angle() + PI

	var min_amount = 5
	var max_amount = 30

	impact_strength = clamp(impact_strength, 0, 1)
	print("Impact strength: ", impact_strength)
	_impact_particles.amount = int(lerp(min_amount, max_amount, impact_strength))

	var min_velocity = lerp(100.0, 300.0, impact_strength)
	var max_velocity = lerp(200.0, 1000.0, impact_strength)

	var particle_material: ParticleProcessMaterial = _impact_particles.process_material
	if particle_material is ParticleProcessMaterial:
		particle_material.initial_velocity_min = min_velocity
		particle_material.initial_velocity_max = max_velocity

	# Set particle color based on dice type
		match _dice._dice_type:
			G_ENUM.DiceType.FLATWHITE:
				particle_material.color = Color(0.4, 0.2, 0.05) # Brown
			G_ENUM.DiceType.GARLIC:
				particle_material.color = Color(1, 1, 1) # White
			_:
				particle_material.color = Color(1, 1, 0.5) # Default (e.g., yellowish)

	_impact_particles.emitting = false # Reset
	_impact_particles.emitting = true


func highlight(active: bool):
	_highlight_particles.emitting = active


func highlight_contributing(active: bool):
	_contributing_highlights.emitting = active


func highlight_contributed(active: bool):
	_contributed_highlights.emitting = active
