extends Entity
class_name BossEntity

signal phase_changed(new_phase)
signal telegraph_started(intent_data)

var current_phase: int = 1
var is_telegraphing: bool = false
var next_move_intent: Dictionary = {}

func take_damage(amount: int, is_piercing: bool = false):
	var dmg_taken = super.take_damage(amount, is_piercing)
	
	if current_hp > 0 and current_hp <= (max_hp / 2) and current_phase == 1:
		trigger_phase_two()
		
	return dmg_taken

func trigger_phase_two():
	current_phase = 2
	phase_changed.emit(2)
	# Here you can implement logic to immediately spawn minions or heal

func calculate_move(game_manager, board_manager, player_pawns):
	pass # To be overridden by specific bosses

func telegraph_move(intent: Dictionary):
	is_telegraphing = true
	next_move_intent = intent
	telegraph_started.emit(intent)

func execute_move():
	is_telegraphing = false
	var intent = next_move_intent
	next_move_intent = {}
	return intent

func spawn_minions(board_manager, minion_types: Array, count: int):
	# Boilerplate for boss spawning enemies
	pass
