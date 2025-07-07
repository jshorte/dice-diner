extends Control

@onready var _current_hbox: HBoxContainer = get_node("%Current_HBox")
var _sprite_to_dice : Dictionary = {}

func _ready():
    SignalManager.add_to_playable_panel.connect(_on_add_to_playable_panel)
    SignalManager.emit_ready.connect(_emit_ready)

func _emit_ready():
    SignalManager.hud_manager_ready.emit()

func _on_add_to_playable_panel(dice):
    var _dice_sprite = TextureRect.new()
    _dice_sprite.texture = dice.get_icon_texture()
    _current_hbox.add_child(_dice_sprite)
    _sprite_to_dice[_dice_sprite] = dice
    print("Added dice to playable panel: ", _sprite_to_dice[_dice_sprite], " with icon: ", _dice_sprite)
