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

static func get_bear_moves(piece, is_player):
	var moves = []
	var dirs = [Vector2(0, 2), Vector2(0, -2), Vector2(2, 0), Vector2(-2, 0)]
	var main = piece.get_tree().get_first_node_in_group("main")
	for d in dirs:
		var p = piece.grid_pos + d
		if main and main.is_inside(p):
			moves.append(p)
	return moves

static func get_spore_moves(piece, is_player):
	var moves = []
	var main = piece.get_tree().get_first_node_in_group("main")
	var d_y = 1 if not is_player else -1
	var p1 = piece.grid_pos + Vector2(0, d_y)
	if main and main.is_inside(p1): moves.append(p1)
	if randi() % 2 == 0:
		var p2 = piece.grid_pos + Vector2(1, d_y)
		if main and main.is_inside(p2): moves.append(p2)
	else:
		var p3 = piece.grid_pos + Vector2(-1, d_y)
		if main and main.is_inside(p3): moves.append(p3)
	return moves
