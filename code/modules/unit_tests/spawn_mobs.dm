///Unit test that spawns all mobs that can be spawned by golden slimes
/datum/unit_test/spawn_mobs

/datum/unit_test/spawn_mobs/Run()
	for(var/T in typesof(/mob/living/simple_animal))
		var/mob/living/simple_animal/animal = T
		if (initial(animal.gold_core_spawnable) == HOSTILE_SPAWN || initial(animal.gold_core_spawnable) == FRIENDLY_SPAWN)
			allocate (T)
