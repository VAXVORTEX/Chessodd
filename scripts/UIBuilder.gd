class_name UIBuilder

static func create_ui(main: Node):
	main.ui_layer = CanvasLayer.new()
	main.ui_layer.layer = 1
	main.add_child(main.ui_layer)
	
	main.item_tooltip = PanelContainer.new()
	var tt_style = StyleBoxFlat.new()
	tt_style.bg_color = Color(0.05, 0.05, 0.08, 0.95)
	tt_style.corner_radius_top_left = 8
	tt_style.corner_radius_bottom_right = 8
	tt_style.corner_radius_bottom_left = 8
	tt_style.corner_radius_top_right = 8
	tt_style.content_margin_left = 15
	tt_style.content_margin_right = 15
	tt_style.content_margin_top = 10
	tt_style.content_margin_bottom = 10
	tt_style.border_width_left = 2
	tt_style.border_width_right = 2
	tt_style.border_width_top = 2
	tt_style.border_width_bottom = 2
	tt_style.border_color = Color(0.3, 0.3, 0.4)
	main.item_tooltip.add_theme_stylebox_override("panel", tt_style)
	
	main.item_tooltip_lbl = Label.new()
	main.item_tooltip_lbl.set("theme_override_font_sizes/font_size", 24)
	main.item_tooltip_lbl.set("theme_override_colors/font_color", Color.WHITE)
	main.item_tooltip.add_child(main.item_tooltip_lbl)
	
	main.item_tooltip.z_index = 4096
	main.item_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.item_tooltip.hide()
	main.ui_layer.add_child(main.item_tooltip)
	
	main.info_panel = PanelContainer.new()
	main.info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.info_panel.z_index = 200
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_right = 4
	style.border_color = Color(0.3, 0.35, 0.4)
	main.info_panel.add_theme_stylebox_override("panel", style)
	main.info_panel.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	main.info_panel.custom_minimum_size = Vector2(350, 0)
	main.ui_layer.add_child(main.info_panel)
	
	var info_margin = MarginContainer.new()
	info_margin.add_theme_constant_override("margin_top", 100)
	info_margin.add_theme_constant_override("margin_bottom", 20)
	info_margin.add_theme_constant_override("margin_left", 20)
	info_margin.add_theme_constant_override("margin_right", 20)
	main.info_panel.add_child(info_margin)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 15)
	info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	info_margin.add_child(info_vbox)
	
	# Pause button moved back to hud_hbox
	
	main.info_statuses = HBoxContainer.new()
	main.info_statuses.alignment = BoxContainer.ALIGNMENT_CENTER
	main.info_statuses.add_theme_constant_override("separation", 10)
	info_vbox.add_child(main.info_statuses)
	
	main.info_tex = TextureRect.new()
	main.info_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	main.info_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	main.info_tex.custom_minimum_size = Vector2(240, 240)
	main.info_tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	info_vbox.add_child(main.info_tex)
	
	main.info_name = Label.new()
	main.info_name.set("theme_override_font_sizes/font_size", 48)
	main.info_name.set("theme_override_colors/font_color", Color.WHITE)
	main.info_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_vbox.add_child(main.info_name)
	
	main.info_stats = Label.new()
	main.info_stats.set("theme_override_font_sizes/font_size", 36)
	main.info_stats.set("theme_override_colors/font_color", Color(1, 0.5, 0.5))
	main.info_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_vbox.add_child(main.info_stats)
	
	main.info_desc = Label.new()
	main.info_desc.set("theme_override_font_sizes/font_size", 28)
	main.info_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(main.info_desc)
	
	main.info_item_slots = HBoxContainer.new()
	main.info_item_slots.add_theme_constant_override("separation", 10)
	main.info_item_slots.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in range(3):
		var slot = PanelContainer.new()
		slot.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				var art = slot.get_meta("item_id")
				var viewed_piece = main.info_panel.get_meta("viewed_piece")
				if is_instance_valid(viewed_piece) and art in ["bottle", "dark_mirror", "hand", "blood_knife", "torch", "finger"]:
					main.selected_piece = viewed_piece
					main.overlay.queue_redraw()
					if art == "bottle": main.start_bottle_targeting(viewed_piece, slot)
					elif art == "dark_mirror": main.start_dark_mirror_targeting(viewed_piece, slot)
					elif art == "hand": main.start_hand_targeting(viewed_piece, slot)
					elif art == "blood_knife": main.start_blood_knife_targeting(viewed_piece, slot)
					elif art == "torch": main.start_torch_targeting(viewed_piece, slot)
					elif art == "finger": main.start_finger_targeting(viewed_piece, slot)
					elif art == "finger": main.start_finger_targeting(viewed_piece, slot)
		)
		var slot_sb = StyleBoxFlat.new()
		slot_sb.bg_color = Color(0.2, 0.22, 0.28, 1.0)
		slot_sb.corner_radius_top_left = 8
		slot_sb.corner_radius_top_right = 8
		slot_sb.corner_radius_bottom_left = 8
		slot_sb.corner_radius_bottom_right = 8
		slot.add_theme_stylebox_override("panel", slot_sb)
		slot.custom_minimum_size = Vector2(70, 70)
		slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		slot.set_meta("item_id", "")
		slot.mouse_entered.connect(func():
			var i_id = slot.get_meta("item_id")
			if i_id != "":
				main.show_custom_tooltip(ItemManager.get_item_description(i_id))
		)
		slot.mouse_exited.connect(func():
			main.hide_custom_tooltip()
		)
		slot.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				var i_id = slot.get_meta("item_id")
				if i_id == "bottle" and main.selected_piece:
					main.start_bottle_targeting(main.selected_piece, slot)
				elif i_id == "dark_mirror" and main.selected_piece:
					if not main.mirror_used_this_level:
						main.start_dark_mirror_targeting(main.selected_piece, slot)
				elif i_id == "hand" and main.selected_piece:
					if not main.selected_piece.has_meta("hand_used_this_turn") or not main.selected_piece.get_meta("hand_used_this_turn"):
						main.start_hand_targeting(main.selected_piece, slot)
				elif i_id == "blood_knife" and main.selected_piece:
					if not main.selected_piece.has_meta("blood_knife_used_this_turn") or not main.selected_piece.get_meta("blood_knife_used_this_turn"):
						main.start_blood_knife_targeting(main.selected_piece, slot)
				elif i_id == "torch" and main.selected_piece:
					if not main.selected_piece.has_meta("torch_used_this_turn") or not main.selected_piece.get_meta("torch_used_this_turn"):
						main.start_torch_targeting(main.selected_piece, slot)
		)
		var tex = TextureRect.new()
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.add_child(tex)
		main.info_item_slots.add_child(slot)
	info_vbox.add_child(main.info_item_slots)
	
	main.info_desc.text = ""
	main.info_panel.call_deferred("hide")
	main.status_label = Label.new()
	main.status_label.text = "Player Turn 1"
	main.status_label.set("theme_override_colors/font_color", Color.WHITE)
	main.status_label.set("theme_override_font_sizes/font_size", 28)
	# Status label will be added to right_vbox
	
	var hud_panel = PanelContainer.new()
	var hud_style = StyleBoxFlat.new()
	hud_style.bg_color = Color(0.1, 0.12, 0.15, 0.85)
	hud_style.corner_radius_bottom_right = 20
	hud_style.border_width_right = 2
	hud_style.border_width_bottom = 2
	hud_style.border_color = Color(0.3, 0.35, 0.4)
	hud_panel.add_theme_stylebox_override("panel", hud_style)
	hud_panel.position = Vector2(0, 0)
	hud_panel.z_index = 250
	main.ui_layer.add_child(hud_panel)
	
	var hud_margin = MarginContainer.new()
	hud_margin.add_theme_constant_override("margin_left", 20)
	hud_margin.add_theme_constant_override("margin_right", 20)
	hud_margin.add_theme_constant_override("margin_top", 10)
	hud_margin.add_theme_constant_override("margin_bottom", 10)
	hud_panel.add_child(hud_margin)
	
	var hud_hbox = HBoxContainer.new()
	hud_hbox.add_theme_constant_override("separation", 20)
	hud_margin.add_child(hud_hbox)
	
	var pause_btn = Button.new()
	pause_btn.text = "Pause"
	pause_btn.set("theme_override_font_sizes/font_size", 24)
	pause_btn.custom_minimum_size = Vector2(120, 50)
	pause_btn.pressed.connect(func(): main.toggle_pause_menu())
	hud_hbox.add_child(pause_btn)
	
	var right_hud_panel = PanelContainer.new()
	var right_style = StyleBoxFlat.new()
	right_style.bg_color = Color(0.1, 0.12, 0.15, 0.85)
	right_style.corner_radius_bottom_left = 20
	right_style.border_width_left = 2
	right_style.border_width_bottom = 2
	right_style.border_color = Color(0.3, 0.35, 0.4)
	right_hud_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	right_hud_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	right_hud_panel.custom_minimum_size = Vector2(350, 0)
	right_hud_panel.z_index = 250
	main.ui_layer.add_child(right_hud_panel)
	
	var right_margin = MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 20)
	right_margin.add_theme_constant_override("margin_right", 20)
	right_margin.add_theme_constant_override("margin_top", 10)
	right_margin.add_theme_constant_override("margin_bottom", 10)
	right_hud_panel.add_child(right_margin)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 15)
	right_margin.add_child(right_vbox)
	
	right_vbox.add_child(main.status_label)
	
	main.timer_label = Label.new()
	main.timer_label.text = "Time: 00:00"
	main.timer_label.set("theme_override_font_sizes/font_size", 28)
	right_vbox.add_child(main.timer_label)
	
	main.room_label = Label.new()
	main.room_label.text = "Room: 1"
	main.room_label.set("theme_override_font_sizes/font_size", 28)
	right_vbox.add_child(main.room_label)
	
	main.coins_label = Label.new()
	main.coins_label.text = "Coins: 0"
	main.coins_label.set("theme_override_colors/font_color", Color(1, 0.8, 0))
	main.coins_label.set("theme_override_font_sizes/font_size", 28)
	right_vbox.add_child(main.coins_label)
	
	var hud_inv_btn = Button.new()
	hud_inv_btn.text = "Inventory"
	hud_inv_btn.set("theme_override_font_sizes/font_size", 24)
	hud_inv_btn.pressed.connect(func(): main.toggle_inventory())
	right_vbox.add_child(hud_inv_btn)
	

	
	main.game_over_panel = ColorRect.new()
	main.game_over_panel.color = Color(0, 0, 0, 0.8)
	main.game_over_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.game_over_panel.z_index = 300
	main.game_over_panel.hide()
	main.ui_layer.add_child(main.game_over_panel)
	
	var go_vbox = VBoxContainer.new()
	go_vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	go_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	go_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	go_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	go_vbox.add_theme_constant_override("separation", 50)
	main.game_over_panel.add_child(go_vbox)
	
	main.game_over_label = Label.new()
	main.game_over_label.text = "GAME OVER"
	main.game_over_label.set("theme_override_colors/font_color", Color.RED)
	main.game_over_label.set("theme_override_font_sizes/font_size", 120)
	main.game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_vbox.add_child(main.game_over_label)
	
	var go_restart = Button.new()
	go_restart.text = "Restart Game"
	go_restart.set("theme_override_font_sizes/font_size", 40)
	go_restart.custom_minimum_size = Vector2(300, 80)
	go_restart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	go_restart.pressed.connect(func():
		main.get_tree().paused = false
		main.game_over_panel.hide()
		main.start_new_run(main.current_save_slot)
	)
	go_vbox.add_child(go_restart)
	
	main.pause_panel = ColorRect.new()
	main.pause_panel.color = Color(0, 0, 0, 0.8)
	main.pause_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.pause_panel.z_index = 1000
	main.pause_panel.hide()
	main.pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	main.ui_layer.add_child(main.pause_panel)
	
	var pause_center = CenterContainer.new()
	pause_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.pause_panel.add_child(pause_center)
	
	var pause_vbox = VBoxContainer.new()
	pause_vbox.add_theme_constant_override("separation", 20)
	pause_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	pause_center.add_child(pause_vbox)
	
	var pause_title = Label.new()
	pause_title.text = "PAUSED"
	pause_title.set("theme_override_font_sizes/font_size", 80)
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_vbox.add_child(pause_title)
	
	var resume_btn = Button.new()
	resume_btn.text = "Resume"
	resume_btn.set("theme_override_font_sizes/font_size", 40)
	resume_btn.custom_minimum_size = Vector2(300, 80)
	resume_btn.pressed.connect(func(): main.toggle_pause_menu())
	pause_vbox.add_child(resume_btn)
	
	var prestart_btn = Button.new()
	prestart_btn.text = "Restart"
	prestart_btn.set("theme_override_font_sizes/font_size", 40)
	prestart_btn.custom_minimum_size = Vector2(300, 80)
	prestart_btn.pressed.connect(func(): 
		main.get_tree().paused = false
		main.toggle_pause_menu()
		main.start_new_run(main.current_save_slot)
	)
	pause_vbox.add_child(prestart_btn)
	
	var psettings_btn = Button.new()
	psettings_btn.text = "Settings"
	psettings_btn.set("theme_override_font_sizes/font_size", 40)
	psettings_btn.custom_minimum_size = Vector2(300, 80)
	psettings_btn.pressed.connect(func(): main.settings_panel.show())
	pause_vbox.add_child(psettings_btn)
	
	var pquit_btn = Button.new()
	pquit_btn.text = "Main Menu"
	pquit_btn.set("theme_override_font_sizes/font_size", 40)
	pquit_btn.custom_minimum_size = Vector2(300, 80)
	pquit_btn.pressed.connect(func(): 
		main.get_tree().paused = false
		main.toggle_pause_menu()
		main.board_node.hide()
		main.shop_panel.hide()
		main.info_panel.call_deferred("hide")
		main.inv_panel.call_deferred("hide")
		main.graveyard_panel.hide()
		main.open_main_menu()
	)
	pause_vbox.add_child(pquit_btn)
	
	var pexit_btn = Button.new()
	pexit_btn.text = "Quit"
	pexit_btn.set("theme_override_font_sizes/font_size", 40)
	pexit_btn.custom_minimum_size = Vector2(300, 80)
	pexit_btn.pressed.connect(func(): main.get_tree().quit())
	pause_vbox.add_child(pexit_btn)
	
	main.inv_panel = ColorRect.new()
	main.inv_panel.color = Color(0.12, 0.14, 0.18, 1.0)
	main.inv_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.inv_panel.z_index = 150
	main.inv_panel.call_deferred("hide")
	main.inv_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	main.ui_layer.add_child(main.inv_panel)
	
	var inv_top_hbox = HBoxContainer.new()
	inv_top_hbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	inv_top_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main.inv_panel.add_child(inv_top_hbox)
	
	var inv_title = Label.new()
	inv_title.text = "INVENTORY"
	inv_title.set("theme_override_font_sizes/font_size", 60)
	inv_title.set("theme_override_colors/font_color", Color.WHITE)
	inv_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inv_top_hbox.add_child(inv_title)
	
	var inv_top_right = PanelContainer.new()
	var itr_style = StyleBoxFlat.new()
	itr_style.bg_color = Color(0.1, 0.12, 0.15, 0.85)
	itr_style.corner_radius_bottom_left = 20
	itr_style.border_width_left = 2
	itr_style.border_width_bottom = 2
	itr_style.border_color = Color(0.3, 0.35, 0.4)
	inv_top_right.add_theme_stylebox_override("panel", itr_style)
	inv_top_right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	inv_top_right.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	main.inv_panel.add_child(inv_top_right)
	
	# Removed itr_margin and its contents to avoid HUD overlap
	
	var main_hbox = HBoxContainer.new()
	main_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_hbox.offset_top = 160
	main_hbox.offset_bottom = -200
	main_hbox.offset_left = 70
	main_hbox.offset_right = -130
	main_hbox.add_theme_constant_override("separation", 30)
	main_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main.inv_panel.add_child(main_hbox)
	
	var figures_panel = PanelContainer.new()
	figures_panel.custom_minimum_size = Vector2(390, 800)
	figures_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	figures_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var fig_sb = StyleBoxFlat.new()
	fig_sb.bg_color = Color(0.1, 0.12, 0.15, 0.9)
	fig_sb.corner_radius_top_left = 15
	fig_sb.corner_radius_top_right = 15
	fig_sb.corner_radius_bottom_left = 15
	fig_sb.corner_radius_bottom_right = 15
	figures_panel.add_theme_stylebox_override("panel", fig_sb)
	main_hbox.add_child(figures_panel)
	
	var fig_margin = MarginContainer.new()
	fig_margin.add_theme_constant_override("margin_top", 20)
	fig_margin.add_theme_constant_override("margin_bottom", 20)
	fig_margin.add_theme_constant_override("margin_left", 20)
	fig_margin.add_theme_constant_override("margin_right", 20)
	figures_panel.add_child(fig_margin)
	
	var fig_vbox = VBoxContainer.new()
	fig_vbox.add_theme_constant_override("separation", 20)
	fig_margin.add_child(fig_vbox)
	
	var fig_lbl = Label.new()
	fig_lbl.text = "Your Figures"
	fig_lbl.set("theme_override_font_sizes/font_size", 40)
	fig_lbl.set("theme_override_colors/font_color", Color.WHITE)
	fig_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fig_vbox.add_child(fig_lbl)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 500)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	fig_vbox.add_child(scroll)
	
	main.inv_pieces_list = GridContainer.new()
	main.inv_pieces_list.columns = 3
	main.inv_pieces_list.add_theme_constant_override("h_separation", 15)
	main.inv_pieces_list.add_theme_constant_override("v_separation", 15)
	main.inv_pieces_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(main.inv_pieces_list)
	
	var center_wrapper = VBoxContainer.new()
	center_wrapper.custom_minimum_size = Vector2(600, 800)
	center_wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center_wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	center_wrapper.add_theme_constant_override("separation", 40)
	main_hbox.add_child(center_wrapper)
	
	var center_panel = PanelContainer.new()
	var center_sb = StyleBoxFlat.new()
	center_sb.bg_color = Color(0.15, 0.17, 0.22, 1.0)
	center_sb.corner_radius_top_left = 20
	center_sb.corner_radius_top_right = 20
	center_sb.corner_radius_bottom_left = 20
	center_sb.corner_radius_bottom_right = 20
	center_sb.border_width_left = 4
	center_sb.border_width_right = 4
	center_sb.border_width_top = 4
	center_sb.border_width_bottom = 4
	center_sb.border_color = Color(0.3, 0.35, 0.45)
	center_panel.add_theme_stylebox_override("panel", center_sb)
	center_panel.custom_minimum_size = Vector2(600, 800)
	center_wrapper.add_child(center_panel)
	
	var center_vbox = VBoxContainer.new()
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.add_theme_constant_override("separation", 20)
	center_panel.add_child(center_vbox)
	
	main.inv_piece_tex = TextureRect.new()
	main.inv_piece_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	main.inv_piece_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	main.inv_piece_tex.custom_minimum_size = Vector2(200, 200)
	main.inv_piece_tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center_vbox.add_child(main.inv_piece_tex)
	
	main.inv_piece_name = Label.new()
	main.inv_piece_name.set("theme_override_font_sizes/font_size", 42)
	main.inv_piece_name.set("theme_override_colors/font_color", Color.WHITE)
	main.inv_piece_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_vbox.add_child(main.inv_piece_name)
	
	main.inv_piece_desc = Label.new()
	main.inv_piece_desc.set("theme_override_font_sizes/font_size", 20)
	main.inv_piece_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.inv_piece_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.inv_piece_desc.custom_minimum_size = Vector2(500, 80)
	center_vbox.add_child(main.inv_piece_desc)
	
	main.inv_piece_slots = HBoxContainer.new()
	main.inv_piece_slots.add_theme_constant_override("separation", 20)
	main.inv_piece_slots.alignment = BoxContainer.ALIGNMENT_CENTER
	main.inv_piece_slots.custom_minimum_size = Vector2(340, 100)
	center_vbox.add_child(main.inv_piece_slots)
	
	main.inv_piece_stats = Label.new()
	main.inv_piece_stats.set("theme_override_font_sizes/font_size", 36)
	main.inv_piece_stats.set("theme_override_colors/font_color", Color(0.8, 0.8, 0.8))
	main.inv_piece_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_vbox.add_child(main.inv_piece_stats)
	
	main.inv_start_btn = Button.new()
	main.inv_start_btn.text = "Close Inventory"
	main.inv_start_btn.set("theme_override_font_sizes/font_size", 40)
	main.inv_start_btn.set("theme_override_colors/font_color", Color.WHITE)
	main.inv_start_btn.custom_minimum_size = Vector2(350, 80)
	main.inv_start_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main.inv_start_btn.pressed.connect(func():
		main.toggle_inventory()
	)
	center_wrapper.add_child(main.inv_start_btn)
	
	var backpack_panel = PanelContainer.new()
	backpack_panel.custom_minimum_size = Vector2(330, 800)
	backpack_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	backpack_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var bp_sb = StyleBoxFlat.new()
	bp_sb.bg_color = Color(0.1, 0.12, 0.15, 0.9)
	bp_sb.corner_radius_top_left = 15
	bp_sb.corner_radius_top_right = 15
	bp_sb.corner_radius_bottom_left = 15
	bp_sb.corner_radius_bottom_right = 15
	backpack_panel.add_theme_stylebox_override("panel", bp_sb)
	main_hbox.add_child(backpack_panel)
	
	var bp_margin = MarginContainer.new()
	bp_margin.add_theme_constant_override("margin_top", 20)
	bp_margin.add_theme_constant_override("margin_bottom", 20)
	bp_margin.add_theme_constant_override("margin_left", 20)
	bp_margin.add_theme_constant_override("margin_right", 20)
	backpack_panel.add_child(bp_margin)
	
	var bp_vbox = VBoxContainer.new()
	bp_vbox.add_theme_constant_override("separation", 20)
	bp_margin.add_child(bp_vbox)
	
	var pool_lbl = Label.new()
	pool_lbl.text = "Backpack"
	pool_lbl.set("theme_override_font_sizes/font_size", 40)
	pool_lbl.set("theme_override_colors/font_color", Color.WHITE)
	pool_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bp_vbox.add_child(pool_lbl)
	
	var bp_scroll = ScrollContainer.new()
	bp_scroll.custom_minimum_size = Vector2(0, 500)
	bp_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bp_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bp_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	bp_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	bp_vbox.add_child(bp_scroll)
	
	main.inv_pool_grid = GridContainer.new()
	main.inv_pool_grid.columns = 3
	main.inv_pool_grid.add_theme_constant_override("h_separation", 15)
	main.inv_pool_grid.add_theme_constant_override("v_separation", 15)
	main.inv_pool_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bp_scroll.add_child(main.inv_pool_grid)
	
	var quit_box = PanelContainer.new()
	var quit_style = StyleBoxFlat.new()
	quit_style.bg_color = Color(0.1, 0.12, 0.15, 0.85)
	quit_style.corner_radius_bottom_right = 20
	quit_style.border_width_right = 2
	quit_style.border_width_bottom = 2
	quit_style.border_color = Color(0.3, 0.35, 0.4)
	quit_box.add_theme_stylebox_override("panel", quit_style)
	quit_box.position = Vector2(0, 0)
	
	# Pause button removed from here, it's already in hud_hbox
	

	
	main.shop_panel = ColorRect.new()
	main.shop_panel.color = Color(0.15, 0.1, 0.1, 1.0)
	main.shop_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.shop_panel.z_index = 100
	main.ui_layer.add_child(main.shop_panel)
	main.shop_panel.hide()
	
	if main.tex_shop_bg:
		var bg_img = TextureRect.new()
		bg_img.texture = main.tex_shop_bg
		bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg_img.modulate = Color(0.4, 0.4, 0.4, 1.0)
		main.shop_panel.add_child(bg_img)
	
	var main_shop_vbox = VBoxContainer.new()
	main_shop_vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	main_shop_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_shop_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	main_shop_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_shop_vbox.add_theme_constant_override("separation", 80)
	main.shop_panel.add_child(main_shop_vbox)
	
	var title = Label.new()
	title.text = "SHOP"
	title.set("theme_override_colors/font_outline_color", Color.BLACK)
	title.set("theme_override_constants/outline_size", 6)
	title.set("theme_override_font_sizes/font_size", 100)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_shop_vbox.add_child(title)
	
	main.shop_items_container = HBoxContainer.new()
	main.shop_items_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main.shop_items_container.add_theme_constant_override("separation", 30)
	main_shop_vbox.add_child(main.shop_items_container)
	
	var shop_bottom_vbox = VBoxContainer.new()
	shop_bottom_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	shop_bottom_vbox.add_theme_constant_override("separation", 30)
	main_shop_vbox.add_child(shop_bottom_vbox)
	
	var shop_hbox = HBoxContainer.new()
	shop_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	shop_hbox.add_theme_constant_override("separation", 40)
	shop_bottom_vbox.add_child(shop_hbox)
	
	var shop_next_btn = Button.new()
	shop_next_btn.text = "Manage Inventory"
	shop_next_btn.set("theme_override_font_sizes/font_size", 32)
	shop_next_btn.custom_minimum_size = Vector2(300, 80)
	shop_next_btn.pressed.connect(main.toggle_inventory)
	shop_hbox.add_child(shop_next_btn)
	
	var reroll_btn = Button.new()
	reroll_btn.text = "Reroll ($2)"
	reroll_btn.set("theme_override_font_sizes/font_size", 32)
	reroll_btn.custom_minimum_size = Vector2(300, 80)
	reroll_btn.pressed.connect(func(): if main.coins >= 2: main.coins -= 2; main.update_ui(); main.generate_shop())
	shop_hbox.add_child(reroll_btn)
	
	var shop_start_btn = Button.new()
	shop_start_btn.text = "Return to Map"
	shop_start_btn.set("theme_override_font_sizes/font_size", 40)
	shop_start_btn.set("theme_override_colors/font_color", Color.GREEN)
	shop_start_btn.custom_minimum_size = Vector2(400, 80)
	shop_start_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	shop_start_btn.pressed.connect(func():
		main.start_map_mode()
	)
	shop_bottom_vbox.add_child(shop_start_btn)
	

	# --- MAIN MENU UI ---
	main.main_menu_panel = ColorRect.new()
	main.main_menu_panel.color = Color(0.05, 0.05, 0.08, 1.0)
	main.main_menu_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.main_menu_panel.z_index = 1000
	main.ui_layer.add_child(main.main_menu_panel)

	var mm_vbox = VBoxContainer.new()
	mm_vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	mm_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	mm_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	mm_vbox.add_theme_constant_override("separation", 30)
	mm_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main.main_menu_panel.add_child(mm_vbox)

	var mm_title = Label.new()
	mm_title.text = "ChessOdd"
	mm_title.set("theme_override_font_sizes/font_size", 120)
	mm_title.set("theme_override_colors/font_color", Color.WHITE)
	mm_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mm_vbox.add_child(mm_title)

	var btn_play = Button.new()
	btn_play.text = "Play"
	btn_play.add_to_group("translateable")
	btn_play.set("theme_override_font_sizes/font_size", 50)
	btn_play.custom_minimum_size = Vector2(400, 100)
	btn_play.pressed.connect(func(): main.open_save_slots())
	mm_vbox.add_child(btn_play)

	var btn_mm_settings = Button.new()
	btn_mm_settings.text = "Settings"
	btn_mm_settings.add_to_group("translateable")
	btn_mm_settings.set("theme_override_font_sizes/font_size", 50)
	btn_mm_settings.custom_minimum_size = Vector2(400, 100)
	btn_mm_settings.pressed.connect(func(): main.settings_panel.show())
	mm_vbox.add_child(btn_mm_settings)

	var btn_quit = Button.new()
	btn_quit.text = "Quit"
	btn_quit.add_to_group("translateable")
	btn_quit.set("theme_override_font_sizes/font_size", 50)
	btn_quit.custom_minimum_size = Vector2(400, 100)
	btn_quit.pressed.connect(func(): main.get_tree().quit())
	mm_vbox.add_child(btn_quit)

	# --- SAVE SLOTS UI ---
	main.save_slots_panel = ColorRect.new()
	main.save_slots_panel.color = Color(0.1, 0.1, 0.15, 1.0)
	main.save_slots_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.save_slots_panel.z_index = 1010
	main.save_slots_panel.hide()
	main.ui_layer.add_child(main.save_slots_panel)

	var ss_vbox = VBoxContainer.new()
	ss_vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	ss_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ss_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	ss_vbox.add_theme_constant_override("separation", 30)
	ss_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main.save_slots_panel.add_child(ss_vbox)

	var ss_title = Label.new()
	ss_title.text = "Select Save Slot"
	ss_title.set("theme_override_font_sizes/font_size", 80)
	ss_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ss_vbox.add_child(ss_title)

	main.save_slots_container = VBoxContainer.new()
	main.save_slots_container.add_theme_constant_override("separation", 20)
	ss_vbox.add_child(main.save_slots_container)
	
	var ss_back = Button.new()
	ss_back.text = "Back"
	ss_back.set("theme_override_font_sizes/font_size", 40)
	ss_back.pressed.connect(func(): main.save_slots_panel.hide())
	ss_vbox.add_child(ss_back)

	# --- SETTINGS UI ---
	main.settings_panel = SettingsMenu.new(main)
	main.ui_layer.add_child(main.settings_panel)
	

	
	# --- GRAVEYARD UI ---
	main.graveyard_panel = PanelContainer.new()
	main.graveyard_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.graveyard_panel.z_index = 200
	var g_style = StyleBoxFlat.new()
	g_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	g_style.border_width_left = 4
	g_style.border_color = Color(0.3, 0.35, 0.4)
	main.graveyard_panel.add_theme_stylebox_override("panel", g_style)
	main.graveyard_panel.custom_minimum_size = Vector2(0, 0)
	main.graveyard_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.graveyard_panel.show()
	right_vbox.add_child(main.graveyard_panel)
	
	var gy_vbox = VBoxContainer.new()
	gy_vbox.add_theme_constant_override("separation", 20)
	main.graveyard_panel.add_child(gy_vbox)
	
	var enemy_gy_title = Label.new()
	enemy_gy_title.text = "Enemy figures"
	enemy_gy_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_gy_title.set("theme_override_colors/font_color", Color(1.0, 0.5, 0.5))
	enemy_gy_title.set("theme_override_font_sizes/font_size", 20)
	gy_vbox.add_child(enemy_gy_title)
	
	var egy_scroll = ScrollContainer.new()
	egy_scroll.custom_minimum_size = Vector2(0, 140)
	egy_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	egy_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	gy_vbox.add_child(egy_scroll)
	
	main.enemy_graveyard_container = HBoxContainer.new()
	main.enemy_graveyard_container.add_theme_constant_override("separation", -64)
	egy_scroll.add_child(main.enemy_graveyard_container)

	main.lbl_graveyard_title = Label.new()
	main.lbl_graveyard_title.text = "Your figures"
	main.lbl_graveyard_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.lbl_graveyard_title.set("theme_override_colors/font_color", Color(0.5, 0.7, 1.0))
	main.lbl_graveyard_title.set("theme_override_font_sizes/font_size", 20)
	gy_vbox.add_child(main.lbl_graveyard_title)
	
	var gy_scroll = ScrollContainer.new()
	gy_scroll.custom_minimum_size = Vector2(0, 140)
	gy_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	gy_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	gy_vbox.add_child(gy_scroll)
	
	main.graveyard_container = HBoxContainer.new()
	main.graveyard_container.add_theme_constant_override("separation", -64)
	gy_scroll.add_child(main.graveyard_container)

	main.ui_layer.move_child(hud_panel, -1)
	main.ui_layer.move_child(right_hud_panel, -1)
	main.ui_layer.move_child(main.pause_panel, -1)
	
