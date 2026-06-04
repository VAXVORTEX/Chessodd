extends Control

var bg: TextureRect
var btn_left: TextureButton
var btn_right: TextureButton

var _piece_type: int
var _is_player: bool
var _level_num: int

var custom_tooltip: PanelContainer
var is_tooltip_active = false

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
	
	var center = get_viewport_rect().size / 2.0
	pivot_offset = center
	
	bg.size = Vector2(800, 800)
	bg.position = center - (bg.size / 2.0)
	
	var figure_icon = TextureRect.new()
	figure_icon.name = "FigureIcon"
	if figure_tex:
		figure_icon.texture = figure_tex
	figure_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	figure_icon.custom_minimum_size = Vector2(128, 128)
	figure_icon.light_mask = 0
	
	figure_icon.size = Vector2(128, 128)
	figure_icon.pivot_offset = figure_icon.size / 2.0
	figure_icon.scale = Vector2(0.6, 0.6)
	figure_icon.position = center - (figure_icon.size / 2.0) + Vector2(30, 20)
	
	var shadow_rect = TextureRect.new()
	shadow_rect.name = "DropShadow"
	if figure_tex:
		shadow_rect.texture = figure_tex
	shadow_rect.modulate = Color(0, 0, 0, 0.5)
	shadow_rect.position = Vector2(15, 20)
	shadow_rect.size = Vector2(128, 128)
	shadow_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shadow_rect.show_behind_parent = true
	figure_icon.add_child(shadow_rect)
	
	add_child(figure_icon)
	
	btn_left = TextureButton.new()
	btn_left.name = "ButtonLeft"
	btn_left.texture_normal = load("res://images/background_option_levelup.png")
	btn_left.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_left.ignore_texture_size = true
	btn_left.custom_minimum_size = Vector2(240, 240)
	btn_left.size = Vector2(240, 240)
	btn_left.light_mask = 0
	add_child(btn_left)
	
	var l_shad = Sprite2D.new()
	l_shad.texture = load("res://images/background_option_levelup.png")
	l_shad.modulate = Color(0,0,0,0.5)
	l_shad.position = Vector2(150, 150) + Vector2(15, 20)
	var btn_scale_factor = 300.0 / l_shad.texture.get_size().x
	l_shad.scale = Vector2((240.0 / l_shad.texture.get_size().x) * 0.85, (240.0 / l_shad.texture.get_size().x) * 0.85)
	l_shad.show_behind_parent = true
	btn_left.add_child(l_shad)
	
	btn_right = TextureButton.new()
	btn_right.name = "ButtonRight"
	btn_right.texture_normal = load("res://images/background_option_levelup.png")
	btn_right.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_right.ignore_texture_size = true
	btn_right.custom_minimum_size = Vector2(240, 240)
	btn_right.size = Vector2(240, 240)
	btn_right.light_mask = 0
	add_child(btn_right)
	
	var r_shad = Sprite2D.new()
	r_shad.texture = load("res://images/background_option_levelup.png")
	r_shad.modulate = Color(0,0,0,0.5)
	r_shad.position = Vector2(150, 150) + Vector2(15, 20)
	r_shad.scale = Vector2((240.0 / r_shad.texture.get_size().x) * 0.85, (240.0 / r_shad.texture.get_size().x) * 0.85)
	r_shad.show_behind_parent = true
	btn_right.add_child(r_shad)
	
	btn_left.size = Vector2(300, 300)
	btn_left.position = center + Vector2(-290, 140)
	
	btn_right.size = Vector2(300, 300)
	btn_right.position = center + Vector2(90, 140)
	
	var lbl_title = Label.new()
	lbl_title.text = "Level up"
	lbl_title.set("theme_override_font_sizes/font_size", 96)
	lbl_title.set("theme_override_colors/font_color", Color.BLACK)
	lbl_title.set("theme_override_colors/font_shadow_color", Color(0,0,0,0.3))
	lbl_title.set("theme_override_constants/shadow_offset_x", 3)
	lbl_title.set("theme_override_constants/shadow_offset_y", 3)
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.size = Vector2(400, 120)
	lbl_title.position = center + Vector2(-310, -136) # Down slightly from arrow top
	lbl_title.rotation_degrees = -27
	add_child(lbl_title)
	
	var lbl_lvl = Label.new()
	lbl_lvl.text = str(_level_num)
	lbl_lvl.set("theme_override_font_sizes/font_size", 160)
	lbl_lvl.set("theme_override_colors/font_color", Color.BLACK)
	lbl_lvl.set("theme_override_colors/font_shadow_color", Color(0,0,0,0.4))
	lbl_lvl.set("theme_override_constants/shadow_offset_x", 3)
	lbl_lvl.set("theme_override_constants/shadow_offset_y", 3)
	lbl_lvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_lvl.size = Vector2(160, 160)
	lbl_lvl.position = center + Vector2(328, -285)
	lbl_lvl.rotation_degrees = 10
	add_child(lbl_lvl)
	
	var lbl_or = Label.new()
	lbl_or.text = "OR"
	lbl_or.set("theme_override_font_sizes/font_size", 42)
	lbl_or.set("theme_override_colors/font_color", Color.BLACK)
	lbl_or.set("theme_override_colors/font_shadow_color", Color(0,0,0,0.4))
	lbl_or.set("theme_override_constants/shadow_offset_x", 2)
	lbl_or.set("theme_override_constants/shadow_offset_y", 2)
	lbl_or.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_or.custom_minimum_size = Vector2(100, 60)
	lbl_or.size = Vector2(100, 60)
	lbl_or.position = center + Vector2(-30, 230)
	add_child(lbl_or)
	
	var data = PieceData.registry.get(_piece_type, {})
	var p_name = data.get("title", "")
	var p_desc = data.get("desc", "")
	
	var lbl_name = Label.new()
	lbl_name.text = p_name
	lbl_name.set("theme_override_font_sizes/font_size", 56)
	lbl_name.set("theme_override_colors/font_color", Color.WHITE)
	lbl_name.set("theme_override_colors/font_outline_color", Color.BLACK)
	lbl_name.set("theme_override_constants/outline_size", 5)
	lbl_name.set("theme_override_colors/font_shadow_color", Color(0,0,0,0.6))
	lbl_name.set("theme_override_constants/shadow_offset_x", 4)
	lbl_name.set("theme_override_constants/shadow_offset_y", 4)
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.custom_minimum_size = Vector2(600, 80)
	lbl_name.size = Vector2(600, 80)
	lbl_name.position = center + Vector2(-300 + 20, 150) # Perfect align under figure
	add_child(lbl_name)
	
	figure_icon.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Dynamic Tooltip
	custom_tooltip = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.8)
	style.border_width_bottom = 2; style.border_width_left = 2; style.border_width_right = 2; style.border_width_top = 2
	style.border_color = Color.WHITE
	custom_tooltip.add_theme_stylebox_override("panel", style)
	custom_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_tooltip.z_index = 500
	custom_tooltip.hide()
	
	var tt_margin = MarginContainer.new()
	tt_margin.add_theme_constant_override("margin_left", 8)
	tt_margin.add_theme_constant_override("margin_right", 8)
	tt_margin.add_theme_constant_override("margin_top", 8)
	tt_margin.add_theme_constant_override("margin_bottom", 8)
	custom_tooltip.add_child(tt_margin)
	
	var tt_lbl = Label.new()
	tt_lbl.text = p_desc
	tt_lbl.set("theme_override_font_sizes/font_size", 24)
	tt_margin.add_child(tt_lbl)
	add_child(custom_tooltip)
	
	figure_icon.mouse_entered.connect(func(): is_tooltip_active = true; custom_tooltip.show())
	figure_icon.mouse_exited.connect(func(): is_tooltip_active = false; custom_tooltip.hide())
	
	# Left button (HP)
	var tex_hp = TextureRect.new()
	tex_hp.texture = load("res://images/heart.png")
	tex_hp.custom_minimum_size = Vector2(100, 100)
	tex_hp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_hp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_hp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_hp.size = Vector2(100, 100)
	tex_hp.position = Vector2(100, 100)
	btn_left.add_child(tex_hp)
	
	var lbl_hp = Label.new()
	lbl_hp.text = "1 HP"
	lbl_hp.set("theme_override_font_sizes/font_size", 44)
	lbl_hp.set("theme_override_colors/font_color", Color.BLACK)
	lbl_hp.set("theme_override_colors/font_shadow_color", Color(0,0,0,0.3))
	lbl_hp.set("theme_override_constants/shadow_offset_x", 2)
	lbl_hp.set("theme_override_constants/shadow_offset_y", 2)
	lbl_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_hp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_left.add_child(lbl_hp)
	
	# Right button (ATK)
	var tex_atk = TextureRect.new()
	tex_atk.texture = load("res://images/damage.png")
	tex_atk.custom_minimum_size = Vector2(100, 100)
	tex_atk.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_atk.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_atk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_atk.size = Vector2(100, 100)
	tex_atk.position = Vector2(100, 100)
	btn_right.add_child(tex_atk)
	
	var lbl_atk = Label.new()
	lbl_atk.text = "1 ATK"
	lbl_atk.set("theme_override_font_sizes/font_size", 44)
	lbl_atk.set("theme_override_colors/font_color", Color.BLACK)
	lbl_atk.set("theme_override_colors/font_shadow_color", Color(0,0,0,0.3))
	lbl_atk.set("theme_override_constants/shadow_offset_x", 2)
	lbl_atk.set("theme_override_constants/shadow_offset_y", 2)
	lbl_atk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_atk.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_atk.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_right.add_child(lbl_atk)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	btn_left.pressed.connect(func(): hp_upgraded.emit())
	btn_right.pressed.connect(func(): atk_upgraded.emit())

func _process(_delta):
	if is_tooltip_active and is_instance_valid(custom_tooltip):
		custom_tooltip.global_position = get_global_mouse_position() + Vector2(15, 15)
