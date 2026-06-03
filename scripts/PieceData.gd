class_name PieceData


static var _cache = {}

static func get_texture(path: String) -> Texture2D:
	if path == "": return null
	if _cache.has(path): return _cache[path]
	var tex = load(path)
	if not tex:
		var img = Image.load_from_file(path)
		if img: tex = ImageTexture.create_from_image(img)
	_cache[path] = tex
	return tex

static func get_piece_texture(type: int, is_player: bool) -> Texture2D:
	if not registry.has(type): return null
	var path = registry[type].get("tex_player", "") if is_player else registry[type].get("tex_bot", "")
	if path == "": path = registry[type].get("tex_player", "")
	return get_texture(path)

static var registry = {
	0: {
		"title": "Pawn",
		"desc": "Moves 1 step forward. Attacks diagonally forward.",
		"hp": 1, "atk": 1, "cost": 2, "is_obstacle": false, "is_boss": false,
		"hp_player": 1, "atk_player": 1, "target_val": 10,
		"tex_player": "res://images/pawn.png",
		"tex_bot": "res://images/pawn.png",
		"movement_func": Callable(MovementRules, "get_pawn_moves")
	},
	1: {
		"title": "Horse",
		"desc": "Moves in an 'L' shape. Can jump over other pieces.",
		"hp": 2, "atk": 2, "cost": 3, "is_obstacle": false, "is_boss": false,
		"hp_player": 1, "atk_player": 2, "target_val": 30,
		"tex_player": "res://images/horse.png",
		"tex_bot": "res://images/horse.png",
		"movement_func": Callable(MovementRules, "get_knight_moves")
	},
	2: {
		"title": "Bishop",
		"desc": "Moves diagonally any number of spaces.",
		"hp": 1, "atk": 2, "cost": 3, "is_obstacle": false, "is_boss": false,
		"hp_player": 2, "atk_player": 1, "target_val": 30,
		"tex_player": "res://images/bishop.png",
		"tex_bot": "res://images/bishop.png",
		"movement_func": Callable(MovementRules, "get_bishop_moves")
	},
	6: {
		"title": "Rook",
		"desc": "Moves horizontally or vertically any number of spaces.",
		"hp": 2, "atk": 2, "cost": 4, "is_obstacle": false, "is_boss": false,
		"hp_player": 3, "atk_player": 1, "target_val": 50,
		"tex_player": "res://images/rook.png",
		"tex_bot": "res://images/rook.png",
		"movement_func": Callable(MovementRules, "get_rook_moves")
	},
	7: {
		"title": "Queen",
		"desc": "Moves in any direction any number of spaces.",
		"hp": 2, "atk": 2, "cost": 5, "is_obstacle": false, "is_boss": false,
		"hp_player": 2, "atk_player": 2, "target_val": 90,
		"tex_player": "res://images/queen.png",
		"tex_bot": "res://images/queen.png",
		"movement_func": Callable(MovementRules, "get_queen_moves")
	},
	3: {
		"title": "King",
		"desc": "Moves 1 step in any direction. If King dies, you lose.",
		"hp": 3, "atk": 1, "cost": 0, "is_obstacle": false, "is_boss": false,
		"hp_player": 5, "atk_player": 1, "target_val": 1000,
		"tex_player": "res://images/king.png",
		"tex_bot": "res://images/king.png",
		"movement_func": Callable(MovementRules, "get_king_moves")
	},
	8: {
		"title": "Spiked Pawn",
		"desc": "Melee attackers take 1 damage.",
		"hp": 1, "atk": 1, "cost": 5, "is_obstacle": false, "is_boss": false,
		"tex_player": "res://images/spiked_pawn.svg",
		"tex_bot": "res://images/spiked_pawn.svg",
		"movement_func": Callable(MovementRules, "get_pawn_moves")
	},
	14: {
		"title": "Telepawn",
		"desc": "Moves 1 step orthogonally. Attacks diagonally forward. Teleports randomly after attack.",
		"hp": 1, "atk": 1, "cost": 4, "is_obstacle": false, "is_boss": false,
		"tex_player": "res://images/Telepawn.png",
		"tex_bot": "res://images/Telepawn.png",
		"movement_func": Callable(MovementRules, "get_telepawn_moves")
	},
	9: {
		"title": "Evil Eye",
		"desc": "Targets a player for 1 turn, then fires. Retreats when approached.",
		"hp": 2, "atk": 1, "cost": 0, "is_obstacle": false, "is_boss": false,
		"tex_player": "res://images/monster_eye.png",
		"tex_bot": "res://images/monster_eye.png",
		"movement_func": Callable(MovementRules, "get_eye_moves")
	},
	16: {
		"title": "Checker",
		"desc": "Moves 1 step orthogonally. Can be stacked under another piece for +1 ATK and a 1-hit shield.",
		"hp": 1, "atk": 1, "cost": 3, "is_obstacle": false, "is_boss": false,
		"tex_player": "res://images/checker.png",
		"tex_bot": "res://images/checker.png",
		"movement_func": Callable(MovementRules, "get_checker_moves")
	},
	15: {
		"title": "Nightmare Pawn",
		"desc": "Moves and attacks like a Pawn. Automatically attacks anyone (ally or enemy) standing adjacent to it out of turn.",
		"hp": 2, "atk": 2, "cost": 4, "is_obstacle": false, "is_boss": false,
		"tex_player": "res://images/nightmare_pawn.png",
		"tex_bot": "res://images/nightmare_pawn.png",
		"movement_func": Callable(MovementRules, "get_nightmare_pawn_moves")
	},
	10: {
		"title": "Deadking",
		"desc": "The terrifying Boss. Moves towards you and attacks.",
		"hp": 10, "atk": 1, "cost": 0, "is_obstacle": false, "is_boss": true,
		"tex_player": "res://images/deadking.png",
		"tex_bot": "res://images/deadking.png",
		"movement_func": Callable(MovementRules, "get_empty_moves")
	},
	11: {
		"title": "Deadking Head",
		"desc": "Severed head. Must be killed. Runs away.",
		"hp": 10, "atk": 0, "cost": 0, "is_obstacle": false, "is_boss": true,
		"hp_player": 1, "atk_player": 1, "target_val": 100,
		"tex_player": "res://images/deadking_head.png",
		"tex_bot": "res://images/deadking_head.png",
		"movement_func": Callable(MovementRules, "get_empty_moves")
	},
	12: {
		"title": "Deadking Body",
		"desc": "Thrashing body. Moves randomly horizontally and smashes pieces.",
		"hp": 999, "atk": 2, "cost": 0, "is_obstacle": false, "is_boss": true,
		"hp_player": 1, "atk_player": 1, "target_val": 100,
		"tex_player": "res://images/deadking_body.png",
		"tex_bot": "res://images/deadking_body.png",
		"movement_func": Callable(MovementRules, "get_empty_moves")
	},
	4: {
		"title": "Rock",
		"desc": "An indestructible obstacle.",
		"hp": 999, "atk": 0, "cost": 0, "is_obstacle": true, "is_boss": false,
		"tex_player": "res://images/rock.svg",
		"tex_bot": "res://images/rock.svg",
		"movement_func": Callable(MovementRules, "get_empty_moves")
	},
	5: {
		"title": "Poop",
		"desc": "Just a piece of poop. Blocks path. Might contain coins or hearts when destroyed.",
		"hp": 1, "atk": 0, "cost": 0, "is_obstacle": true, "is_boss": false,
		"tex_player": "res://images/poop.svg",
		"tex_bot": "res://images/poop.svg",
		"movement_func": Callable(MovementRules, "get_empty_moves")
	},
		17: {
		"title": "Blood Queen",
		"desc": "Heals +1 HP when attacking. Heals +2 HP if target is bleeding.",
		"hp": 2, "atk": 2, "cost": 6, "is_obstacle": false, "is_boss": false,
		"hp_player": 2, "atk_player": 2, "target_val": 100,
		"tex_player": "res://images/bloody_queen.png",
		"tex_bot": "res://images/bloody_queen.png",
		"movement_func": Callable(MovementRules, "get_queen_moves")
	},
	13: {
		"title": "Bomb Barrel",
		"desc": "Explosive barrel. Detonates when attacked, dealing 2 damage in a 3x3 area.",
		"hp": 1, "atk": 0, "cost": 0, "is_obstacle": true, "is_boss": false,
		"hp_player": 1, "atk_player": 0, "target_val": 10,
		"tex_player": "res://images/bomb_barrel.png",
		"tex_bot": "res://images/bomb_barrel.png",
		"movement_func": Callable(MovementRules, "get_empty_moves")
	},
	18: {
		"title": "Tick",
		"desc": "Moves 1 cell orthogonally. Applies 1 Poison and -1 ATK for 1 turn on hit.",
		"hp": 1, "atk": 0, "cost": 3, "is_obstacle": false, "is_boss": false,
		"hp_player": 1, "atk_player": 0, "target_val": 20,
		"tex_player": "res://images/tick.png",
		"tex_bot": "res://images/tick.png",
		"movement_func": Callable(MovementRules, "get_checker_moves")
	},
	19: {
		"title": "Figurecatcher",
		"desc": "Moves 1 cell in any direction. After killing, becomes inactive for 2 enemy turns.",
		"hp": 2, "atk": 2, "cost": 5, "is_obstacle": false, "is_boss": false,
		"hp_player": 2, "atk_player": 2, "target_val": 40,
		"tex_player": "res://images/figurecatcher.png",
		"tex_bot": "res://images/figurecatcher.png",
		"movement_func": Callable(MovementRules, "get_king_moves")
	},
	20: {
		"title": "Bear",
		"desc": "ALWAYS jumps exactly 2 cells orthogonally.",
		"hp": 4, "atk": 2, "cost": 5, "is_obstacle": false, "is_boss": false,
		"hp_player": 4, "atk_player": 2, "target_val": 50,
		"tex_player": "res://images/bear.png",
		"tex_bot": "res://images/bear.png",
		"movement_func": Callable(MovementRules, "get_bear_moves")
	},
	21: {
		"title": "Fungus",
		"desc": "Immobile. Spawns a Spore 1 cell in front every 2 turns.",
		"hp": 2, "atk": 0, "cost": 0, "is_obstacle": true, "is_boss": false,
		"hp_player": 2, "atk_player": 0, "target_val": 15,
		"tex_player": "res://images/fungus.png",
		"tex_bot": "res://images/fungus.png",
		"movement_func": Callable(MovementRules, "get_empty_moves")
	},
	22: {
		"title": "Spore",
		"desc": "Flies downwards. Decays 1 HP/turn. Breaks & poisons on collision/hit.",
		"hp": 5, "atk": 0, "cost": 0, "is_obstacle": true, "is_boss": false,
		"hp_player": 5, "atk_player": 0, "target_val": 5,
		"tex_player": "res://images/spore.png",
		"tex_bot": "res://images/spore.png",
		"movement_func": Callable(MovementRules, "get_spore_moves")
	},
	23: {
		"title": "Wolf",
		"desc": "Moves in an 'L' shape.",
		"hp": 2, "atk": 1, "cost": 4, "is_obstacle": false, "is_boss": false,
		"hp_player": 2, "atk_player": 1, "target_val": 30,
		"tex_player": "res://images/wolf.png",
		"tex_bot": "res://images/wolf.png",
		"movement_func": Callable(MovementRules, "get_knight_moves")
	}
}
