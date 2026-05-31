extends RefCounted
class_name CombatManager

var main: Node

func _init(m):
	main = m

func take_damage(piece, amt, attacker = null):
	if amt > 0:
		main.shake_board(15.0, 0.25)

	
func perform_action(piece, target_pos):
	var g_pos = piece.grid_pos
	var is_player = piece.is_player
	var atk = piece.attack_damage
	var type = piece.piece_type
	var target_piece = main.board.get(target_pos)
	
	if target_piece:
		if target_piece.piece_type == main.PieceType.CHECKER and target_piece.is_player == piece.is_player:
			if piece.has_meta("is_clone"):
				main.show_floating_text(piece.grid_pos, "SPLAT!", Color.AQUA)
				take_damage(piece, 9999)
				var tween = main.create_tween()
				main.end_turn_with_tween(null, target_pos, tween, piece.is_player)
				return
			
			var count = piece.get_meta("stacked_checker_count") if piece.has_meta("stacked_checker_count") else 0
			count += 1
			piece.set_meta("stacked_checker_count", count)
			piece.attack_damage += 1
			
			main.show_floating_text(target_pos, "+1 RANGE (Checker Stacked)", Color.YELLOW)
			
			main.board.erase(target_pos)
			if target_piece.is_player:
				main.player_pawns.erase(target_piece)
			else:
				main.bot_pawns.erase(target_piece)
			target_piece.queue_free()
			
			var s = piece.get_node_or_null("StackedChecker")
			if not s:
				piece.offset = Vector2(0, -10)
				var checker_sprite = Sprite2D.new()
				checker_sprite.name = "StackedChecker"
				checker_sprite.texture = PieceData.get_piece_texture(main.PieceType.CHECKER, piece.is_player)
				checker_sprite.position = Vector2(0, 15)
				checker_sprite.show_behind_parent = true
				var ts = checker_sprite.texture.get_size() if checker_sprite.texture else Vector2(1,1)
				var sf_checker = min(main.CELL_SIZE_V.x * 0.8 / ts.x, main.CELL_SIZE_V.y * 0.8 / ts.y) * 0.6
				if piece.scale.x > 0 and piece.scale.y > 0:
					checker_sprite.scale = Vector2(sf_checker / piece.scale.x, sf_checker / piece.scale.y)
				piece.add_child(checker_sprite)
				main.update_piece_slots(piece)
				
			main.board.erase(g_pos)
			piece.grid_pos = target_pos
			main.board[target_pos] = piece
			
			var tween = main.create_tween()
			tween.tween_property(piece, "position", target_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.3)
			main.end_turn_with_tween(piece, target_pos, tween)
			return
			
		var was_poop = target_piece.has_meta("is_obstacle") and target_piece.piece_type == main.PieceType.POOP
		
		if piece.has_meta("is_clone") and was_poop:
			main.show_floating_text(piece.grid_pos, "SPLAT!", Color.BROWN)
			take_damage(piece, 9999)
			var tween = main.create_tween()
			main.end_turn_with_tween(null, target_pos, tween, piece.is_player)
			return
			
		take_damage(target_piece, atk, piece)
		
		if is_instance_valid(piece) and piece.artifacts.has("shark_tooth") and is_instance_valid(target_piece) and target_piece.current_hp > 0:
			target_piece.bleed_stacks += 1
			main.show_floating_text(target_pos, "BLEED!", Color.RED)
		
		if is_instance_valid(target_piece) and target_piece.has_spikes:
			take_damage(piece, 1)
			main.show_floating_text(g_pos, "SPIKED!", Color.RED)
			
		var bump_pos = (g_pos * main.CELL_SIZE_V + target_pos * main.CELL_SIZE_V) / 2.0 + (main.CELL_SIZE_V / 2.0)
		var tween = main.create_tween()
		if is_instance_valid(piece):
			tween.tween_property(piece, "position", bump_pos, 0.15)
		
		if not is_instance_valid(target_piece) or target_piece.current_hp <= 0:
			if is_instance_valid(piece) and piece.current_hp > 0:
				if piece.artifacts.has("deadking_head"):
					piece.current_hp += 1
					main.show_floating_text(piece.grid_pos, "+1 HP", Color.GREEN)
					if piece == main.selected_piece: main.update_info_panel(piece.grid_pos)
				
				if not main.board.has(target_pos) or main.board[target_pos] == target_piece:
					main.board.erase(g_pos)
					piece.grid_pos = target_pos
					main.board[target_pos] = piece
					handle_movement_bleed(piece, g_pos, target_pos)
					tween.tween_property(piece, "position", target_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.15)
				else:
					tween.tween_property(piece, "position", g_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.15)
				
				if was_poop and is_player:
					var r = randf()
					if r < 0.75:
						var c = randi_range(1, 3)
						main.coins += c
						main.update_ui()
						main.show_floating_text(target_pos, "+%d Coins" % c, Color(1, 0.8, 0))
					else:
						piece.current_hp += 1
						main.show_floating_text(target_pos, "+1 HP", Color(0.2, 1, 0.2))
					
		else:
			var stop_pos = main.get_cell_before_target(g_pos, target_pos)
			if stop_pos != g_pos and not main.board.has(stop_pos):
				main.board.erase(g_pos)
				piece.grid_pos = stop_pos
				main.board[stop_pos] = piece
				handle_movement_bleed(piece, g_pos, stop_pos)
				var move_px = stop_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0)
				tween.tween_property(piece, "position", move_px, 0.15)
			else:
				tween.tween_property(piece, "position", g_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.15)
				
		if is_instance_valid(piece) and piece.current_hp > 0 and piece.piece_type == main.PieceType.TELEPAWN:
			var empty_spots = []
			for x in range(main.COLS):
				for y in range(main.ROWS):
					var pos2 = Vector2(x, y)
					if not main.board.has(pos2): empty_spots.append(pos2)
			if empty_spots.size() > 0:
				var tp = empty_spots[randi() % empty_spots.size()]
				var old_gp = piece.grid_pos
				main.board.erase(piece.grid_pos)
				piece.grid_pos = tp
				main.board[tp] = piece
				handle_movement_bleed(piece, old_gp, tp)
				tween.tween_property(piece, "position", tp * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.15)
				main.show_floating_text(tp, "TELEPORT!", Color.CYAN)
				main.end_turn_with_tween(piece, tp, tween, is_player)
				return
				
		if is_instance_valid(piece) and piece.current_hp > 0:
			if piece.is_player and piece.artifacts.has("brain_jar") and not piece.get_meta("brain_used_this_turn", false):
				piece.set_meta("brain_used_this_turn", true)
				main.show_floating_text(target_pos, "FREE ACTION!", Color.CYAN)
				# Do NOT end turn!
				main.normal_move_used = false
				main.selected_piece = null
				main.overlay.queue_redraw()
				main.update_ui()
			else:
				main.end_turn_with_tween(piece, target_pos, tween)
		else:
			main.end_turn_with_tween(null, target_pos, tween, is_player)
			
	else:
		main.board.erase(g_pos)
		piece.grid_pos = target_pos
		main.board[target_pos] = piece
		handle_movement_bleed(piece, g_pos, target_pos)
		
		var tween = main.create_tween()
		tween.tween_property(piece, "position", target_pos * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0), 0.3)
		if piece.is_player and piece.artifacts.has("brain_jar") and not piece.get_meta("brain_used_this_turn", false):
			piece.set_meta("brain_used_this_turn", true)
			main.show_floating_text(target_pos, "FREE ACTION!", Color.CYAN)
			main.normal_move_used = false
			main.selected_piece = null
			main.overlay.queue_redraw()
			main.update_ui()
		else:
			main.end_turn_with_tween(piece, target_pos, tween)





func handle_movement_bleed(piece, start_pos, target_pos):
	if not is_instance_valid(piece): return
	var dist = int(max(abs(target_pos.x - start_pos.x), abs(target_pos.y - start_pos.y)))
	if dist == 0: return
	
	var bleed_dmg = min(dist, piece.bleed_stacks)
	if bleed_dmg > 0:
		take_damage(piece, bleed_dmg, null)
		piece.bleed_stacks -= bleed_dmg
		main.show_floating_text(target_pos, "BLEED -%d" % bleed_dmg, Color.RED)
		
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
