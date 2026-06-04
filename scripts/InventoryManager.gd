class_name InventoryManager

var main: Node

func _init(m: Node):
	main = m

func toggle_inventory():
	main.info_panel.hide()
	var right_hud = main.ui_layer.get_node_or_null("RightHUDPanel")
	if main.inv_panel.visible:
		main.inv_panel.hide()
		main.update_ui()
		if right_hud: right_hud.show()
		if main.state == main.GameState.SHOP:
			main.shop_panel.show()
	else:
		refresh_player_pawns()
		if main.graveyard_panel: main.graveyard_panel.hide()
		if right_hud: right_hud.hide()
		if main.player_pawns.size() > 0:
			if main.current_view_index >= main.player_pawns.size():
				main.current_view_index = 0
			if main.state == main.GameState.SHOP:
				main.shop_panel.hide()
			main.inv_panel.show()
			update_inventory_screen()

func refresh_player_pawns():
	var valid_pawns = []
	for p in main.player_pawns:
		if is_instance_valid(p) and p.current_hp > 0:
			valid_pawns.append(p)
	main.player_pawns = valid_pawns

func shift_view_index(dir):
	if main.player_pawns.size() == 0: return
	main.current_view_index = (main.current_view_index + dir) % main.player_pawns.size()
	if main.current_view_index < 0:
		main.current_view_index = main.player_pawns.size() - 1
	update_inventory_screen()

func get_base_stats(type):
	var data = PieceData.registry.get(type)
	if data: return {"hp": data.get("hp", 1), "atk": data.get("atk", 1)}
	return {"hp": 1, "atk": 1}

func recalc_pawn_stats(p):
	var base = get_base_stats(p.piece_type)
	p.attack_damage = base.atk
	if p.has_meta("stacked_checker_count"):
		p.attack_damage += p.get_meta("stacked_checker_count")
	for a in p.artifacts:
		if a == "knife":
			p.attack_damage += 1
		elif a == "hoof" and p.piece_type == main.PieceType.KNIGHT:
			p.attack_damage += 1

func swap_items(src_type, src_idx, dst_type, dst_idx):
	if main.player_pawns.size() == 0: return
	var p = main.player_pawns[main.current_view_index]
	
	while p.artifacts.size() < 3:
		p.artifacts.append("")
	var arts = p.artifacts
	
	var get_item = func(typ, idx):
		if typ == "piece":
			return arts[idx]
		else:
			return main.unassigned_items[idx] if idx < main.unassigned_items.size() else ""
	
	var set_item = func(typ, idx, item_id):
		if typ == "piece":
			arts[idx] = item_id
		else:
			if item_id == "":
				if idx < main.unassigned_items.size(): main.unassigned_items.remove_at(idx)
			else:
				if idx < main.unassigned_items.size():
					main.unassigned_items[idx] = item_id
				else:
					main.unassigned_items.append(item_id)
	
	var item_src = get_item.call(src_type, src_idx)
	var item_dst = get_item.call(dst_type, dst_idx)
	
	if item_src == "": return
	
	if p.piece_type == main.PieceType.CHECKER:
		main.vfx_manager.show_floating_text(p.grid_pos if is_instance_valid(p) else Vector2.ZERO, "CANNOT EQUIP ON CHECKER!", Color.RED)
		return
		
	if dst_type == "piece" and (dst_idx == 0 or dst_idx == 2) and arts[1] == "dark_mirror":
		main.vfx_manager.show_floating_text(p.grid_pos if is_instance_valid(p) else Vector2.ZERO, "SLOT LOCKED!", Color.RED)
		return
		
	if item_src == "dark_mirror" and dst_type == "piece":
		for i in range(3):
			if arts[i] != "":
				main.unassigned_items.append(arts[i])
				arts[i] = ""
		arts[1] = "dark_mirror"
		if src_type == "pool":
			main.unassigned_items.remove_at(src_idx)
		recalc_pawn_stats(p)
		main.update_piece_slots(p)
		update_inventory_screen()
		return
	
	set_item.call(src_type, src_idx, item_dst)
	set_item.call(dst_type, dst_idx, item_src)
	
	while arts.size() > 3:
		var removed = arts.pop_back()
		if removed != "":
			main.unassigned_items.append(removed)
	
	recalc_pawn_stats(p)
	main.update_piece_slots(p)
	update_inventory_screen()

func on_item_dropped(src_slot: DragSlot, dst_slot: DragSlot):
	swap_items(src_slot.slot_type, src_slot.slot_index, dst_slot.slot_type, dst_slot.slot_index)

func get_item_texture(item_id: String):
	match item_id:
		"knife": return main.tex_knife
		"bottle": return main.tex_bottle
		"boots": return main.tex_boots
		"deadking_head": return main.tex_deadking_head
		"dark_mirror": return main.tex_dark_mirror
		"hand": return main.tex_hand
		"blood_knife": return main.tex_blood_knife
		"torch": return main.tex_torch
		"finger": return main.tex_finger
		"shark_tooth": return main.tex_shark_tooth
		"hoof": return main.tex_hoof
		"brain_jar": return main.tex_brain_jar
	return null

func show_custom_tooltip(text: String):
	main.item_tooltip_lbl.text = text
	main.item_tooltip.show()

func hide_custom_tooltip():
	main.item_tooltip.hide()

func show_item_info(item_id: String, pos: Vector2):
	if item_id == "": return
	main.info_panel.show()
	main.info_panel.position = pos
	main.info_name.text = item_id.capitalize()
	main.info_stats.text = ""
	main.info_desc.text = ItemManager.get_item_description(item_id)

func get_piece_name(type):
	var data = PieceData.registry.get(type)
	if data: return data.get("title", "Unknown")
	return "Unknown"

func update_inventory_screen():
	main.inv_start_btn.visible = true
	
	for c in main.inv_pieces_list.get_children():
		c.queue_free()
		
	var type_counts = {}
	for p in main.player_pawns: type_counts[p.piece_type] = type_counts.get(p.piece_type, 0) + 1
	var type_indices = {}
	
	for i in range(main.player_pawns.size()):
		var p = main.player_pawns[i]
		var t = p.piece_type
		type_indices[t] = type_indices.get(t, 0) + 1
		
		var panel = PanelContainer.new()
		var p_sb = StyleBoxFlat.new()
		var is_benched = p.get_meta("is_benched", false)
		p_sb.bg_color = Color(1.0, 0.2, 0.2, 0.8) if is_benched else Color(0.2, 1.0, 0.2, 0.8)
		p_sb.corner_radius_top_left = 10
		p_sb.corner_radius_top_right = 10
		p_sb.corner_radius_bottom_left = 10
		p_sb.corner_radius_bottom_right = 10
		panel.add_theme_stylebox_override("panel", p_sb)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var tbtn = TextureButton.new()
		tbtn.texture_normal = p.texture
		tbtn.ignore_texture_size = true
		tbtn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		tbtn.custom_minimum_size = Vector2(100, 100)
		tbtn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
		var shad1 = TextureRect.new()
		shad1.texture = p.texture
		shad1.modulate = Color(0, 0, 0, 0.5)
		shad1.position = Vector2(3, 3)
		shad1.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shad1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		shad1.show_behind_parent = true
		tbtn.add_child(shad1)
		var p_idx = i
		tbtn.pressed.connect(func():
			main.current_view_index = p_idx
			update_inventory_selection()
		)
		vbox.add_child(tbtn)
		
		var lbl = Label.new()
		var n = get_piece_name(t)
		if type_counts[t] > 1: n += " " + str(type_indices[t])
		lbl.text = n
		lbl.set("theme_override_font_sizes/font_size", 20)
		lbl.set("theme_override_colors/font_color", Color.BLACK)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl)
		
		panel.add_child(vbox)
		main.inv_pieces_list.add_child(panel)
		
	if main.player_pawns.size() > 0:
		if main.current_view_index >= main.player_pawns.size(): main.current_view_index = 0
		update_inventory_selection()
	else:
		main.inv_piece_tex.texture = null
		main.inv_piece_name.text = ""
		main.inv_piece_desc.text = ""
		main.inv_piece_stats.text = ""
		for c in main.inv_piece_slots.get_children(): c.queue_free()
			
	for c in main.inv_pool_grid.get_children():
		c.queue_free()
		
	for i in range(max(24, main.unassigned_items.size() + 5)):
		var bg = ColorRect.new()
		bg.custom_minimum_size = Vector2(80, 80)
		bg.color = Color(0.15, 0.15, 0.25, 0.8)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var drag_slot = load("res://scripts/DragSlot.gd").new()
		drag_slot.slot_type = "pool"
		drag_slot.slot_index = i
		drag_slot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		drag_slot.custom_minimum_size = Vector2(80, 80)
		drag_slot.mouse_filter = Control.MOUSE_FILTER_STOP
		
		if i < main.unassigned_items.size():
			drag_slot.item_id = main.unassigned_items[i]
			drag_slot.texture = get_item_texture(drag_slot.item_id)
			
		bg.add_child(drag_slot)
		main.inv_pool_grid.add_child(bg)


func update_inventory_selection():
	if main.player_pawns.is_empty(): return
	var p = main.player_pawns[main.current_view_index]
	main.inv_piece_tex.texture = p.texture
	if not main.inv_piece_tex.has_node("Shadow"):
		var shad2 = TextureRect.new()
		shad2.name = "Shadow"
		shad2.modulate = Color(0, 0, 0, 0.5)
		shad2.position = Vector2(8, 8)
		shad2.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shad2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		shad2.show_behind_parent = true
		main.inv_piece_tex.add_child(shad2)
	main.inv_piece_tex.get_node("Shadow").texture = p.texture
	
	var type_counts = {}
	for cp in main.player_pawns: type_counts[cp.piece_type] = type_counts.get(cp.piece_type, 0) + 1
	var idx = 1
	for j in range(main.current_view_index):
		if main.player_pawns[j].piece_type == p.piece_type: idx += 1
		
	var n = get_piece_name(p.piece_type)
	if type_counts[p.piece_type] > 1: n += " " + str(idx)
	main.inv_piece_name.text = n

	
	var desc = ""
	match p.piece_type:
		main.PieceType.PAWN: desc = "Moves 1 step forward. Attacks diagonally forward."
		main.PieceType.KNIGHT: desc = "Moves in an 'L' shape. Can jump over other pieces."
		main.PieceType.BISHOP: desc = "Moves diagonally any number of spaces."
		main.PieceType.ROOK: desc = "Moves horizontally or vertically any number of spaces."
		main.PieceType.QUEEN: desc = "Moves in any direction any number of spaces."
		main.PieceType.KING: desc = "Moves 1 step in any direction. If King dies, you lose."
		main.PieceType.SPIKED_PAWN: desc = "Melee attackers take 1 damage."
		main.PieceType.TELEPAWN: desc = "Moves 1 step horizontally and vertically. Attacks diagonally forward. Teleports randomly after attacking."
	main.inv_piece_desc.text = desc
	
	main.inv_piece_stats.text = "%d HP | ATK: %d" % [p.current_hp, p.attack_damage]
	
	if main.inv_bench_btn:
		var is_benched = p.get_meta("is_benched", false)
		
		# Disconnect old signals
		if main.inv_bench_btn.pressed.get_connections().size() > 0:
			for conn in main.inv_bench_btn.pressed.get_connections():
				main.inv_bench_btn.pressed.disconnect(conn.callable)
				
		if is_benched:
			main.inv_bench_btn.text = "Unselected"
			main.inv_bench_btn.modulate = Color(1.0, 0.3, 0.3)
		else:
			main.inv_bench_btn.text = "Selected"
			main.inv_bench_btn.modulate = Color(0.3, 1.0, 0.3)
			
		main.inv_bench_btn.pressed.connect(func():
			if p.piece_type == main.PieceType.KING: return
			var currently_benched = p.get_meta("is_benched")
			
			if currently_benched:
				var unbenched_count = 0
				for cp in main.player_pawns:
					if not cp.get_meta("is_benched"): unbenched_count += 1
				if unbenched_count >= 15:
					return # Cannot unbench more!
					
			p.set_meta("is_benched", not currently_benched)
			if not currently_benched: p.remove_meta("start_pos")
			update_inventory_screen()
			update_inventory_selection()
		)
	
	for c in main.inv_piece_slots.get_children():
		c.queue_free()
		
	var arts = p.artifacts
	while arts.size() < 3:
		arts.append("")
	var is_mirror = arts[1] == "dark_mirror"
	var is_checker = p.piece_type == main.PieceType.CHECKER
	for i in range(3):
		if is_checker:
			continue
		var bg = ColorRect.new()
		bg.custom_minimum_size = Vector2(100, 100)
		if is_mirror and (i == 0 or i == 2):
			bg.color = Color(0.4, 0.1, 0.1, 0.8)
		else:
			bg.color = Color(0.2, 0.2, 0.2, 0.8)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var drag_slot = load("res://scripts/DragSlot.gd").new()
		drag_slot.slot_type = "piece"
		drag_slot.slot_index = i
		drag_slot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		drag_slot.custom_minimum_size = Vector2(80, 80)
		drag_slot.mouse_filter = Control.MOUSE_FILTER_STOP
		
		drag_slot.item_id = arts[i]
		if is_mirror and (i == 0 or i == 2):
			var lock_lbl = Label.new()
			lock_lbl.text = "LOCKED"
			lock_lbl.set("theme_override_font_sizes/font_size", 16)
			lock_lbl.set("theme_override_colors/font_color", Color(1.0, 0.3, 0.3))
			lock_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			drag_slot.add_child(lock_lbl)
			drag_slot.modulate = Color(0.7, 0.7, 0.7)
			
		bg.add_child(drag_slot)
		main.inv_piece_slots.add_child(bg)
