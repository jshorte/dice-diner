extends Control

var is_visible: bool

func _ready():
	is_visible = visible

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			is_visible = not is_visible
			visible = is_visible
