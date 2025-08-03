class_name CustomerBar extends Control

var customer_score_label_scene: PackedScene = preload("res://Scenes/customer_score_label.tscn")

var customer_to_score: Array[Customer] = []
var customer_score_labels: Array[CustomerScoreLabel] = []

@onready var _customer_score_vbox: VBoxContainer = get_node("%CustomerScoreVBox")

func _ready() -> void:
	SignalManager.customer_added.connect(_on_customer_added)
	SignalManager.score_updated.connect(_on_score_updated)
	# SignalManager.customer_removed.connect(_on_customer_removed)

func _on_customer_added(customer: Customer) -> void:
	var label = customer_score_label_scene.instantiate()

	customer_to_score.append(customer)
	customer_score_labels.append(label)
	_customer_score_vbox.add_child(label)
	label.set_customer(customer)

	for i in range(customer_to_score.size()):
		var l = customer_score_labels[i]
		l.set_customer_score(customer_to_score[i])
		l.visible = true

func _on_score_updated(_round_score: int, _total_score: int, _dice_scores: Array[Dice]) -> void:
	for i in range(customer_score_labels.size()):
		var label = customer_score_labels[i]
		label.update_customer_score()
	pass
