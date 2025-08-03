extends Node

var _current_stage: int = 1
var _customer_scene = preload("res://Scenes/customer.tscn")
var _spawn_locations: Array[Vector2] = []

@onready var _customer_positions: Node = get_node("/root/main/SpawnPositions/CustomerPositions")
@onready var _customer_root: Node = get_node("/root/main/Customers")

# TODO: Have customer templates in level folders and randomly select customers depending on the current level

var _level_one_customer_templates = [
	("res://resources/customer_types/stage_1/customer_1.tres"),
	("res://resources/customer_types/stage_1/customer_2.tres"),
]


func _ready():
	# TODO: Load spawn locations from a level resource or scene
	_get_spawn_locations()
	SignalManager.emit_ready.connect(_emit_ready)
	SignalManager.request_customer_load.connect(_on_load_customer)
	pass


func _emit_ready():
	SignalManager.customer_manager_ready.emit()


func _on_load_customer() -> void: 
	var number_to_load: int = 2
	
	for i in range(number_to_load):
		var blank_customer: Customer = _customer_scene.instantiate()

		blank_customer.customer_template = _get_random_customer_template()
		blank_customer.position = _get_random_spawn_location()
		blank_customer.initialise_values_from_template()
		_customer_root.add_child(blank_customer)
		# TODO: Add customer to orders panel
		SignalManager.customer_added.emit(blank_customer)
		

func _get_random_customer_template() -> CustomerTemplate:
	if _current_stage == 1:
		if _level_one_customer_templates.size() == 0:
			push_error(false, "No customer templates available for the current stage.")
			return null

		var rand_index = randi() % _level_one_customer_templates.size()
		var template_path = _level_one_customer_templates[rand_index]
		_level_one_customer_templates.remove_at(rand_index)
		return load(template_path)

	push_error(false, "No customer templates available for the current stage.")
	return null


func _get_spawn_locations() -> void:
	_spawn_locations.clear()

	for child in _customer_positions.get_children():
		_spawn_locations.append(child.global_position)


func _get_random_spawn_location() -> Vector2:
	if _spawn_locations.size() == 0:
		push_error(false, "No spawn locations available for customers.")
		return Vector2.ZERO

	var rand_index = randi() % _spawn_locations.size()
	var location = _spawn_locations[rand_index]
	_spawn_locations.remove_at(rand_index)
	return location
