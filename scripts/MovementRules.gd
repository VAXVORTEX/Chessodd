class_name MovementRules

static func get_pawn_moves(main, pawn, range_bonus: int) -> Array:
	var valid_moves = []
	var g_pos = pawn.grid_pos
	var is_player = pawn.is_player
	
	for move_dir in [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]:
		for i in range(1, 2 + range_bonus):
			var move_pos = g_pos + move_dir * i
			if main.is_inside(move_pos):
				var cell_has = main.board.has(move_pos)
				if not cell_has or (main.board[move_pos].is_player == is_player and main.board[move_pos].piece_type == main.PieceType.CHECKER):
					valid_moves.append(move_pos)
					if cell_has: break
				else:
					break
			else:
				break
	for diag in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		for i in range(1, 2):
			var atk_pos = g_pos + diag * i
			if not main.is_inside(atk_pos): break
			if main.board.has(atk_pos) and main.can_move_or_attack(atk_pos, is_player):
				var target_piece = main.board[atk_pos]
				if target_piece.piece_type == main.PieceType.CHECKER and target_piece.is_player == is_player:
					break
				valid_moves.append(atk_pos)
				break
	return valid_moves

static func get_telepawn_moves(main, pawn, range_bonus: int) -> Array:
	var valid_moves = []
	var g_pos = pawn.grid_pos
	var is_player = pawn.is_player
	
	for move_dir in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
		for i in range(1, 2 + range_bonus):
			var move_pos = g_pos + move_dir * i
			if main.is_inside(move_pos):
				var cell_has = main.board.has(move_pos)
				if not cell_has or (main.board[move_pos].is_player == is_player and main.board[move_pos].piece_type == main.PieceType.CHECKER):
					valid_moves.append(move_pos)
					if cell_has: break
				else:
					break
			else:
				break
	for diag in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		for i in range(1, 2):
			var atk_pos = g_pos + diag * i
			if not main.is_inside(atk_pos): break
			if main.board.has(atk_pos) and main.can_move_or_attack(atk_pos, is_player):
				var target_piece = main.board[atk_pos]
				if target_piece.piece_type == main.PieceType.CHECKER and target_piece.is_player == is_player:
					break
				valid_moves.append(atk_pos)
				break
	return valid_moves

static func get_checker_moves(main, pawn, _range_bonus: int) -> Array:
	var valid_moves = []
	var dirs = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	for d in dirs:
		var t = pawn.grid_pos + d
		if main.is_inside(t) and main.can_move_or_attack(t, pawn.is_player):
			valid_moves.append(t)
	return valid_moves

static func get_nightmare_pawn_moves(main, pawn, range_bonus: int) -> Array:
	return get_pawn_moves(main, pawn, range_bonus)

static func get_knight_moves(main, pawn, range_bonus: int) -> Array:
	var valid_moves = []
	var jumps = [Vector2(-1, -2), Vector2(1, -2), Vector2(-1, 2), Vector2(1, 2), Vector2(-2, -1), Vector2(2, -1), Vector2(-2, 1), Vector2(2, 1)]
	if range_bonus > 0:
		jumps += [Vector2(-1, -3), Vector2(1, -3), Vector2(-1, 3), Vector2(1, 3), Vector2(-3, -1), Vector2(3, -1), Vector2(-3, 1), Vector2(3, 1)]
	for j in jumps:
		var t = pawn.grid_pos + j
		if main.is_inside(t) and main.can_move_or_attack(t, pawn.is_player): valid_moves.append(t)
	return valid_moves

static func get_bishop_moves(main, pawn, range_bonus: int) -> Array:
	var valid_moves = []
	var dirs = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
	for d in dirs:
		for i in range(1, 3 + range_bonus):
			var t = pawn.grid_pos + d * i
			if not main.is_inside(t): break
			if main.can_move_or_attack(t, pawn.is_player): valid_moves.append(t)
			if main.board.has(t): break
	return valid_moves

static func get_rook_moves(main, pawn, range_bonus: int) -> Array:
	var valid_moves = []
	var dirs = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	for d in dirs:
		for i in range(1, 3 + range_bonus):
			var t = pawn.grid_pos + d * i
			if not main.is_inside(t): break
			if main.can_move_or_attack(t, pawn.is_player): valid_moves.append(t)
			if main.board.has(t): break
	return valid_moves

static func get_queen_moves(main, pawn, range_bonus: int) -> Array:
	var valid_moves = []
	var dirs = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	for d in dirs:
		for i in range(1, 3 + range_bonus):
			var t = pawn.grid_pos + d * i
			if not main.is_inside(t): break
			if main.can_move_or_attack(t, pawn.is_player): valid_moves.append(t)
			if main.board.has(t): break
	return valid_moves

static func get_king_moves(main, pawn, range_bonus: int) -> Array:
	var valid_moves = []
	var dirs = [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	for d in dirs:
		for i in range(1, 2 + range_bonus):
			var t = pawn.grid_pos + d * i
			if not main.is_inside(t): break
			if main.can_move_or_attack(t, pawn.is_player): valid_moves.append(t)
			if main.board.has(t): break
	return valid_moves

static func get_empty_moves(_main, _pawn, _range_bonus: int) -> Array:
	return []


static func get_eye_moves(_main, _pawn, _range_bonus: int) -> Array:
	return []
