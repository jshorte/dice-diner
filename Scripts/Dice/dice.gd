extends RigidBody2D

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var direction = (global_position - get_global_mouse_position()).normalized()
        var strength = 1000
        SignalManager.request_dice_impulse.emit(self, direction, strength)
        print("Dice impulse requested with direction: ", direction, " and strength: ", strength)