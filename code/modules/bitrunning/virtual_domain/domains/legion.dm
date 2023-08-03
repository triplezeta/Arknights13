/datum/map_template/virtual_domain/legion
	name = "Chamber of Echoes"
	cost = BITRUNNER_COST_MEDIUM
	desc = "A chilling realm that houses Legion's necropolis. Those who succumb to it are forever damned."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	filename = "legion.dmm"
	forced_outfit = /datum/outfit/job/miner
	id = "legion"
	reward_points = BITRUNNER_REWARD_MEDIUM
	safehouse_path = /datum/map_template/safehouse/lavaland_boss

/mob/living/simple_animal/hostile/megafauna/legion/virtual_domain
	can_be_cybercop = FALSE
	crusher_loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	loot = list(/obj/structure/closet/crate/secure/bitrunner_loot/encrypted)
	health = 1300
	maxHealth = 1300

// You may be thinking, well, what about those mini-legions? They're not part of the created_atoms list
