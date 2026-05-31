class_name ShopManager

var main

func _init(m):
	main = m

func generate_shop():
	for child in main.shop_items_container.get_children():
		main.shop_items_container.remove_child(child)
		child.queue_free()
		
	for i in range(3):
		var pool = [main.PieceType.PAWN, main.PieceType.KNIGHT, main.PieceType.BISHOP, main.PieceType.ROOK, main.PieceType.QUEEN, main.PieceType.TELEPAWN, main.PieceType.CHECKER, main.PieceType.NIGHTMARE_PAWN]
		var type = pool[randi() % pool.size()]
		
		if randf() < 0.5:
			type = main.PieceType.SPIKED_PAWN
			
		var data = PieceData.registry.get(type, PieceData.registry[main.PieceType.PAWN])
		var cost = max(1, data.get("cost", 2) - 1)
		var type_name = TranslationManager.translate(main.PieceType.keys()[type].to_lower())
		var tex = PieceData.get_piece_texture(type, true)
			
		var btn = Button.new()
		btn.text = "%s\n$%d" % [type_name, cost]
		btn.custom_minimum_size = Vector2(160, 200)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.icon = tex
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.expand_icon = true
		btn.pressed.connect(buy_item.bind(type, cost, btn, false))
		btn.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				main.show_item_info(main.PieceType.keys()[type], btn.global_position + Vector2(20,20))
		)
		main.shop_items_container.add_child(btn)
		
	var item_pool = ["knife", "bottle", "boots", "dark_mirror", "hand", "blood_knife", "torch", "finger", "shark_tooth", "hoof", "brain_jar"]
	for i in range(2):
		var item_type = item_pool[randi() % item_pool.size()]
		var btn = Button.new()
		var cost = 3
		if item_type == "dark_mirror": cost = 5
		btn.text = "%s\n$%d" % [TranslationManager.translate(item_type), cost]
		btn.custom_minimum_size = Vector2(160, 200)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		btn.icon = main.get_item_texture(item_type)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.expand_icon = true
		btn.pressed.connect(buy_item.bind(item_type, cost, btn, true))
		btn.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				main.show_item_info(item_type, btn.global_position + Vector2(20,20))
		)
		main.shop_items_container.add_child(btn)

func buy_item(item, cost, btn, is_artifact):
	if main.coins >= cost:
		main.coins -= cost
		main.update_ui()
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5)
		
		if is_artifact:
			main.unassigned_items.append(item)
			main.update_inventory_ui()
			main.show_floating_text(Vector2(2, 4), "Item Bought!", Color.GOLD)
		else:
			var empty_spots = []
			for x in range(main.COLS):
				for y in range(main.ROWS-2, main.ROWS):
					if not main.board.has(Vector2(x, y)):
						empty_spots.append(Vector2(x, y))
			
			if empty_spots.size() > 0:
				empty_spots.shuffle()
				var spot = empty_spots[0]
				var new_pawn = main.spawn_random_piece(true, item)
				new_pawn.grid_pos = spot
				main.board[spot] = new_pawn
				main.player_pawns.append(new_pawn)
				main.board_node.add_child(new_pawn)
				new_pawn.position = spot * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0)
				main.show_floating_text(Vector2(2, 4), "Bought Piece!", Color.GREEN)
				main.overlay.queue_redraw()
			else:
				main.show_floating_text(Vector2(2, 4), "No Room!", Color.RED)
				main.coins += cost
				main.update_ui()
				btn.disabled = false
				btn.modulate = Color.WHITE
	else:
		main.show_floating_text(Vector2(2, 4), "Not enough coins!", Color.RED)
