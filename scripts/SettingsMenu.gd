extends ColorRect
class_name SettingsMenu

var main: Node

var slider_master: HSlider
var slider_gamma: HSlider
var slider_contrast: HSlider
var slider_saturation: HSlider
var slider_time: HSlider
var cb_clouds: CheckBox
var cb_shadows: CheckBox
var cb_fullscreen: CheckBox

var tabs: TabContainer
var btn_close: Button

func _init(_main: Node):
	main = _main
	
	color = Color(0.05, 0.05, 0.08, 0.98)
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 2000
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.add_theme_constant_override("separation", 40)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)
	
	var title = Label.new()
	title.text = TranslationManager.translate("settings")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set("theme_override_font_sizes/font_size", 60)
	vbox.add_child(title)
	
	tabs = TabContainer.new()
	tabs.custom_minimum_size = Vector2(1000, 600)
	tabs.tab_alignment = TabBar.ALIGNMENT_CENTER
	vbox.add_child(tabs)
	
	_build_audio_tab()
	_build_video_tab()
	_build_game_tab()
	_build_lang_tab()
	
	btn_close = Button.new()
	btn_close.text = TranslationManager.translate("close")
	btn_close.set("theme_override_font_sizes/font_size", 50)
	btn_close.custom_minimum_size = Vector2(400, 80)
	btn_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_close.pressed.connect(_on_close)
	vbox.add_child(btn_close)

	visibility_changed.connect(func():
		if visible and is_instance_valid(main) and is_instance_valid(main.ui_layer):
			main.ui_layer.move_child(self, -1)
	)
	
func _build_audio_tab():
	var tab = VBoxContainer.new()
	tab.name = "Audio"
	tab.alignment = BoxContainer.ALIGNMENT_CENTER
	tab.add_theme_constant_override("separation", 30)
	
	var lbl = Label.new()
	lbl.text = "Master Volume"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.set("theme_override_font_sizes/font_size", 30)
	tab.add_child(lbl)
	
	slider_master = HSlider.new()
	slider_master.min_value = 0
	slider_master.max_value = 100
	slider_master.value = SaveManager.load_settings().get("volume", 50.0)
	slider_master.custom_minimum_size = Vector2(400, 50)
	slider_master.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slider_master.value_changed.connect(func(v):
		var bus = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(bus, linear_to_db(v / 100.0))
	)
	tab.add_child(slider_master)
	
	tabs.add_child(tab)

func _build_video_tab():
	var tab = VBoxContainer.new()
	tab.name = "Graphics"
	tab.alignment = BoxContainer.ALIGNMENT_CENTER
	tab.add_theme_constant_override("separation", 20)
	
	var st = SaveManager.load_settings()
	
	cb_fullscreen = CheckBox.new()
	cb_fullscreen.text = "Fullscreen"
	cb_fullscreen.button_pressed = st.get("fullscreen", false)
	cb_fullscreen.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tab.add_child(cb_fullscreen)
	
	# Gamma
	var ghbox = HBoxContainer.new()
	ghbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var gl = Label.new(); gl.text = "Brightness"; gl.custom_minimum_size = Vector2(150, 0)
	ghbox.add_child(gl)
	slider_gamma = HSlider.new()
	slider_gamma.min_value = 0; slider_gamma.max_value = 200; slider_gamma.value = st.get("gamma", 100)
	slider_gamma.custom_minimum_size = Vector2(300, 40)
	ghbox.add_child(slider_gamma)
	tab.add_child(ghbox)
	
	# Contrast
	var chbox = HBoxContainer.new()
	chbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var cl = Label.new(); cl.text = "Contrast"; cl.custom_minimum_size = Vector2(150, 0)
	chbox.add_child(cl)
	slider_contrast = HSlider.new()
	slider_contrast.min_value = 0; slider_contrast.max_value = 200; slider_contrast.value = st.get("contrast", 100)
	slider_contrast.custom_minimum_size = Vector2(300, 40)
	chbox.add_child(slider_contrast)
	tab.add_child(chbox)
	
	# Saturation
	var shbox = HBoxContainer.new()
	shbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var sl = Label.new(); sl.text = "Saturation"; sl.custom_minimum_size = Vector2(150, 0)
	shbox.add_child(sl)
	slider_saturation = HSlider.new()
	slider_saturation.min_value = 0; slider_saturation.max_value = 200; slider_saturation.value = st.get("saturation", 100)
	slider_saturation.custom_minimum_size = Vector2(300, 40)
	shbox.add_child(slider_saturation)
	tab.add_child(shbox)
	
	var btn_reset = Button.new()
	btn_reset.text = "Reset Visuals"
	btn_reset.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_reset.pressed.connect(func():
		slider_gamma.value = 100
		slider_contrast.value = 100
		slider_saturation.value = 100
	)
	tab.add_child(btn_reset)
	
	tabs.add_child(tab)

func _build_game_tab():
	var tab = VBoxContainer.new()
	tab.name = "Game"
	tab.alignment = BoxContainer.ALIGNMENT_CENTER
	tab.add_theme_constant_override("separation", 20)
	
	cb_clouds = CheckBox.new()
	cb_clouds.text = "Enable Clouds"
	cb_clouds.button_pressed = SaveManager.load_settings().get("clouds", true)
	cb_clouds.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tab.add_child(cb_clouds)
	
	cb_shadows = CheckBox.new()
	cb_shadows.text = "Enable Shadows"
	cb_shadows.button_pressed = SaveManager.load_settings().get("shadows", true)
	cb_shadows.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tab.add_child(cb_shadows)
	
	slider_time = HSlider.new()
	slider_time.min_value = 0
	slider_time.max_value = 24
	slider_time.value = SaveManager.load_settings().get("time_of_day", 12)
	tabs.add_child(tab)

func _build_lang_tab():
	var tab = VBoxContainer.new()
	tab.name = "Language"
	tab.alignment = BoxContainer.ALIGNMENT_CENTER
	tab.add_theme_constant_override("separation", 30)
	
	var btn_en = Button.new()
	btn_en.text = "English"
	btn_en.set("theme_override_font_sizes/font_size", 40)
	btn_en.pressed.connect(func(): _set_lang("en"))
	tab.add_child(btn_en)
	
	var btn_ru = Button.new()
	btn_ru.text = "Русский"
	btn_ru.set("theme_override_font_sizes/font_size", 40)
	btn_ru.pressed.connect(func(): _set_lang("ru"))
	tab.add_child(btn_ru)
	
	var btn_uk = Button.new()
	btn_uk.text = "Українська"
	btn_uk.set("theme_override_font_sizes/font_size", 40)
	btn_uk.pressed.connect(func(): _set_lang("uk"))
	tab.add_child(btn_uk)
	
	tabs.add_child(tab)

func _set_lang(lang: String):
	TranslationManager.set_locale(lang)
	main.update_ui_translation()
	btn_close.text = TranslationManager.translate("close")
	var s = SaveManager.load_settings()
	SaveManager.save_settings(lang, s.get("fullscreen", false), s.get("volume", 50.0), s.get("resolution", 0))

func apply_visuals():
	if is_instance_valid(main):
		if is_instance_valid(main.world_env) and main.world_env.environment:
			var e = main.world_env.environment
			e.adjustment_brightness = slider_gamma.value / 100.0
			e.adjustment_contrast = slider_contrast.value / 100.0
			e.adjustment_saturation = slider_saturation.value / 100.0
		if is_instance_valid(main.clouds_rect):
			main.clouds_rect.visible = cb_clouds.button_pressed
		for p in main.player_pawns + main.bot_pawns:
			if is_instance_valid(p) and p.has_node("DropShadow"):
				p.get_node("DropShadow").visible = cb_shadows.button_pressed
				
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if cb_fullscreen.button_pressed else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)

func _on_close():
	apply_visuals()
	SaveManager.save_visual_settings(
		slider_gamma.value, 
		slider_contrast.value, 
		slider_saturation.value, 
		slider_time.value, 
		cb_clouds.button_pressed, 
		cb_shadows.button_pressed
	)
	var s = SaveManager.load_settings()
	SaveManager.save_settings(s.get("locale", "en"), cb_fullscreen.button_pressed, slider_master.value, 0)
	
	hide()
	if is_instance_valid(main) and not main.pause_panel.visible:
		main.get_tree().paused = false
