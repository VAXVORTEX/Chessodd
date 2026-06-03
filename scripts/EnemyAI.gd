class_name EnemyAI

static func process_bot_turn(main: Node) -> bool:
	main.bot_pawns = main.bot_pawns.filter(func(p): return is_instance_valid(p) and p.current_hp > 0)
	main.player_pawns = main.player_pawns.filter(func(p): return is_instance_valid(p) and p.current_hp > 0)
	
	if main.game_over or main.state != main.GameState.PLAYING: return false
	if main.bot_pawns.is_empty():
		main.end_level()
		return false
		
	var moved = false
	for b in main.bot_pawns:
		if is_instance_valid(b) and b.current_cooldown > 0:
			b.current_cooldown -= 1
		
		# Fungus Spore Spawning Logic
		if is_instance_valid(b) and b.piece_type == 21: # PieceType.FUNGUS
			if not b.has_meta("spore_timer"):
				b.set_meta("spore_timer", 1)
			else:
				var t = b.get_meta("spore_timer")
				if t >= 2:
					var d_y = 1 if not b.is_player else -1
					var p1 = b.grid_pos + Vector2(0, d_y)
					if main.is_inside(p1) and not main.board.has(p1):
						var EnemySpawner = load("res://scripts/EnemySpawner.gd")
						var spore = EnemySpawner.spawn_piece(main, p1.x, p1.y, b.is_player, 22) # SPORE
						if spore:
							main.vfx_manager.show_floating_text(p1, "SPORED!", Color.GREEN)
					b.set_meta("spore_timer", 1)
				else:
					b.set_meta("spore_timer", t + 1)
					
	var player_threats = []
	for p in main.player_pawns:
		if is_instance_valid(p):
			var pmoves = main.get_valid_moves(p)
			for m in pmoves:
				if not player_threats.has(m):
					var threat_target = main.board.get(m)
					if threat_target and not threat_target.is_player:
						player_threats.append(m)
					
	var boss_acted = false
	var boss_head = null
	var boss_body = null
	
	for b in main.bot_pawns:
		if not is_instance_valid(b): continue
		if b.piece_type == main.PieceType.BOSS_HEAD: boss_head = b
		if b.piece_type == main.PieceType.BOSS_BODY: boss_body = b
		
		if b.piece_type == main.PieceType.BOSS_DEADKING:
			boss_acted = true
			if b.current_cooldown > 0:
				continue
			var closest_p = null
			var min_d = 999
			for p in main.player_pawns:
				if is_instance_valid(p):
					var d = abs(p.grid_pos.x - b.grid_pos.x) + abs(p.grid_pos.y - b.grid_pos.y)
					if d < min_d:
						min_d = d
						closest_p = p
			
			var best_target = null
			if closest_p:
				var best_dist = 999
				var dirs = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
				for d in dirs:
					var target_pos = b.grid_pos + d
					if main.is_inside(target_pos) and (not main.board.has(target_pos) or main.board[target_pos].is_player):
						var dist_to_player = abs(closest_p.grid_pos.x - target_pos.x) + abs(closest_p.grid_pos.y - target_pos.y)
						if dist_to_player < best_dist:
							best_dist = dist_to_player
							best_target = target_pos
			
			if best_target != null:
				main.perform_action(b, best_target)
				b.current_cooldown = b.cooldown
			else:
				main.show_floating_text(b.grid_pos, "BLOCKED!", Color.GRAY)
			moved = true

	if boss_body or boss_head:
		boss_acted = true
		var boss_moved = false
		
		if boss_body and boss_body.current_cooldown > 0:
			boss_body = null
		if boss_head and boss_head.current_cooldown > 0:
			boss_head = null
		
		if boss_body:
			var closest_p = null
			var min_d = 999
			for p in main.player_pawns:
				if is_instance_valid(p):
					var d = abs(p.grid_pos.x - boss_body.grid_pos.x) + abs(p.grid_pos.y - boss_body.grid_pos.y)
					if d < min_d:
						min_d = d
						closest_p = p
						
			var body_dirs = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
			var best_dir = null
			var best_t = null
			var body_moved = false
			
			if closest_p:
				var best_dist = 999
				body_dirs.shuffle()
				for d in body_dirs:
					var t = boss_body.grid_pos + d
					if main.is_inside(t):
						var target = main.board.get(t)
						if target and target.has_meta("is_boss"): continue
						var dist_to_player = abs(closest_p.grid_pos.x - t.x) + abs(closest_p.grid_pos.y - t.y)
						# Prefer cells with player to attack them immediately
						if target and target.is_player:
							dist_to_player -= 100
						if dist_to_player < best_dist:
							best_dist = dist_to_player
							best_dir = d
							best_t = t
			
			if best_t:
				var target = main.board.get(best_t)
				var tween = main.create_tween()
				var start_pos = boss_body.grid_pos
				main.board.erase(start_pos)
				boss_body.grid_pos = best_t
				main.board[best_t] = boss_body
				tween.tween_property(boss_body, "position", best_t * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.3)
				
				if target:
					var push_t = best_t + best_dir
					if main.is_inside(push_t) and not main.board.has(push_t):
						target.grid_pos = push_t
						main.board[push_t] = target
						main.take_damage(target, 2)
						if is_instance_valid(target) and target.current_hp > 0:
							tween.parallel().tween_property(target, "position", push_t * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.3)
							tween.parallel().tween_callback(func(): main.check_nightmare_pawns_interaction(target))
					else:
						main.take_damage(target, 2)
					main.show_floating_text(best_t, "SMASH!", Color.RED)
					
				main.end_turn_with_tween(boss_body, best_t, tween, false, boss_head != null)
				boss_body.current_cooldown = boss_body.cooldown
				body_moved = true
				boss_moved = true
				
			if boss_body and not body_moved: main.show_floating_text(boss_body.grid_pos, "STUCK!", Color.GRAY)
		
		if boss_head:
			var head_moved = false
			var best_t = null
			var best_dist = 999
			var best_dir = Vector2.ZERO
			var h_dirs = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
			h_dirs.shuffle()
			for d in h_dirs:
				var t = boss_head.grid_pos + d * 2
				if main.is_inside(t):
					var target = main.board.get(t)
					if target and target.has_meta("is_boss"): continue
					var dist_to_player = 999
					for p in main.player_pawns:
						if is_instance_valid(p):
							var pd = abs(t.x - p.grid_pos.x) + abs(t.y - p.grid_pos.y)
							if pd < dist_to_player: dist_to_player = pd
					if target and target.is_player:
						dist_to_player -= 100
					if dist_to_player < best_dist:
						best_dist = dist_to_player
						best_t = t
						best_dir = d
			
			if best_t:
				var tween = main.create_tween()
				var start_pos = boss_head.grid_pos
				
				# Build the push chain starting from start_pos + best_dir
				var push_chain = []
				var curr = start_pos + best_dir
				while main.is_inside(curr):
					if main.board.has(curr):
						var piece = main.board[curr]
						if piece.has_meta("is_boss") or piece == boss_head:
							break
						push_chain.append(piece)
					else:
						break
					curr += best_dir
				
				main.board.erase(start_pos)
				boss_head.grid_pos = best_t
				
				# Process push chain in REVERSE order (from furthest to closest)
				for j in range(push_chain.size() - 1, -1, -1):
					var piece = push_chain[j]
					if piece.piece_type == main.PieceType.BOMB_BARREL:
						main.take_damage(piece, 1)
						continue
					var p_pos = piece.grid_pos
					var dest_pos = p_pos + best_dir
					
					main.board.erase(p_pos)
					
					main.take_damage(piece, 1)
					
					if is_instance_valid(piece) and piece.current_hp > 0:
						if main.is_inside(dest_pos) and not main.board.has(dest_pos):
							piece.grid_pos = dest_pos
							main.board[dest_pos] = piece
							tween.parallel().tween_property(piece, "position", dest_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.2)
							tween.parallel().tween_callback(func(): main.check_nightmare_pawns_interaction(piece))
						else:
							main.take_damage(piece, 99)
							main.show_floating_text(p_pos, "CRUSHED!", Color.RED)
				
				if not main.board.has(best_t):
					main.board[best_t] = boss_head
				else:
					var placed = false
					for d in [Vector2(-1,0), Vector2(1,0), Vector2(0,-1), Vector2(0,1)]:
						var alt = best_t + d
						if main.is_inside(alt) and not main.board.has(alt):
							boss_head.grid_pos = alt
							main.board[alt] = boss_head
							placed = true
							tween.tween_property(boss_head, "position", alt * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.2)
							break
					if not placed:
						boss_head.queue_free()
						main.bot_pawns.erase(boss_head)
				
				if is_instance_valid(boss_head) and boss_head.current_hp > 0:
					tween.tween_property(boss_head, "position", boss_head.grid_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.3)
				
				main.end_turn_with_tween(boss_head, boss_head.grid_pos if is_instance_valid(boss_head) else best_t, tween)
				boss_head.current_cooldown = boss_head.cooldown
				head_moved = true
				boss_moved = true
			if not head_moved:
				h_dirs = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
				h_dirs.shuffle()
				for d in h_dirs:
					var t = boss_head.grid_pos + d * 2
					if main.is_inside(t) and not main.board.has(t):
						var tween = main.create_tween()
						main.board.erase(boss_head.grid_pos)
						boss_head.grid_pos = t
						main.board[t] = boss_head
						tween.tween_property(boss_head, "position", t * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.3)
						main.end_turn_with_tween(boss_head, t, tween)
						boss_head.current_cooldown = boss_head.cooldown
						head_moved = true
						boss_moved = true
						break
				if not head_moved:
					main.show_floating_text(boss_head.grid_pos, "STUCK!", Color.GRAY)
			
		if boss_moved:
			moved = true
		
	if boss_acted and not moved:
		main.current_turn = 0
		main.turn_count += 1
		main.status_label.text = "Player Turn %d" % main.turn_count
		main.status_label.set("theme_override_colors/font_color", Color.WHITE)
		main.check_win_condition()
		moved = true
					
	var best_bot = null
	var best_move = null
	var best_score = -99999

	var player_king_pos = null
	for p in main.player_pawns:
		if is_instance_valid(p) and p.piece_type == main.PieceType.KING:
			player_king_pos = p.grid_pos
			break

	for bot in main.bot_pawns:
		if not is_instance_valid(bot): continue
		if bot.current_cooldown > 0: continue
		
		var moves = main.get_valid_moves(bot)
		var currently_threatened = player_threats.has(bot.grid_pos)
		
		for m in moves:
			var score = randf_range(0, 1)
			
			var target = main.board.get(m)
			var is_attack = false
			if target and target.is_player:
				is_attack = true
				var data = PieceData.registry.get(target.piece_type)
				var val = data.get("target_val", 20) if data else 20
				score += val
			elif target and target.has_meta("is_obstacle") and target.piece_type == main.PieceType.POOP:
				score += 5
			elif target and target.piece_type == main.PieceType.BOMB_BARREL:
				score -= 30
				
			# Aggressive tracking of the King
			if player_king_pos != null:
				var dist_to_king = abs(m.x - player_king_pos.x) + abs(m.y - player_king_pos.y)
				score += (15.0 - dist_to_king) * 1.5
				
			var moves_into_threat = player_threats.has(m)
			if is_attack:
				# If we are attacking, we are less afraid of dying (aggressive!)
				if moves_into_threat:
					score -= 5
			else:
				if moves_into_threat:
					score -= 15 # Still try to avoid walking into death for no reason
				elif currently_threatened:
					score += 8 # Slight bonus for escaping
					
			# HP-aware: low HP bots play defensively
			var hp_ratio = bot.current_hp * 1.0 / bot.max_hp
			if hp_ratio < 0.4:
				score -= 10
			elif hp_ratio < 0.7:
				if moves_into_threat:
					score -= 10
				score -= 3
			
			# Prefer moving forward and center
			score += 3.0 - abs(m.x - 2) * 0.8
			if m.y > bot.grid_pos.y: score += 3.0
			
			if score > best_score:
				best_score = score
				best_move = m
				best_bot = bot
				
	if best_bot and best_move:
		main.perform_action(best_bot, best_move)
		best_bot.current_cooldown = best_bot.cooldown
		moved = true

	return moved
