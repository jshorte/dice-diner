extends Node

func _ready():
	SignalManager.request_dice_impulse.connect(Callable(DicePhysics, "apply_dice_impulse"))
