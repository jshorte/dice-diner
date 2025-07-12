extends Node

# Initialisation
signal hud_manager_ready
signal deck_manager_ready
signal score_manager_ready
signal emit_ready

# Dice management
signal request_dice_impulse
signal dice_placed
signal dice_started_moving
signal dice_finished_moving
signal reset_dice_score

# Deck management
signal remove_placed_dice
signal request_deck_load
signal request_deck_draw
signal draw_completed

# GUI management
signal add_to_deck_panel
signal remove_from_deck_panel

# Game management
signal phase_state_changed

# Scoring management
signal score_completed