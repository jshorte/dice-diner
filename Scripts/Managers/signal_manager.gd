extends Node

# Initialisation
signal hud_manager_ready
signal deck_manager_ready
signal emit_ready

# Dice management
signal request_dice_impulse
signal dice_placed
signal dice_started_moving
signal dice_finished_moving

# Deck management
signal request_deck_load
signal request_deck_draw

# GUI management
signal add_to_deck_panel
signal remove_from_deck_panel

# Game management
signal phase_state_changed