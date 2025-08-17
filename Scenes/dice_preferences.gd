class_name DicePreferences extends Node2D

var _dice: Dice

# TODO: Update using canvas
func _process(delta):
	rotation = -_dice.rotation

func add_dice_icons() -> void:
	var icons_hbox = get_node("%DiceIconsHBox")

	for course in _dice._dice_courses:
		print("Adding course icon for: ", course)

		if course == G_ENUM.Course.NONE:
			continue

		if G_ENUM.COURSE_ICON_PATHS.has(course):
			var icon = load(G_ENUM.COURSE_ICON_PATHS[course])
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icons_hbox.add_child(tex_rect)
			print("Added course icon for: ", course)

	for taste in _dice._dice_taste:
		if taste == G_ENUM.Tastes.NONE:
			continue
		if G_ENUM.TASTE_ICON_PATHS.has(taste):
			var icon = load(G_ENUM.TASTE_ICON_PATHS[taste])
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icons_hbox.add_child(tex_rect)

	for prep in _dice._dice_preparation:
		if prep == G_ENUM.Preparation.NONE:
			continue
		if G_ENUM.PREPARATION_ICON_PATHS.has(prep):
			var icon = load(G_ENUM.PREPARATION_ICON_PATHS[prep])
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icons_hbox.add_child(tex_rect)
