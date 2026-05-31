class_name EventManager
extends Node

var main_node

func _init(main):
	main_node = main

# Weighted event selection
const EVENTS = [
	"lose_pawn",      # negative
	"king_hp_up",     # positive
	"gain_pawn",      # positive
	"gain_item",      # positive
	"lose_items",     # negative
]

func trigger_random_event():
	var shuffled = EVENTS.duplicate()
	shuffled.shuffle()
	var event_id = shuffled[0]
	
	# Safety checks
	var non_king_pawns = main_node.player_pawns.filter(
		func(p): return is_instance_valid(p) and p.piece_type != main_node.PieceType.KING
	)
	if event_id == "lose_pawn" and non_king_pawns.is_empty():
		event_id = "lore"
	if event_id == "lose_items":
		var has = false
		for p in main_node.player_pawns:
			if is_instance_valid(p):
				for a in p.artifacts:
					if a != "": has = true
		if not has: event_id = "gain_item"
	
	var result
	match event_id:
		"lose_pawn":   result = event_lose_random_pawn()
		"king_hp_up":  result = event_king_hp_up()
		"gain_pawn":   result = event_gain_random_pawn()
		"gain_item":   result = event_gain_random_item()
		"boss_reveal": result = event_boss_reveal()
		"lore":        result = event_lore()
		"lose_items":  result = event_lose_items()
		_:             result = event_lore()
	
	show_event_ui(result.title, result.desc, result.icons, result.type)

# ── EVENTS ──────────────────────────────────────────────────────────────────

func event_lose_random_pawn() -> Dictionary:
	var non_kings = main_node.player_pawns.filter(
		func(p): return is_instance_valid(p) and p.piece_type != main_node.PieceType.KING
	)
	if non_kings.is_empty(): return event_lore()
	
	var stolen: Node = non_kings[randi() % non_kings.size()]
	var p_name = _get_piece_name(stolen.piece_type)
	var tex = _get_piece_tex(stolen.piece_type)
	
	main_node.player_pawns.erase(stolen)
	if main_node.board.has(stolen.grid_pos): main_node.board.erase(stolen.grid_pos)
	stolen.queue_free()
	
	return {
		"type": "bad",
		"title": "A Sacrifice is Made",
		"desc": "Shadowed hands reach from the void and drag your %s into the darkness.\nIt is gone forever." % p_name,
		"icons": [tex]
	}

func event_king_hp_up() -> Dictionary:
	for p in main_node.player_pawns:
		if is_instance_valid(p) and p.piece_type == main_node.PieceType.KING:
			p.current_hp += 2
			break
	return {
		"type": "good",
		"title": "Royal Blessing",
		"desc": "A golden altar hums with divine energy.\nYour King's maximum HP is permanently increased by +2!",
		"icons": [main_node.tex_heart]
	}

func event_gain_random_pawn() -> Dictionary:
	var pool = [
		main_node.PieceType.PAWN,
		main_node.PieceType.KNIGHT,
		main_node.PieceType.BISHOP,
		main_node.PieceType.ROOK,
		main_node.PieceType.QUEEN,
		main_node.PieceType.TELEPAWN,
		main_node.PieceType.NIGHTMARE_PAWN,
		main_node.PieceType.CHECKER
	]
	var type = pool[randi() % pool.size()]
	var p_name = _get_piece_name(type)
	var tex = _get_piece_tex(type)
	
	# Spawn off-board — will be repositioned in start_next_level
	var new_piece = EnemySpawner.spawn_piece(main_node, 0, 0, true, type)
	new_piece.grid_pos = Vector2(-99, -99)
	new_piece.position = Vector2(-9999, -9999)
	if main_node.board.has(Vector2(0, 0)) and main_node.board[Vector2(0, 0)] == new_piece:
		main_node.board.erase(Vector2(0, 0))
	
	return {
		"type": "good",
		"title": "A New Ally",
		"desc": "A wandering %s has decided to join your cause!\nThey will appear in your next battle." % p_name,
		"icons": [tex]
	}

func event_gain_random_item() -> Dictionary:
	var item_pool = ["knife", "bottle", "boots", "dark_mirror", "hand", "deadking_head", "blood_knife", "torch", "finger", "shark_tooth", "hoof", "brain_jar"]
	var item = item_pool[randi() % item_pool.size()]
	var item_name = ItemManager.get_item_name(item)
	
	# Give item to king or first piece with space
	var given = false
	for p in main_node.player_pawns:
		if not is_instance_valid(p): continue
		while p.artifacts.size() < 3: p.artifacts.append("")
		var has_dark_mirror = p.artifacts[1] == "dark_mirror"
		for i in range(p.artifacts.size()):
			if p.artifacts[i] == "":
				if has_dark_mirror and (i == 0 or i == 2): continue
				p.artifacts[i] = item
				given = true
				break
		if given: break
		
	if not given:
		main_node.unassigned_items.append(item)
	
	main_node.update_ui()
	
	return {
		"type": "good",
		"title": "Ancient Relic Found",
		"desc": "Buried beneath a crumbling stone, you discover: %s!\n%s" % [
			item_name,
			ItemManager.get_item_description(item)
		],
		"icons": [main_node.get_item_texture(item)]
	}

func event_boss_reveal() -> Dictionary:
	var boss_names = ["The Dead King", "The Abyssal Monarch", "The Shattered Crown", "The Pale Overlord"]
	var boss_quotes = [
		"His bones are old. His hatred — eternal.",
		"He who was crowned in shadow shall die in light.",
		"The throne room reeks of blood and forgotten prayers.",
		"Ten floors above you, something ancient stirs."
	]
	var idx = randi() % boss_names.size()
	return {
		"type": "neutral",
		"title": "Ominous Vision",
		"desc": "'%s awaits you at the summit...'\n\n%s" % [boss_names[idx], boss_quotes[idx]],
		"icons": [main_node.tex_deadking_head if main_node.tex_deadking_head else null]
	}

func event_lore() -> Dictionary:
	var entries = [
		{
			"title": "A Soldier's Journal",
			"desc": "Entry 47: The Spiked Pawn blocked the corridor. Every step forward cost us two men. Commanders don't mention this in their reports."
		},
		{
			"title": "Forgotten Inscription",
			"desc": "The Dark Mirror does not show your reflection. It shows the version of you that made different choices. Most people can't bear to look."
		},
		{
			"title": "Traveler's Warning",
			"desc": "The Nightmare Pawn feeds on hesitation. Move quickly. It cannot follow those who commit."
		},
		{
			"title": "Alchemist's Notes",
			"desc": "This bottle was not meant to hold liquid. The residue suggests it once contained something between a scream and a color."
		},
		{
			"title": "Barkeep's Tale",
			"desc": "One night, a man walked in with a checkered shield. He wouldn't sell it. Said it was 'alive.' He left without it the next morning."
		},
		{
			"title": "Ancient Codex",
			"desc": "The Bishop moved in curves, once. Only after the Schism were they restricted to diagonals. Historians disagree on what was lost."
		},
		{
			"title": "Graffiti on the Wall",
			"desc": "Someone scratched 'THE KING HAS NO HP' into the stone. Below it, in different handwriting: 'Not anymore.'"
		},
		{
			"title": "A Child's Drawing",
			"desc": "Crayon lines depict what appears to be a large eye floating above a chessboard. The caption reads 'the thing that watches us play.'"
		},
		{
			"title": "Monster Codex: Evil Eye",
			"desc": "The Evil Eye does not blink. Researchers theorize it cannot. They also theorize it does not need to. It sees everything anyway."
		},
		{
			"title": "Field Report: Knight",
			"desc": "Subject moves in L-shaped bursts. Attempts to predict its destination fail approximately 70% of the time. It seems amused by this."
		},
		{
			"title": "Philosopher's Stone (the note)",
			"desc": "We didn't turn lead to gold. We turned regret to momentum. Same thing, really, if you think about it long enough."
		}
	]
	var e = entries[randi() % entries.size()]
	return {
		"type": "neutral",
		"title": e.title,
		"desc": e.desc,
		"icons": []
	}

func event_lose_items() -> Dictionary:
	var stolen_names = []
	var stolen_texs = []
	var stolen_count = 0
	
	for p in main_node.player_pawns:
		if not is_instance_valid(p): continue
		for i in range(p.artifacts.size()):
			if p.artifacts[i] != "" and stolen_count < 2:
				stolen_names.append(ItemManager.get_item_name(p.artifacts[i]))
				var t = main_node.get_item_texture(p.artifacts[i])
				if t: stolen_texs.append(t)
				p.artifacts[i] = ""
				stolen_count += 1
		if stolen_count >= 2: break
	
	main_node.update_ui()
	
	var desc_str = "You were ambushed in the dark!\nThieves made off with: %s.\nThey vanished before you could react." % ", ".join(stolen_names)
	if stolen_names.is_empty():
		desc_str = "Shadowy hands searched your pack... but found nothing. Lucky."
	
	return {
		"type": "bad",
		"title": "Ambush!",
		"desc": desc_str,
		"icons": stolen_texs
	}

# ── UI ──────────────────────────────────────────────────────────────────────

func show_event_ui(title: String, desc: String, icons: Array, event_type: String):
	var event_panel = ColorRect.new()
	event_panel.color = Color(0, 0, 0, 0.0)
	event_panel.z_index = 2000
	main_node.ui_layer.add_child(event_panel)
	event_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	event_panel.size = Vector2(1920, 1080)
	event_panel.position = Vector2(0, 0)
	
	# Fade in
	var tween_in = event_panel.create_tween()
	tween_in.tween_property(event_panel, "color", Color(0, 0, 0, 0.85), 0.5)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 30)
	vbox.custom_minimum_size = Vector2(900, 0)
	event_panel.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	# Title color based on event type
	var title_color = Color.WHITE
	if event_type == "good": title_color = Color(0.4, 1.0, 0.5)
	elif event_type == "bad": title_color = Color(1.0, 0.35, 0.35)
	elif event_type == "neutral": title_color = Color(0.8, 0.8, 1.0)
	
	var lbl_title = Label.new()
	lbl_title.text = title
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.set("theme_override_font_sizes/font_size", 56)
	lbl_title.set("theme_override_colors/font_color", title_color)
	lbl_title.modulate.a = 0.0
	vbox.add_child(lbl_title)
	
	var tween_title = lbl_title.create_tween()
	tween_title.tween_interval(0.3)
	tween_title.tween_property(lbl_title, "modulate:a", 1.0, 0.4)
	
	# Separator
	var sep = HSeparator.new()
	sep.custom_minimum_size = Vector2(600, 4)
	vbox.add_child(sep)
	
	# Icons row
	if not icons.is_empty():
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 20)
		vbox.add_child(hbox)
		for tex in icons:
			if not tex: continue
			var tex_r = TextureRect.new()
			tex_r.texture = tex
			tex_r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_r.custom_minimum_size = Vector2(120, 120)
			hbox.add_child(tr)
	
	var lbl_desc = Label.new()
	lbl_desc.text = desc
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.set("theme_override_font_sizes/font_size", 28)
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.custom_minimum_size = Vector2(800, 0)
	lbl_desc.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	lbl_desc.modulate.a = 0.0
	vbox.add_child(lbl_desc)
	
	var tween_desc = lbl_desc.create_tween()
	tween_desc.tween_interval(0.5)
	tween_desc.tween_property(lbl_desc, "modulate:a", 1.0, 0.4)
	
	var btn = Button.new()
	btn.text = "Continue"
	btn.custom_minimum_size = Vector2(240, 64)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.set("theme_override_font_sizes/font_size", 28)
	btn.modulate.a = 0.0
	vbox.add_child(btn)
	
	var tween_btn = btn.create_tween()
	tween_btn.tween_interval(0.8)
	tween_btn.tween_property(btn, "modulate:a", 1.0, 0.3)
	
	btn.pressed.connect(func():
		var t_out = event_panel.create_tween()
		t_out.tween_property(event_panel, "color", Color(0, 0, 0, 0.0), 0.3)
		t_out.tween_callback(event_panel.queue_free)
		t_out.tween_callback(main_node.start_map_mode)
	)

# ── HELPERS ─────────────────────────────────────────────────────────────────

func _get_piece_name(type) -> String:
	var data = PieceData.registry.get(type)
	return data.get("title", "Piece") if data else "Piece"

func _get_piece_tex(type) -> Texture2D:
	var tex = PieceData.get_piece_texture(type, true)
	if tex: return tex
	match type:
		main_node.PieceType.PAWN:   return main_node.tex_pawn_player
		main_node.PieceType.KNIGHT: return main_node.tex_knight_player
		main_node.PieceType.BISHOP: return main_node.tex_bishop_player
		main_node.PieceType.ROOK:   return main_node.tex_rook_player
		main_node.PieceType.QUEEN:  return main_node.tex_queen_player
		main_node.PieceType.KING:   return main_node.tex_king_player
	return null
