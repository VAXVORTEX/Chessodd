class_name CombatManager

var main: Node

func _init(m: Node):
	main = m

func handle_movement_bleed(piece, start_pos, target_pos):
	if not is_instance_valid(piece): return
	var dist = int(max(abs(target_pos.x - start_pos.x), abs(target_pos.y - start_pos.y)))
	if dist == 0: return
	
	var bleed_dmg = min(dist, piece.bleed_stacks)
	if bleed_dmg > 0:
		main.take_damage(piece, bleed_dmg, null)
		piece.bleed_stacks -= bleed_dmg
		main.vfx_manager.show_floating_text(target_pos, "BLEED -%d" % bleed_dmg, Color.RED)
		
	if piece.bleed_stacks > 0 or bleed_dmg > 0:
		var last_idx = randi() % 3
		for i in range(dist):
			var t = float(i) / float(dist) if dist > 0 else 0.0
			var cell = Vector2(round(lerp(start_pos.x, target_pos.x, t)), round(lerp(start_pos.y, target_pos.y, t)))
			last_idx = (last_idx + randi_range(1, 2)) % 3
			if not main.blood_hazards.has(cell):
				main.blood_hazards[cell] = {"turns": 3, "tex_idx": last_idx}
			else:
				main.blood_hazards[cell].turns = 3

func get_cell_before_target(g_pos: Vector2, target_pos: Vector2) -> Vector2:
	var diff = target_pos - g_pos
	var step = Vector2.ZERO
	if abs(diff.x) > abs(diff.y):
		step = Vector2(sign(diff.x), 0)
	elif abs(diff.y) > abs(diff.x):
		step = Vector2(0, sign(diff.y))
	else:
		step = Vector2(sign(diff.x), sign(diff.y))
	return target_pos - step

func tick_statuses(is_player_turn):
	for p in main.player_pawns + main.bot_pawns:
		if not is_instance_valid(p) or p.current_hp <= 0 or p.has_meta("is_obstacle"): continue
		
		if p.burn_stacks > 0:
			main.take_damage(p, p.burn_stacks, null)
			main.vfx_manager.show_floating_text(p.grid_pos, "BURN -%d" % p.burn_stacks, Color.ORANGE)
			p.burn_stacks -= 1
			if p.burn_stacks < 0: p.burn_stacks = 0
			
		if p.poison_stacks > 0 and p.is_player != is_player_turn:
			main.take_damage(p, p.poison_stacks, null)
			main.vfx_manager.show_floating_text(p.grid_pos, "POISON -%d" % p.poison_stacks, Color.GREEN)
			p.poison_stacks -= 1
			if p.poison_stacks < 0: p.poison_stacks = 0
		
		if p.bleed_stacks > 0:
			main.take_damage(p, 1, null)
			p.bleed_stacks -= 1
			if p.bleed_stacks < 0: p.bleed_stacks = 0
			main.vfx_manager.show_floating_text(p.grid_pos, "BLEED -1", Color.RED)
			
	var to_remove = []
	for pos in main.blood_hazards.keys():
		main.blood_hazards[pos].turns -= 1
		if main.blood_hazards[pos].turns <= 0:
			to_remove.append(pos)
	for pos in to_remove:
		main.blood_hazards.erase(pos)
	main.overlay.queue_redraw()

func check_nightmare_pawns_interaction(moved_piece):
	if not is_instance_valid(moved_piece) or moved_piece.current_hp <= 0: return
	var diagonal_dirs = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
	if moved_piece.piece_type == main.PieceType.NIGHTMARE_PAWN:
		for d in diagonal_dirs:
			var adj_pos = moved_piece.grid_pos + d
			if main.board.has(adj_pos):
				var adj_piece = main.board[adj_pos]
				if is_instance_valid(adj_piece) and adj_piece != moved_piece and not adj_piece.has_meta("is_obstacle"):
					main.vfx_manager.show_floating_text(moved_piece.grid_pos, "NIGHTMARE STRIKE!", Color.DARK_RED)
					main.take_damage(adj_piece, 1, moved_piece)
	else:
		if moved_piece.has_meta("is_obstacle"): return
		for d in diagonal_dirs:
			var adj_pos = moved_piece.grid_pos + d
			if main.board.has(adj_pos):
				var adj_piece = main.board[adj_pos]
				if is_instance_valid(adj_piece) and adj_piece.piece_type == main.PieceType.NIGHTMARE_PAWN:
					main.vfx_manager.show_floating_text(adj_piece.grid_pos, "NIGHTMARE STRIKE!", Color.DARK_RED)
					main.take_damage(moved_piece, 1, adj_piece)
					if not is_instance_valid(moved_piece) or moved_piece.current_hp <= 0:
						break
