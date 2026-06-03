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
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	scale = Vector2.ZERO
	
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
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
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	
	figure_icon.size = Vector2(128, 128)
	figure_icon.pivot_offset = figure_icon.size / 2.0
	figure_icon.scale = Vector2(0.6, 0.6) # Reduced from 0.8
	figure_icon.position = center - (figure_icon.size / 2.0) + Vector2(0, 20)
	add_child(figure_icon)
	
	btn_left = TextureButton.new()
	btn_left.name = "ButtonLeft"
	btn_left.texture_normal = load("res://images/background_option_levelup.png")
	btn_left.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_left.ignore_texture_size = true
	btn_left.custom_minimum_size = Vector2(180, 180)
	btn_left.light_mask = 0
	add_child(btn_left)
	
	btn_right = TextureButton.new()
	btn_right.name = "ButtonRight"
	btn_right.texture_normal = load("res://images/background_option_levelup.png")
	btn_right.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_right.ignore_texture_size = true
	btn_right.custom_minimum_size = Vector2(180, 180)
	btn_right.light_mask = 0
	add_child(btn_right)
	
	# Moved buttons and OR down by 60px
	btn_left.size = Vector2(180, 180)
	btn_left.position = center + Vector2(-220, 190)
	
	btn_right.size = Vector2(180, 180)
	btn_right.position = center + Vector2(40, 190)
	
	var lbl_title = Label.new()
	lbl_title.text = "Level up"
	lbl_title.set("theme_override_font_sizes/font_size", 96) # 2x size
	lbl_title.set("theme_override_colors/font_color", Color.BLACK)
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.size = Vector2(400, 120)
	lbl_title.position = center + Vector2(-280, -220) # Moved left and down
	lbl_title.rotation_degrees = -20
	add_child(lbl_title)
	
	var lbl_lvl = Label.new()
	lbl_lvl.text = str(_level_num)
	lbl_lvl.set("theme_override_font_sizes/font_size", 108) # 2x size
	lbl_lvl.set("theme_override_colors/font_color", Color.BLACK)
	lbl_lvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_lvl.size = Vector2(160, 160)
	lbl_lvl.position = center + Vector2(280, -200) # Moved right and slightly up
	lbl_lvl.rotation_degrees = -15 # Tilted slightly left as it's often more natural, or they meant 180? I'll use 0. Let's make it 0.
	lbl_lvl.rotation_degrees = 0
	add_child(lbl_lvl)
	
	var lbl_or = Label.new()
	lbl_or.text = "OR"
	lbl_or.set("theme_override_font_sizes/font_size", 42)
	lbl_or.set("theme_override_colors/font_color", Color.BLACK)
	lbl_or.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_or.size = Vector2(100, 60)
	lbl_or.position = center + Vector2(-50, 240)
	add_child(lbl_or)
	
	var data = PieceData.registry.get(_piece_type, {})
	var p_name = data.get("title", "")
	var p_desc = data.get("desc", "")
	
	var lbl_name = Label.new()
	lbl_name.text = p_name
	lbl_name.set("theme_override_font_sizes/font_size", 28)
	lbl_name.set("theme_override_colors/font_color", Color.WHITE)
	lbl_name.set("theme_override_colors/font_outline_color", Color.BLACK)
	lbl_name.set("theme_override_constants/outline_size", 3)
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.size = Vector2(300, 40)
	lbl_name.position = center + Vector2(-150, 110)
	add_child(lbl_name)
	
	figure_icon.mouse_filter = Control.MOUSE_FILTER_PASS
	figure_icon.tooltip_text = p_desc
	
	# Left button (HP) content: heart.png in center, Label on top
	var tex_hp = TextureRect.new()
	tex_hp.texture = load("res://images/heart.png")
	tex_hp.custom_minimum_size = Vector2(80, 80)
	tex_hp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE # FIX for giant heart
	tex_hp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_hp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_hp.size = Vector2(80, 80)
	tex_hp.position = Vector2(50, 50) # Centered in 180x180
	btn_left.add_child(tex_hp)
	
	var lbl_hp = Label.new()
	lbl_hp.text = "1 HP"
	lbl_hp.set("theme_override_font_sizes/font_size", 40)
	lbl_hp.set("theme_override_colors/font_color", Color.BLACK)
	lbl_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_hp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_left.add_child(lbl_hp)
	
	# Right button (ATK) content: damage.png in center, Label on top
	var tex_atk = TextureRect.new()
	tex_atk.texture = load("res://images/damage.png")
	tex_atk.custom_minimum_size = Vector2(80, 80)
	tex_atk.expand_mode = TextureRect.EXPAND_IGNORE_SIZE # FIX for giant damage
	tex_atk.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_atk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_atk.size = Vector2(80, 80)
	tex_atk.position = Vector2(50, 50) # Centered in 180x180
	btn_right.add_child(tex_atk)
	
	var lbl_atk = Label.new()
	lbl_atk.text = "1 ATK"
	lbl_atk.set("theme_override_font_sizes/font_size", 40)
	lbl_atk.set("theme_override_colors/font_color", Color.BLACK)
	lbl_atk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_atk.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_atk.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_right.add_child(lbl_atk)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	btn_left.pressed.connect(func(): hp_upgraded.emit())
	btn_right.pressed.connect(func(): atk_upgraded.emit())
