class_name DiceOptions extends HBoxContainer

var _dice: Dice
var preview = true

func _on_bump_button_pressed() -> void:
	if _dice and _dice._is_previewing_quality:
		_dice.commit_quality_preview()
		ScoreManager._calculate_score(false)
		for customer in ScoreManager.customer_to_score:
			customer.snapshot_appetite()
		_dice.start_quality_preview()


func _on_bump_button_mouse_entered() -> void:
	print("Bump button mouse entered")
	if _dice:
		_dice.start_quality_preview()
		ScoreManager._calculate_score(preview)
		_dice._dice_score_panel.update_score_display()


func _on_bump_button_mouse_exited():
	if _dice:
		_dice.end_quality_preview()
		ScoreManager._calculate_score(preview)
		_dice._dice_score_panel.update_score_display()
