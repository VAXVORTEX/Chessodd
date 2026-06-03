extends Sprite2D
class_name Entity

signal died(entity)
signal hp_changed(new_hp, max_hp)
signal took_damage(amount)

var max_hp: int = 2
var current_hp: int = 2
var soul_hearts: int = 0
var attack_damage: int = 1
var attack_range: int = 1
var attack_type: String = "melee" # melee, projectile, laser, splash
var cooldown: int = 0
var current_cooldown: int = 0
var level: int = 1

var has_spikes: bool = false
var is_player: bool = false
var piece_type: int = 0 # References PieceType enum from GameManager
var grid_pos: Vector2 = Vector2.ZERO
var artifacts: Array = []
var bottle_used_this_level: bool = false

var bleed_stacks: int = 0
var burn_stacks: int = 0
var is_poisoned: bool = false
var atk_down_turns: int = 0
var stun_turns: int = 0

var tex_bleed = preload("res://images/status_blood.png")
var tex_burn = preload("res://images/status_fire.png")
var tex_poison = preload("res://images/status_poison.png")

func _ready():
	add_to_group("entities")

func take_damage(amount: int, is_piercing: bool = false):
	if artifacts.has("holy_mantle") and not has_meta("mantle_used"):
		set_meta("mantle_used", true)
		return 0 # Damage blocked completely
	
	var remaining_damage = amount
	
	if not is_piercing and soul_hearts > 0:
		if soul_hearts >= remaining_damage:
			soul_hearts -= remaining_damage
			remaining_damage = 0
		else:
			remaining_damage -= soul_hearts
			soul_hearts = 0
			
	if remaining_damage > 0:
		current_hp -= remaining_damage
		
	hp_changed.emit(current_hp, max_hp)
	took_damage.emit(amount)
	
	if current_hp <= 0:
		die()
		
	return remaining_damage

func die():
	died.emit(self)
	queue_free()

func move_to(target_pos: Vector2, tween: Tween, cell_size: int):
	grid_pos = target_pos
	var final_px = target_pos * cell_size + Vector2(cell_size / 2.0, cell_size / 2.0)
	tween.tween_property(self, "position", final_px, 0.15)

func _process(delta):
	queue_redraw()

func _draw():
	if not texture: return
	
	var target_visual_size = 80.0
	var icon_w = target_visual_size / scale.x
	var icon_h = target_visual_size / scale.y
	
	var start_y = -65.0 / scale.y
	
	var active_statuses = []
	if bleed_stacks > 0 and tex_bleed: active_statuses.append({"tex": tex_bleed, "text": str(bleed_stacks), "color": Color.RED})
	if burn_stacks > 0 and tex_burn: active_statuses.append({"tex": tex_burn, "text": str(burn_stacks), "color": Color.ORANGE})
	if is_poisoned and tex_poison: active_statuses.append({"tex": tex_poison, "text": "", "color": Color.GREEN})
	
	var total = active_statuses.size()
	if total == 0: return
	
	var padding_x = 4.0 / scale.x
	var cur_x = (65.0 / scale.x) - icon_w - padding_x
	
	for stat in active_statuses:
		draw_texture_rect(stat.tex, Rect2(cur_x, start_y, icon_w, icon_h), false)
		if stat.text != "":
			var font = ThemeDB.fallback_font
			var font_size = max(1, int(16.0 / scale.y))
			var str_size = font.get_string_size(stat.text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
			var text_x = cur_x + (icon_w - str_size.x) / 2.0
			var text_y = start_y + (icon_h + str_size.y) / 2.0 - (4.0 / scale.y)
			var outline = max(1.0, 2.0 / scale.x)
			
			for ox in [-outline, 0, outline]:
				for oy in [-outline, 0, outline]:
					draw_string(font, Vector2(text_x + ox, text_y + oy), stat.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
			draw_string(font, Vector2(text_x, text_y), stat.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, stat.color)
			
		cur_x -= (icon_w + padding_x)
