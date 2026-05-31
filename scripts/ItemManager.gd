class_name ItemManager

static func get_item_name(item_id: String) -> String:
	match item_id:
		"knife": return "Knife"
		"bottle": return "Bottle"
		"boots": return "Boots"
		"deadking_head": return "Dead King's Head"
		"dark_mirror": return "Dark Mirror"
		"hand": return "Hand"
		"blood_knife": return "Blood Knife"
		"torch": return "Torch"
		"finger": return "Finger"
		"shark_tooth": return "Shark Tooth"
		"hoof": return "Hoof"
		"brain_jar": return "Brain in a Jar"
	return "Unknown Item"

static func get_item_description(item_id: String) -> String:
	match item_id:
		"knife": return "Knife: +1 attack damage"
		"bottle": return "Bottle: Drink to sacrifice an ally and gain permanent +2 HP and +1 ATK"
		"boots": return "Boots: +1 movement range"
		"deadking_head": return "Dead King's Head: Heal 1 HP when you kill an enemy"
		"dark_mirror": return "Dark Mirror: Active item. Occupies all slots. Spawns an adjacent clone of the selected piece for a double turn. Clone disappears after turn."
		"hand": return "Hand: Active item. Pushes an enemy 1 cell away orthogonally."
		"blood_knife": return "Blood Knife: Active item. Target an enemy up to 3 cells away orthogonally to inflict 3 stacks of Bleeding. Bleeding units take damage when they move and leave blood trails."
		"torch": return "Torch: Active item. Target an enemy up to 3 cells away orthogonally to inflict 2 stacks of Burn. Burning units take damage at the end of every turn."
		"finger": return "Finger: Active item. Target an enemy anywhere to make them attack a random adjacent ally of theirs."
		"shark_tooth": return "Shark Tooth: Passive item. Your attacks inflict 1 stack of Bleeding."
		"hoof": return "Hoof: Passive item. You can move and attack like a Knight. If you are already a Knight, gain +1 attack range and +1 ATK."
		"brain_jar": return "Brain in a Jar: Passive item. Grants this piece a free action every turn."
	return "Unknown item"
