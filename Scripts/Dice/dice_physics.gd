extends Node

func _ready():
    SignalManager.request_dice_impulse.connect(_on_request_dice_impulse)

func _on_request_dice_impulse(dice_node, direction, strength):
    if dice_node and dice_node is RigidBody2D:
        dice_node.apply_central_impulse(direction * strength)
        print("Applied impulse to dice: ", dice_node.name, " with direction: ", direction, " and strength: ", strength)