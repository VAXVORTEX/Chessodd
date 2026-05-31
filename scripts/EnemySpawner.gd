class_name EnemySpawner

static func spawn_piece(main: Node, x: int, y: int, is_player: bool, type: int = 0) -> Node:
	var data = PieceData.registry.get(type, PieceData.registry[main.PieceType.PAWN])
	var tex = PieceData.get_piece_texture(type, is_player)
	
	var max_hp = data.get("hp", 1)
	var atk = data.get("atk", 1)
	if is_player:
		max_hp = data.get("hp_player", max_hp)
		atk = data.get("atk_player", atk)
		
	var is_boss = data.get("is_boss", false)
	var has_spikes = (type == main.PieceType.SPIKED_PAWN)
	
	var p = load("res://scripts/Entity.gd").new()
	p.texture = tex
	var ts = Vector2(1, 1)
	if tex != null: ts = tex.get_size()
	if ts.x == 0: ts = Vector2(1, 1)
	var sf = min(main.CELL_SIZE_V.x * 0.8 / ts.x, main.CELL_SIZE_V.y * 0.8 / ts.y)
	if type == main.PieceType.BOMB_BARREL:
		sf = min(main.CELL_SIZE_V.x * 1.3 / ts.x, main.CELL_SIZE_V.y * 1.3 / ts.y)
	p.scale = Vector2(sf, sf)
	p.is_player = is_player
	if not is_player and type == main.PieceType.PAWN:
		p.modulate = Color(0, 0, 0)
	p.current_hp = max_hp
	p.max_hp = max_hp
	p.grid_pos = Vector2(x, y)
	p.piece_type = type
	p.attack_damage = atk
	p.has_spikes = has_spikes
	p.set_meta("is_boss", is_boss)
	if data.get("is_obstacle", false): p.set_meta("is_obstacle", true)
	if type == main.PieceType.BOSS_HEAD: p.set_meta("is_head", true)
	if type == main.PieceType.BOSS_BODY: p.set_meta("is_body", true)
	
	p.artifacts = []
	p.bottle_used_this_level = false
	
	p.position = Vector2(x, y) * main.CELL_SIZE_V + (main.CELL_SIZE_V / 2.0)
	
	# Add Drop Shadow
	var shadow = Sprite2D.new()
	shadow.name = "DropShadow"
	# We use the piece's own texture and color it black with low alpha
	shadow.texture = tex
	shadow.modulate = Color(0, 0, 0, 0.5)
	# Offset it slightly down and right
	var obstacle = (data.get("is_obstacle", false) or type == main.PieceType.POOP)
	if obstacle:
		shadow.position = Vector2(4, 5)
	else:
		shadow.position = Vector2(10, 15)
	shadow.z_index = -1 # Draw behind the piece
	p.add_child(shadow)
	
	main.board_node.add_child(p)
	main.board[Vector2(x, y)] = p
		
	if is_player: main.player_pawns.append(p)
	else: main.bot_pawns.append(p)
	return p

static func generate_level(main: Node, level: int):
	# This function will be called from Main.gd's generate_level
	pass
