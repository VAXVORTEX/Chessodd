extends Control

var bg: TextureRect
var btn_left: TextureButton
var btn_right: TextureButton

var _piece_type: int
var _is_player: bool
var _level_num: int

signal hp_upgraded
signal atk_upgraded

func setup(piece_type: int, is_player: bool, level_num: int):
	_piece_type = piece_type
	_is_player = is_player
	_level_num = level_num
	
	name = "LevelUpScreen"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	light_mask = 0
	z_index = 400
	mouse_filter = Control.MOUSE_FILTER_STOP
	scale = Vector2.ZERO
	
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.light_mask = 0
	add_child(dim)
	
	bg = TextureRect.new()
	bg.name = "BackgroundCircle"
	if _piece_type == 3: # King
		bg.texture = load("res://images/screen_king_levelup.png")
	else:
		bg.texture = load("res://images/screen_ levelup.png")
	bg.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	bg.custom_minimum_size = Vector2(800, 800)
	bg.light_mask = 0
	add_child(bg)
	
	var figure_tex = PieceData.get_piece_texture(_piece_type, _is_player)
	var figure_icon = TextureRect.new()
	figure_icon.name = "FigureIcon"
	if figure_tex:
		figure_icon.texture = figure_tex
	figure_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	figure_icon.custom_minimum_size = Vector2(128, 128)
	figure_icon.light_mask = 0
	
	var center = get_viewport_rect().size / 2.0
	pivot_offset = center
	
	bg.size = Vector2(800, 800)
	bg.position = center - (bg.size / 2.0)
	
	# figure icon inside background
	figure_icon.size = Vector2(128, 128)
	figure_icon.pivot_offset = figure_icon.size / 2.0
	figure_icon.scale = Vector2(0.5, 0.5)
	figure_icon.position = center - (figure_icon.size / 2.0) + Vector2(0, 80)
	add_child(figure_icon)
	
	# Transparent buttons for the drawn green arrows
	btn_left = TextureButton.new()
	btn_left.name = "ButtonLeft"
	btn_left.custom_minimum_size = Vector2(200, 200)
	btn_left.light_mask = 0
	add_child(btn_left)
	
	btn_right = TextureButton.new()
	btn_right.name = "ButtonRight"
	btn_right.custom_minimum_size = Vector2(200, 200)
	btn_right.light_mask = 0
	add_child(btn_right)
	
	btn_left.size = Vector2(200, 200)
	btn_left.position = center + Vector2(-220, 150)
	
	btn_right.size = Vector2(200, 200)
	btn_right.position = center + Vector2(20, 150)
	
	# --- Labels for Level Up UI ---
	var lbl_title = Label.new()
	lbl_title.text = "NEW LEVEL"
	lbl_title.set("theme_override_font_sizes/font_size", 48)
	lbl_title.set("theme_override_colors/font_color", Color.BLACK)
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.size = Vector2(400, 60)
	lbl_title.position = center + Vector2(-300, -200)
	lbl_title.rotation_degrees = -20
	add_child(lbl_title)
	
	var lbl_lvl = Label.new()
	lbl_lvl.text = str(_level_num)
	lbl_lvl.set("theme_override_font_sizes/font_size", 54)
	lbl_lvl.set("theme_override_colors/font_color", Color.BLACK)
	lbl_lvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_lvl.size = Vector2(80, 80)
	lbl_lvl.position = center + Vector2(170, -230)
	lbl_lvl.rotation_degrees = 15
	add_child(lbl_lvl)
	
	var lbl_or = Label.new()
	lbl_or.text = "OR"
	lbl_or.set("theme_override_font_sizes/font_size", 42)
	lbl_or.set("theme_override_colors/font_color", Color.BLACK)
	lbl_or.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_or.size = Vector2(100, 60)
	lbl_or.position = center + Vector2(-50, 180)
	add_child(lbl_or)
	
	var lbl_desc = Label.new()
	var data = PieceData.registry.get(_piece_type, {})
	var p_name = data.get("title", "")
	var p_desc = data.get("desc", "")
	


	lbl_desc.text = p_name + "\n" + p_desc
	lbl_desc.set("theme_override_font_sizes/font_size", 24)
	lbl_desc.set("theme_override_colors/font_color", Color.WHITE)
	lbl_desc.set("theme_override_colors/font_outline_color", Color.BLACK)
	lbl_desc.set("theme_override_constants/outline_size", 3)
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.size = Vector2(500, 100)
	lbl_desc.position = center + Vector2(-250, -50)
	add_child(lbl_desc)
	
	var lbl_hp = Label.new()
	lbl_hp.text = "+1 HP"
	lbl_hp.set("theme_override_font_sizes/font_size", 42)
	lbl_hp.set("theme_override_colors/font_color", Color.BLACK)
	lbl_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hp.size = Vector2(200, 60)
	lbl_hp.position = center + Vector2(-220, 280)
	add_child(lbl_hp)
	
	var lbl_atk = Label.new()
	lbl_atk.text = "+1 ATK"
	lbl_atk.set("theme_override_font_sizes/font_size", 42)
	lbl_atk.set("theme_override_colors/font_color", Color.BLACK)
	lbl_atk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_atk.size = Vector2(200, 60)
	lbl_atk.position = center + Vector2(20, 280)
	add_child(lbl_atk)
	
	btn_left.pressed.connect(func(): hp_upgraded.emit())
	btn_right.pressed.connect(func(): atk_upgraded.emit())
	
	for n in get_tree().get_nodes_in_group("side_menu"):
		n.hide()
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
