//Foxxy
/mob/living/simple_animal/pet/fox
	name = "fox"
	desc = "It's a fox."
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak = list("Ack-Ack","Ack-Ack-Ack-Ackawoooo","Awoo","Tchoff")
	speak_emote = list("geckers", "barks")
	emote_hear = list("howls.","barks.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	held_state = "fox"
	pet_bonus = TRUE
	pet_bonus_emote = "pants and yaps happily!"

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/pet/fox/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/britevidence/ribbon))
		to_chat(user, "<span class='notice'>You carefully tie the ribbon to [name].</span>")
		qdel(O)
		icon_state = "foxribbon"
		icon_living = "foxribbon"
		icon_dead = "foxribbon_dead"
		return 1
	else
		return ..()

//Captain fox
/mob/living/simple_animal/pet/fox/renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox."
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE


//British Fox
/mob/living/simple_animal/pet/fox/Rose
	name = "Rose"
	desc = "A Red Fox, particularly native to Britain. How did she get here?"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	icon_state = "rose"
	icon_living = "rose"
	icon_dead = "rose_dead"
	can_be_held = TRUE
	held_state = "rose"
