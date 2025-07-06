class_name DicePhysics extends Node

static func apply_dice_impulse(dice_node, direction, strength):
	if dice_node and dice_node is Dice:
		dice_node.apply_central_impulse(direction * strength)
