/var/list/sacrificed = list()
var/list/non_revealed_runes = (subtypesof(/obj/effect/rune) - /obj/effect/rune/malformed)

/*

This file contains runes.
Runes are used by the cult to cause many different effects and are paramount to their success.
They are drawn with an arcane tome in blood, and are distinguishable to cultists and normal crew by examining.
Fake runes can be drawn in crayon to fool people.
Runes can either be invoked by one's self or with many different cultists. Each rune has a specific incantation that the cultists will say when invoking it.

To draw a rune, use an arcane tome.

*/

/obj/effect/rune
	name = "rune"
	var/cultist_name = "basic rune"
	desc = "An odd collection of symbols drawn in what seems to be blood."
	var/cultist_desc = "A basic rune with no function." //This is shown to cultists who examine the rune in order to determine its true purpose.
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = TURF_LAYER + 0.08
	color = rgb(255,0,0)
	mouse_opacity = 2

	var/invocation = "Aiy ele-mayo!" //This is said by cultists when the rune is invoked.
	var/req_cultists = 1 //The amount of cultists required around the rune to invoke it. If only 1, any cultist can invoke it.
	var/rune_in_use = 0 // Used for some runes, this is for when you want a rune to not be usable when in use.
	var/talisman_type = null //the type of talisman the rune produces when attacked with a paper

	var/creation_delay = 50 //how long the rune takes to create
	var/scribe_damage = 0.1 //how much damage you take doing it

	var/req_pylons = 0
	var/req_forges = 0
	var/req_archives = 0
	var/req_altars = 0

	var/req_keyword = 0 //If the rune requires a keyword - go figure amirite
	var/keyword //The actual keyword for the rune

/obj/effect/rune/New(loc, set_keyword)
	..()
	if(set_keyword)
		keyword = set_keyword

/obj/effect/rune/examine(mob/user)
	..()
	if(iscultist(user) || user.stat == DEAD) //If they're a cultist or a ghost, tell them the effects
		user << "<b>Name:</b> [cultist_name]"
		user << "<b>Effects:</b> [capitalize(cultist_desc)]"
		user << "<b>Required Acolytes:</b> [req_cultists]"
		if(req_keyword && keyword)
			user << "<b>Keyword:</b> [keyword]"
		if(talisman_type)
			user << "<b>This rune can be imbued by striking it with paper.</b>"

/obj/effect/rune/attackby(obj/I, mob/user, params)
	if(iscultist(user))
		if(istype(I, /obj/item/weapon/tome))
			user << "<span class='notice'>You carefully erase the [lowertext(cultist_name)] rune.</span>"
			qdel(src)
		if(istype(I, /obj/item/weapon/paper) && !istype(I, /obj/item/weapon/paper/talisman))
			if(talisman_type)
				user << "<span class='notice'>You imbue the [lowertext(cultist_name)] rune into the paper.</span>"
				user.drop_item()
				user.put_in_hands(new talisman_type(user))
				qdel(I)
				qdel(src)
			else
				user << "<span class='notice'>This rune cannot be imbued into a talisman.</span>"
	else if(istype(I, /obj/item/weapon/nullrod))
		user.say("BEGONE FOUL MAGIKS!!")
		user << "<span class='danger'>You disrupt the magic of [src] with [I].</span>"
		qdel(src)

/obj/effect/rune/attack_hand(mob/living/user)
	if(!iscultist(user))
		user << "<span class='warning'>You aren't able to understand the words of [src].</span>"
		return
	if(can_invoke(user))
		invoke(user)
		var/oldtransform = transform
		animate(src, transform = matrix()*2, alpha = 0, time = 5) //fade out
		animate(transform = oldtransform, alpha = 255, time = 0)
	else
		fail_invoke(user)

/*

There are a few different procs each rune runs through when a cultist activates it.
can_invoke() is called when a cultist activates the rune with an empty hand. If there are multiple cultists, this rune determines if the required amount is nearby.
invoke() is the rune's actual effects.
fail_invoke() is called when the rune fails, via not enough people around or otherwise. Typically this just has a generic 'fizzle' effect.
structure_check() searches for nearby cultist structures required for the invocation. Proper structures are pylons, forges, archives, and altars.

*/

/obj/effect/rune/proc/can_invoke(var/mob/living/user)
	//This proc determines if the rune can be invoked at the time. If there are multiple required cultists, it will find all nearby cultists.
	if(!structure_check(req_pylons, req_forges, req_archives, req_altars))
		return 0
	if(!keyword && req_keyword)
		return 0
	if(req_cultists <= 1)
		if(invocation)
			user.say(invocation)
		return 1
	else
		var/cultists_in_range = 0
		for(var/mob/living/L in range(1, src))
			if(iscultist(L))
				var/mob/living/carbon/human/H = L
				if(!istype(H))
					if(istype(L, /mob/living/simple_animal/hostile/construct))
						if(invocation)
							L.say(invocation)
						cultists_in_range++
					continue
				if(L.stat || (H.disabilities & MUTE) || H.silent)
					continue
				if(invocation)
					L.say(invocation)
				cultists_in_range++
		if(cultists_in_range >= req_cultists)
			return 1
		else
			return 0

/obj/effect/rune/proc/invoke(var/mob/living/user)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.

/obj/effect/rune/proc/fail_invoke(var/mob/living/user)
	//This proc contains the effects of a rune if it is not invoked correctly, through either invalid wording or not enough cultists. By default, it's just a basic fizzle.
	visible_message("<span class='warning'>The markings pulse with a small flash of red light, then fall dark.</span>")

/obj/effect/rune/proc/structure_check(var/rpylons, var/rforges, var/rarchives, var/raltars)
	var/pylons = 0
	var/forges = 0
	var/archives = 0
	var/altars = 0
	for(var/obj/structure/cult/pylon in orange(3,src))
		pylons++
	for(var/obj/structure/cult/forge in orange(3,src))
		forges++
	for(var/obj/structure/cult/tome in orange(3,src))
		archives++
	for(var/obj/structure/cult/talisman in orange(3,src))
		altars++
	if(pylons >= rpylons && forges >= rforges && archives >= rarchives && altars >= raltars)
		return 1
	return 0


//Malformed Rune: This forms if a rune is not drawn correctly. Invoking it does nothing but hurt the user.
/obj/effect/rune/malformed
	cultist_name = "Malformed Rune"
	cultist_desc = "a senseless rune written in gibberish. No good can come from invoking this."
	invocation = "Ra'sha yoka!"

/obj/effect/rune/malformed/New()
	..()
	icon_state = "[rand(1,6)]"
	color = rgb(rand(0,255), rand(0,255), rand(0,255))

/obj/effect/rune/malformed/invoke(mob/living/user)
	user << "<span class='cultitalic'><b>You feel your life force draining. The Geometer is displeased.</b></span>"
	user.apply_damage(30, BRUTE)
	qdel(src)

/mob/proc/null_rod_check() //The null rod, if equipped, will protect the holder from the effects of most runes
	var/obj/item/weapon/nullrod/N = locate() in src
	if(N)
		return N
	return 0

var/list/teleport_runes = list()
//Rite of Translocation: Warps the user to a random teleport rune with the same keyword.
/obj/effect/rune/teleport
	cultist_name = "Teleport"
	cultist_desc = "warps everything above it to another chosen teleport rune."
	invocation = "Sas'so c'arta forbici!"
	talisman_type = /obj/item/weapon/paper/talisman/teleport
	icon_state = "2"
	color = rgb(0, 0, 255)
	req_keyword = 1
	var/listkey

/obj/effect/rune/teleport/New(loc, set_keyword)
	..()
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	listkey = set_keyword ? "[set_keyword] [locname]":"[locname]"
	teleport_runes["[listkey]"] = src

/obj/effect/rune/teleport/Destroy()
	teleport_runes.Remove(listkey)
	return ..()

/obj/effect/rune/teleport/invoke(mob/living/user)
	var/list/potential_runes = list()
	for(var/R in teleport_runes)
		var/obj/effect/rune/teleport/T = teleport_runes[R]
		if(T != src && (T.z <= ZLEVEL_SPACEMAX))
			potential_runes["[T.listkey]"] = T

	if(!potential_runes.len)
		user << "<span class='warning'>There are no valid runes to teleport to!</span>"
		log_game("Teleport rune failed - no other teleport runes")
		fail_invoke()
		return

	if(user.z > ZLEVEL_SPACEMAX)
		user << "<span class='cultitalic'>You are not in the right dimension!</span>"
		log_game("Teleport rune failed - user in away mission")
		fail_invoke()
		return

	var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes
	var/obj/effect/rune/teleport/actual_selected_rune = teleport_runes["[input_rune_key]"]
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated() || !actual_selected_rune)
		fail_invoke()
		return

	var/turf/T = get_turf(src)
	var/turf/UT = get_turf(user)
	var/movedsomething = 0
	for(var/atom/movable/A in T)
		if(!A.anchored)
			movedsomething = 1
			A.forceMove(get_turf(actual_selected_rune))
	if(movedsomething)
		visible_message("<span class='warning'>There is a sharp crack of inrushing air, and everything above the rune disappears!</span>")
		user << "<span class='cult'>You[user.loc == UT ? " send everything above the rune away":"r vision blurs, and you suddenly appear somewhere else"].</span>"
	else
		fail_invoke()


//Rite of Knowledge: Creates an arcane tome at the rune's location and destroys the rune.
/obj/effect/rune/summon_tome
	cultist_name = "Summon Tome"
	cultist_desc = "pulls an arcane tome from the archives of the Geometer."
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	creation_delay = 10 //1 second
	talisman_type = /obj/item/weapon/paper/talisman/summon_tome
	icon_state = "5"
	color = rgb(0, 0, 255)

/obj/effect/rune/summon_tome/invoke(mob/living/user)
	visible_message("<span class='warning'>A frayed tome materializes on the surface of [src], which dissolves into nothing.</span>")
	new /obj/item/weapon/tome(get_turf(src))
	qdel(src)


//Rite of Enlightenment: Converts a normal crewmember to the cult. Faster for every cultist nearby.
/obj/effect/rune/convert
	cultist_name = "Convert"
	cultist_desc = "converts a normal crewmember on top of it to the cult. Does not work on loyalty-implanted crew. Requires 2 invokers."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "3"
	color = rgb(255, 0, 0)
	req_cultists = 2

/obj/effect/rune/convert/can_invoke(mob/living/user)
	var/list/convertees = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T.contents)
		if(!iscultist(M) && !isloyal(M))
			convertees |= M
	if(!convertees.len)
		log_game("Convert rune failed - no eligible convertees")
		return 0
	return ..()

/obj/effect/rune/convert/invoke(mob/living/user)
	var/list/convertees = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T.contents)
		if(!iscultist(M) && !isloyal(M))
			convertees |= M
	var/mob/living/new_cultist = pick(convertees)
	if(!is_convertable_to_cult(new_cultist.mind) || new_cultist.null_rod_check())
		user << "<span class='warning'>Something is shielding [new_cultist]'s mind!</span>"
		fail_invoke()
		log_game("Convert rune failed - convertee could not be converted")
		if(is_sacrifice_target(new_cultist.mind))
			for(var/mob/living/M in orange(1,src))
				if(iscultist(M))
					M << "<span class='cultlarge'>\"I desire this one for myself. <i>SACRIFICE THEM!</i>\"</span>"
		return
	new_cultist.visible_message("<span class='warning'>[new_cultist] writhes in pain as the markings below them glow a bloody red!</span>", \
					  			"<span class='cultlarge'><i>AAAAAAAAAAAAAA-</i></span>")
	ticker.mode.add_cultist(new_cultist.mind)
	new_cultist.mind.special_role = "Cultist"
	new_cultist << "<span class='cultitalic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible, truth. The veil of reality has been ripped away \
	and something evil takes root.</b></span>"
	new_cultist << "<span class='cultitalic'><b>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve the Geometer above all else. Bring it back.\
	</b></span>"


//Rite of Tribute: Sacrifices a crew member to Nar-Sie. Places them into a soul shard if they're in their body.
/obj/effect/rune/sacrifice
	cultist_name = "Sacrifice"
	cultist_desc = "sacrifices a crew member to the Geometer. May place them into a soul shard if their spirit remains in their body. Requires 3 invokers to sacrifice living targets."
	icon_state = "3"
	invocation = "Barhah hra zar'garis!"
	color = rgb(255, 255, 255)
	rune_in_use = 0

/obj/effect/rune/sacrifice/New()
	..()
	icon_state = "[rand(1,6)]"

/obj/effect/rune/sacrifice/invoke(mob/living/user)
	if(rune_in_use)
		return
	rune_in_use = 1
	var/turf/T = get_turf(src)
	var/list/possible_targets = list()
	for(var/mob/living/M in T.contents)
		if(!iscultist(M))
			possible_targets.Add(M)
	var/mob/offering
	if(possible_targets.len > 1) //If there's more than one target, allow choice
		offering = input(user, "Choose an offering to sacrifice.", "Unholy Tribute") as null|anything in possible_targets
		if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
			return
	else if(possible_targets.len) //Otherwise, if there's a target at all, pick the only one
		offering = possible_targets[possible_targets.len]
	if(!offering)
		rune_in_use = 0
		return
	/*var/obj/item/weapon/nullrod/N = offering.null_rod_check()
	if(N)
		user << "<span class='warning'>Something is blocking the Geometer's magic!</span>"
		log_game("Sacrifice rune failed - target has \a [N]!")
		fail_invoke()
		rune_in_use = 0
		return*/
	if(((ishuman(offering) || isrobot(offering)) && offering.stat != DEAD) || is_sacrifice_target(offering.mind)) //Requires three people to sacrifice living targets
		var/cultists_nearby = 1
		for(var/mob/living/M in range(1,src))
			if(iscultist(M) && M != user)
				cultists_nearby++
				M.say(invocation)
		if(cultists_nearby < 3)
			user << "<span class='cultitalic'>[offering] is too greatly linked to the world! You need three acolytes!</span>"
			fail_invoke()
			log_game("Sacrifice rune failed - not enough acolytes and target is living")
			rune_in_use = 0
			return
	visible_message("<span class='warning'>[src] pulses blood red!</span>")
	color = rgb(126, 23, 23)
	spawn(5)
		color = initial(color)
	sac(offering)

/obj/effect/rune/sacrifice/proc/sac(mob/living/T)
	var/sacrifice_fulfilled
	if(T)
		if(istype(T, /mob/living/simple_animal/pet/dog))
			for(var/mob/living/carbon/C in range(3,src))
				if(iscultist(C))
					C << "<span class='cultlarge'>\"Even I have standards, such as they are!\"</span>"
					if(C.reagents)
						C.reagents.add_reagent("hell_water", 2)
		if(T.mind)
			sacrificed.Add(T.mind)
			if(is_sacrifice_target(T.mind))
				sacrifice_fulfilled = 1
		PoolOrNew(/obj/effect/overlay/temp/cult/sac, src.loc)
		for(var/mob/living/M in range(3,src))
			if(iscultist(M))
				if(sacrifice_fulfilled)
					M << "<span class='cultlarge'>\"Yes! This is the one I desire! You have done well.\"</span>"
				else
					if(ishuman(T) || isrobot(T))
						M << "<span class='cultlarge'>\"I accept this sacrifice.\"</span>"
					else
						M << "<span class='cultlarge'>\"I accept this meager sacrifice.\"</span>"
		if(T.mind)
			var/obj/item/device/soulstone/stone = new /obj/item/device/soulstone(get_turf(src))
			stone.invisibility = INVISIBILITY_MAXIMUM //so it's not picked up during transfer_soul()
			if(!stone.transfer_soul("FORCE", T, usr)) //If it cannot be added
				qdel(stone)
			if(stone)
				stone.invisibility = 0
			if(!T)
				rune_in_use = 0
				return
		if(isrobot(T))
			playsound(T, 'sound/magic/Disable_Tech.ogg', 100, 1)
			T.dust() //To prevent the MMI from remaining
		else
			playsound(T, 'sound/magic/Disintegrate.ogg', 100, 1)
			T.gib()
	rune_in_use = 0


//Ritual of Dimensional Rending: Calls forth the avatar of Nar-Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Summon Nar-Sie"
	cultist_desc = "tears apart dimensional barriers, calling forth the Geometer, Nar-Sie Herself. Requires 9 invokers."
	invocation = null
	req_cultists = 9
	creation_delay = 350 //35 seconds
	scribe_damage = 25 //lots of damage
	icon = 'icons/effects/96x96.dmi'
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	var/used

/obj/effect/rune/narsie/invoke(mob/living/user)
	if(used)
		return
	if(ticker.mode.name == "cult")
		var/datum/game_mode/cult/cult_mode = ticker.mode
		if(!("eldergod" in cult_mode.cult_objectives))
			message_admins("[usr.real_name]([user.ckey]) tried to summon Nar-Sie when the objective was wrong")
			for(var/mob/living/M in range(1,src))
				if(iscultist(M))
					M << "<span class='cultlarge'><i>\"YOUR SOUL BURNS WITH YOUR ARROGANCE!!!\"</i></span>"
					if(M.reagents)
						M.reagents.add_reagent("hell_water", 10)
					M.Weaken(5)
			fail_invoke()
			log_game("Summon Nar-Sie rune failed - improper objective")
			return
		else
			if(cult_mode.sacrifice_target && !(cult_mode.sacrifice_target in sacrificed))
				for(var/mob/living/M in orange(1,src))
					if(iscultist(M))
						M << "<span class='warning'>The sacrifice is not complete. The portal lacks the power to open!</span>"
				fail_invoke()
				log_game("Summon Nar-Sie rune failed - sacrifice not complete")
				return
		if(!cult_mode.eldergod)
			for(var/mob/living/M in orange(1,src))
				if(iscultist(M))
					M << "<span class='warning'>The avatar of Nar-Sie is already on this plane!</span>"
				log_game("Summon Nar-Sie rune failed - already summoned")
				return
		//BEGIN THE SUMMONING
		used = 1
		for(var/mob/living/M in range(1,src))
			if(iscultist(M))
				M.say("TOK-LYR RQA-NAP G'OLT-ULOFT!!")
		world << 'sound/effects/dimensional_rend.ogg'
		world << "<span class='cultitalic'><b>The veil... <span class='big'>is...</span> <span class='reallybig'>TORN!!!--</span></b></span>"
		sleep(40)
		new /obj/singularity/narsie/large(get_turf(user)) //Causes Nar-Sie to spawn even if the rune has been removed
		cult_mode.eldergod = 0
	else
		fail_invoke()
		log_game("Summon Nar-Sie rune failed - gametype is not cult")
		return

/obj/effect/rune/narsie/attackby(obj/I, mob/user, params)	//Since the narsie rune takes a long time to make, add logging to removal.
	if((istype(I, /obj/item/weapon/tome) && iscultist(user)))
		user.visible_message("<span class='warning'>[user.name] begins erasing the [src]...</span>", "<span class='notice'>You begin erasing the [src]...</span>")
		if(do_after(user, 50, target = src))	//Prevents accidental erasures.
			log_game("Summon Narsie rune erased by [user.mind.key] (ckey) with a tome")
			message_admins("[key_name_admin(user)] erased a Narsie rune with a tome")
			..()
	else
		if(istype(I, /obj/item/weapon/nullrod))	//Begone foul magiks. You cannot hinder me.
			log_game("Summon Narsie rune erased by [user.mind.key] (ckey) using a null rod")
			message_admins("[key_name_admin(user)] erased a Narsie rune with a null rod")
			..()


//Rite of Resurrection: Requires two corpses. Revives one and gibs the other.
/obj/effect/rune/raise_dead
	cultist_name = "Raise Dead"
	cultist_desc = "requires two corpses, one on the rune and one near it. The one placed upon the rune is brought to life, the other is turned to ash."
	invocation = null //Depends on the name of the user - see below
	icon_state = "1"
	color = rgb(255, 0, 0)

/obj/effect/rune/raise_dead/invoke(mob/living/user)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_sacrifice
	var/mob/living/mob_to_revive
	var/list/potential_sacrifice_mobs = list()
	var/list/potential_revive_mobs = list()
	if(rune_in_use)
		return
	for(var/mob/living/M in orange(1,src))
		if(!(M in T.contents) && M.stat == DEAD)
			potential_sacrifice_mobs.Add(M)
	if(!potential_sacrifice_mobs.len)
		user << "<span class='cultitalic'>There are no eligible sacrifices nearby!</span>"
		log_game("Raise Dead rune failed - no catalyst corpse")
		return
	mob_to_sacrifice = input(user, "Choose a corpse to sacrifice.", "Corpse to Sacrifice") as null|anything in potential_sacrifice_mobs
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	for(var/mob/living/M in T.contents)
		if(M.stat == DEAD)
			potential_revive_mobs.Add(M)
	if(rune_in_use)
		return
	if(!potential_revive_mobs.len)
		user << "<span class='cultitalic'>There is no eligible revival target on the rune!</span>"
		log_game("Raise Dead rune failed - no corpse to revived")
		return
	mob_to_revive = input(user, "Choose a corpse to revive.", "Corpse to Revive") as null|anything in potential_revive_mobs
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated() || !mob_to_revive || !mob_to_sacrifice)
		return
	revive(mob_to_revive, mob_to_sacrifice, user, T)

	//Begin revival
/obj/effect/rune/raise_dead/proc/revive(mob/living/mob_to_revive, mob/living/mob_to_sacrifice, mob/living/user, turf/T)
	if(rune_in_use)
		return
	if(!in_range(mob_to_sacrifice,src))
		user << "<span class='cultitalic'>The sacrificial target has been moved!</span>"
		fail_invoke()
		log_game("Raise Dead rune failed - catalyst corpse moved")
		return
	if(!(mob_to_revive in T.contents))
		user << "<span class='cultitalic'>The corpse to revive has been moved!</span>"
		fail_invoke()
		log_game("Raise Dead rune failed - revival target moved")
		return
	if(mob_to_sacrifice.stat != DEAD)
		user << "<span class='cultitalic'>The sacrificial target must be dead!</span>"
		fail_invoke()
		log_game("Raise Dead rune failed - catalyst corpse is not dead")
		return
	rune_in_use = 1
	if(user.name == "Herbert West")
		user.say("To life, to life, I bring them!")
	else
		user.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	mob_to_sacrifice.visible_message("<span class='warning'><b>[mob_to_sacrifice]'s body rises into the air, connected to [mob_to_revive] by a glowing tendril!</span>")
	mob_to_revive.Beam(mob_to_sacrifice,icon_state="sendbeam",icon='icons/effects/effects.dmi',time=20)
	sleep(20)
	if(!mob_to_sacrifice || !in_range(mob_to_sacrifice, src))
		mob_to_sacrifice.visible_message("<span class='warning'><b>[mob_to_sacrifice] disintegrates into a pile of bones</span>")
		return
	mob_to_sacrifice.dust()
	if(!mob_to_revive || mob_to_revive.stat != DEAD)
		visible_message("<span class='warning'>The glowing tendril snaps against the rune with a shocking crack.</span>")
		rune_in_use = 0
		return
	mob_to_revive.revive() //This does remove disabilities and such, but the rune might actually see some use because of it!
	mob_to_revive << "<span class='cultlarge'>\"PASNAR SAVRAE YAM'TOTH. Arise.\"</span>"
	mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] draws in a huge breath, red light shining from their eyes.</span>", \
								  "<span class='cultlarge'>You awaken suddenly from the void. You're alive!</span>")
	rune_in_use = 0

/obj/effect/rune/raise_dead/fail_invoke()
	for(var/mob/living/M in orange(1,src))
		if(M.stat == DEAD)
			M.visible_message("<span class='warning'>[M] twitches.</span>")


//Rite of True Sight: Turns ghosts and obscured runes visible, or hides them, depending on what state the rune is in
/obj/effect/rune/true_sight
	cultist_name = "Obscure Runes"
	cultist_desc = "reveals or hides all invisible objects nearby, from spirits to runes."
	invocation = "Kla'atu barada nikt'o!"
	creation_delay = 30 //3 seconds
	talisman_type = /obj/item/weapon/paper/talisman/true_sight
	icon_state = "4"
	color = rgb(255, 150, 200)
	var/revealing = TRUE //if the next use will reveal or hide

/obj/effect/rune/true_sight/invoke()
	visible_message("<span class='warning'>[src] flickers slightly.</span>")
	if(revealing)
		invocation = "Nikt'o barada kla'atu!"
		for(var/mob/dead/observer/O in range(3,src))
			if(O.invisibility)
				O << "<span class='cultitalic'>You suddenly feel very obvious...</span>"
				O.invisibility = 0
		for(var/obj/effect/rune/R in orange(3,src))
			if(R.invisibility)
				R.invisibility = 0
				R.visible_message("<span class='danger'>[R] suddenly appears!</span>")
				R.alpha = initial(R.alpha)
	else
		invocation = "Kla'atu barada nikt'o!"
		for(var/obj/effect/rune/R in orange(3,src))
			if(!R.invisibility)
				R.visible_message("<span class='danger'>[R] fades away.</span>")
				R.invisibility = INVISIBILITY_OBSERVER
				R.alpha = 100 //To help ghosts distinguish hidden runes
		for(var/mob/dead/observer/O in range(3,src))
			if(!O.invisibility)
				O << "<span class='cultitalic'>You suddenly feel as if you've vanished...</span>"
				O.invisibility = INVISIBILITY_OBSERVER
	revealing = !revealing

/obj/effect/rune/true_sight/examine(mob/user)
	..()
	if(iscultist(user) || user.stat == DEAD)
		user << "<span class='cult'>Will [revealing ? "reveal":"hide"] nearby runes and spirits when invoked.</span>"


//Rite of Disruption: Emits an EMP blast.
/obj/effect/rune/emp
	cultist_name = "Electromagnetic Disruption"
	cultist_desc = "emits a large electromagnetic pulse, hindering electronics and disabling silicons."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	talisman_type = /obj/item/weapon/paper/talisman/emp
	icon_state = "5"
	color = rgb(255, 0, 0)

/obj/effect/rune/emp/invoke(mob/living/user)
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>[src] glows blue for a moment before vanishing.</span>")
	for(var/mob/living/carbon/C in range(1,src))
		C << "<span class='warning'>You feel a minute vibration pass through you!</span>"
	playsound(T, 'sound/items/Welder2.ogg', 25, 1)
	qdel(src) //delete before pulsing because it's a delay reee
	empulse(T, 4, 8) //A bit less than an EMP grenade


//Rite of Astral Communion: Separates one's spirit from their body. They will take damage while it is active.
/obj/effect/rune/astral
	cultist_name = "Astral Communion"
	cultist_desc = "severs the link between one's spirit and body, allowing the user to seek hidden targets via the spirit realm. This effect is taxing and one's physical body will take damage while this is active."
	invocation = "Fwe'sh mah erl nyag r'ya!"
	icon_state = "6"
	color = rgb(126, 23, 23)
	rune_in_use = 0 //One at a time, please!
	var/mob/living/affecting = null

/obj/effect/rune/astral/examine(mob/user)
	..()
	if(affecting)
		user << "<span class='cultitalic'>A translucent field encases [user] above the rune!</span>"

/obj/effect/rune/astral/can_invoke(mob/living/user)
	if(rune_in_use)
		user << "<span class='cultitalic'>[src] cannot support more than one body!</span>"
		fail_invoke()
		log_game("Astral Communion rune failed - more than one user")
		return 0
	var/turf/T = get_turf(src)
	if(!user in T.contents)
		user << "<span class='cultitalic'>You must be standing on top of [src]!</span>"
		fail_invoke()
		log_game("Astral Communion rune failed - user not standing on rune")
		return 0
	. = ..()

/obj/effect/rune/astral/invoke(mob/living/user)
	rune_in_use = 1
	affecting = user
	var/previouscolor = user.color
	user.color = "#7e1717"
	user.visible_message("<span class='warning'>[user] freezes statue-still, glowing an unearthly red.</span>", \
						 "<span class='cult'>You see what lies beyond. All is revealed. While this is a wondrous experience, your physical form will waste away in this state. Hurry...</span>")
	user.ghostize(1)
	while(user)
		if(!affecting)
			visible_message("<span class='warning'>[src] pulses gently before falling dark.</span>")
			affecting = null //In case it's assigned to a number or something
			rune_in_use = 0
			return
		affecting.apply_damage(1, BRUTE)
		var/turf/T = get_turf(src)
		if(!(user in T.contents))
			user.visible_message("<span class='warning'>A spectral tendril wraps around [user] and pulls them back to the rune!</span>")
			Beam(user,icon_state="drainbeam",icon='icons/effects/effects.dmi',time=2)
			user.forceMove(get_turf(src)) //NO ESCAPE :^)
		if(user.key)
			user.visible_message("<span class='warning'>[user] slowly relaxes, the glow around them dimming.</span>", \
								 "<span class='danger'>You are re-united with your physical form. [src] releases its hold over you.</span>")
			user.color = previouscolor
			user.Weaken(3)
			rune_in_use = 0
			affecting = null
			return
		if(user.stat == UNCONSCIOUS)
			if(prob(10))
				var/mob/dead/observer/G = user.get_ghost()
				if(G)
					G << "<span class='cultitalic'>You feel the link between you and your body weakening... you must hurry!</span>"
		if(user.stat == DEAD)
			user.color = previouscolor
			rune_in_use = 0
			affecting = null
			var/mob/dead/observer/G = user.get_ghost()
			if(G)
				G << "<span class='cultitalic'><b>You suddenly feel your physical form pass on. [src]'s exertion has killed you!</b></span>"
			return
		sleep(10)
	rune_in_use = 0


//Rite of the Corporeal Shield: When invoked, becomes solid and cannot be passed. Invoke again to undo.
/obj/effect/rune/wall
	cultist_name = "Form Shield"
	cultist_desc = "becomes solid when invoked, preventing passage. Invoking it again reverses this effect."
	invocation = "Khari'd! Eske'te tannin!"
	icon_state = "1"
	color = rgb(255, 0, 0)

/obj/effect/rune/wall/examine(mob/user)
	..()
	if(density)
		user << "<span class='cultitalic'>There is a barely perceptible shimmering of the air above [src].</span>"

/obj/effect/rune/wall/invoke(mob/living/user)
	density = !density
	user.visible_message("<span class='warning'>[user] places their hands on [src], and [density ? "the air above it begins to shimmer" : "the shimmer above it fades"].</span>", \
						 "<span class='cultitalic'>You channel your life energy into [src], [density ? "preventing" : "allowing"] passage above it.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(2, BRUTE, pick("l_arm", "r_arm"))


//Rite of the Shadowed Mind:  Deafens, blinds and mutes all non-cultists nearby.
/obj/effect/rune/deafen
	cultist_name = "Debilitate"
	cultist_desc = "causes all non-followers nearby to lose their hearing, sight and voice. Will trigger when crossed by noncultists."
	invocation = "Sti kaliedir!"
	color = rgb(0, 255, 0)
	icon_state = "4"

/obj/effect/rune/deafen/invoke(mob/living/user)
	visible_message("<span class='warning'>[src] is obscured by shadows!</span>")
	for(var/mob/living/carbon/C in viewers(src))
		blind(C)
	qdel(src)

/obj/effect/rune/deafen/Crossed(atom/A)
	if(iscarbon(A) && !iscultist(A))
		blind(A)
		qdel(src)

/obj/effect/rune/deafen/proc/blind(mob/living/carbon/C)
	if(istype(L) && !iscultist(L))
		if(!C.null_rod_check())
			C << "<span class='cultlarge'>A dark fog blankets your senses!</span>"
			C.adjustEarDamage(0,50)
			C.flash_eyes(1, 1)
			C.adjust_blurriness(50)
			C.adjust_blindness(20)
			C.silent += 10
		else
			C << "<span class='warning'>Your holy weapon emits a soft glow!</span>"


//Rite of Disorientation: Stuns all non-cultists nearby for a brief time
/obj/effect/rune/stun
	cultist_name = "Stun"
	cultist_desc = "stuns all nearby non-followers for a brief time. Will trigger when crossed by noncultists."
	invocation = "Fuu ma'jin!"
	talisman_type = /obj/item/weapon/paper/talisman/stun
	icon_state = "2"
	color = rgb(100, 0, 100)

/obj/effect/rune/stun/invoke(mob/living/user)
	visible_message("<span class='warning'>[src] explodes in a bright flash!</span>")
	for(var/mob/living/M in viewers(src))
		stun(M)
	qdel(src)

/obj/effect/rune/stun/Crossed(atom/A)
	if(isliving(A))
		stun(A)
		qdel(src)

/obj/effect/rune/stun/proc/stun(mob/living/L)
	if(istype(L) && !iscultist(L))
		if(!L.null_rod_check())
			L << "<span class='cultitalic'><b>You are disoriented by [src]!</b></span>"
			L.Weaken(3)
			L.Stun(3)
			L.flash_eyes(1,1)
		else
			L << "<span class='warning'>Your holy weapon absorbs the blinding light!</span>"


//Rite of Joined Souls: Summons a single cultist.
/obj/effect/rune/summon
	cultist_name = "Summon Cultist"
	cultist_desc = "summons a single cultist to the rune. Requires 2 invokers."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	req_cultists = 2
	icon_state = "5"
	color = rgb(0, 255, 0)

/obj/effect/rune/summon/invoke(mob/living/user)
	var/list/cultists = list()
	for(var/datum/mind/M in ticker.mode.cult)
		cultists.Add(M.current)
	var/mob/living/cultist_to_summon = input("Who do you wish to call to [src]?", "Followers of the Geometer") as null|anything in (cultists - user)
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	if(!cultist_to_summon)
		user << "<span class='cultitalic'>You require a summoning target!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(!iscultist(cultist_to_summon))
		user << "<span class='cultitalic'>[cultist_to_summon] is not a follower of the Geometer!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(cultist_to_summon.z > ZLEVEL_SPACEMAX)
		user << "<span class='cultitalic'>[cultist_to_summon] is not in our dimension!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - target in away mission")
		return
	cultist_to_summon.visible_message("<span class='warning'>[cultist_to_summon] suddenly disappears in a flash of red light!</span>", \
									  "<span class='cultitalic'><b>Overwhelming vertigo consumes you as you are hurled through the air!</b></span>")
	visible_message("<span class='warning'>A foggy shape materializes atop [src] and solidifes into [cultist_to_summon]!</span>")
	user.apply_damage(10, BRUTE, "head")
	cultist_to_summon.forceMove(get_turf(src))
	qdel(src)


//Rite of Fabrication: Creates a construct shell out of 15 metal sheets.
/obj/effect/rune/construct_shell
	cultist_name = "Fabricate Shell"
	cultist_desc = "turns fifteen metal sheets into an empty construct shell, suitable for containing a soul shard."
	invocation = "Ethra p'ni dedol!"
	icon_state = "5"
	color = rgb(150, 150, 150)

/obj/effect/rune/construct_shell/can_invoke(mob/living/user)
	. = 0
	var/turf/T = get_turf(src)
	var/canmakeshell = 0
	for(var/obj/item/stack/sheet/metal/S in T)
		if(!canmakeshell && S.use(15))
			canmakeshell = 1
	if(canmakeshell)
		. = ..()
	else
		user << "<span class='cultitalic'>There must be at least fifteen sheets of metal on [src]!</span>"
		log_game("Construct Shell rune failed - not enough metal sheets")

/obj/effect/rune/construct_shell/invoke(mob/living/user)
	new /obj/structure/constructshell(get_turf(src))
	visible_message("<span class='warning'>The metal bends and twists into a humanoid shell!</span>")
	qdel(src)


//Rite of Arming: Creates cult robes, a trophy rack, and a cult sword on the rune.
/obj/effect/rune/armor
	cultist_name = "Summon Armaments"
	cultist_desc = "equips the user with robes, shoes, a backpack, and a longsword. Items that cannot be equipped will not be summoned."
	invocation = "N'ath reth sh'yro eth draggathnor!"
	talisman_type = /obj/item/weapon/paper/talisman/armor
	icon_state = "4"
	color = rgb(255, 0, 0)

/obj/effect/rune/armor/invoke(mob/living/user)
	visible_message("<span class='warning'>With the sound of clanging metal, [src] crumbles to dust!</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), slot_shoes)
	user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
	user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
	qdel(src)


//Rite of Leeching: Deals brute damage to the target and heals the same amount to the invoker.
/obj/effect/rune/leeching
	cultist_name = "Drain Life"
	cultist_desc = "drains the life of all targets on the rune, restoring life to the user."
	invocation = "Yu'gular faras desdae. Umathar uf'kal thenar!"
	icon_state = "2"
	color = rgb(255, 0, 0)

/obj/effect/rune/leeching/can_invoke(mob/living/user)
	if(world.time <= usr.next_move)
		return 0
	var/turf/T = get_turf(src)
	var/list/potential_targets = list()
	for(var/mob/living/carbon/M in T)
		if(M.stat != DEAD && M != user)
			potential_targets.Add(M)
	if(!potential_targets.len)
		user << "<span class='cultitalic'>There must be a valid target on the rune!</span>"
		log_game("Leeching rune failed - no valid targets")
		return 0
	return ..()

/obj/effect/rune/leeching/invoke(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	var/turf/T = get_turf(src)
	for(var/mob/living/carbon/M in T)
		if(M.stat != DEAD && M != user)
			var/drained_amount = rand(10,20)
			M.apply_damage(drained_amount, BRUTE, "chest")
			user.adjustBruteLoss(-drained_amount)
			user.Beam(M,icon_state="drainbeam",icon='icons/effects/effects.dmi',time=5)
			M << "<span class='cultitalic'>You feel extremely weak.</span>"
	user.visible_message("<span class='warning'>Blood flows from the rune into [user]!</span>", \
						 "<span class='cult'>Blood flows into you, healing your wounds and revitalizing your spirit.</span>")


//Rite of Boiling Blood: Deals extremely high amounts of damage to non-cultists nearby
/obj/effect/rune/blood_boil
	cultist_name = "Boil Blood"
	cultist_desc = "boils the blood of non-believers who can see the rune, dealing extreme amounts of damage. Requires 3 invokers."
	invocation = "Dedo ol'btoh!"
	icon_state = "4"
	color = rgb(255, 0, 0)
	req_cultists = 3

/obj/effect/rune/blood_boil/invoke(mob/living/user)
	visible_message("<span class='warning'>[src] briefly bubbles before disappearing in a burst of flame!</span>")
	for(var/mob/living/carbon/C in viewers(src))
		if(!iscultist(C))
			var/obj/item/weapon/nullrod/N = C.null_rod_check()
			if(N)
				C << "<span class='userdanger'>\The [N] suddenly burns hotly before returning to normal!</span>"
				continue
			C << "<span class='cultlarge'>Your blood boils in your veins!</span>"
			C.take_overall_damage(51,51)
	for(var/mob/living/carbon/M in range(1,src))
		if(iscultist(M))
			M.apply_damage(15, BRUTE, pick("l_arm", "r_arm"))
			M << "<span class='cultitalic'>[src] saps your strength!</span>"
	PoolOrNew(/obj/effect/hotspot, get_turf(src))
	qdel(src)


//Rite of Spectral Manifestation: Summons a ghost on top of the rune as a cultist human with no items. User must stand on the rune at all times, and takes damage for each summoned ghost.
/obj/effect/rune/manifest
	cultist_name = "Manifest Spirit"
	cultist_desc = "manifests a spirit as a servant of the Geometer. The invoker must not move from atop the rune, and will take damage for each summoned spirit."
	invocation = "Gal'h'rfikk harfrandid mud'gib!" //how the fuck do you pronounce this
	icon_state = "6"
	color = rgb(255, 0, 0)

/obj/effect/rune/manifest/can_invoke(mob/living/user)
	if(!(user in get_turf(src)))
		user << "<span class='cultitalic'>You must be standing on [src]!</span>"
		log_game("Manifest rune failed - user not standing on rune")
		return 0
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST))
			ghosts_on_rune |= O
	if(!ghosts_on_rune.len)
		user << "<span class='cultitalic'>There are no spirits near [src]!</span>"
		fail_invoke()
		log_game("Manifest rune failed - no nearby ghosts")
		return 0
	return ..()

/obj/effect/rune/manifest/invoke(mob/living/user)
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST))
			ghosts_on_rune |= O
	var/mob/dead/observer/ghost_to_spawn = pick(ghosts_on_rune)
	var/mob/living/carbon/human/new_human = new(get_turf(src))
	new_human.real_name = ghost_to_spawn.real_name
	new_human.alpha = 150 //Makes them translucent
	visible_message("<span class='warning'>A cloud of red mist forms above [src], and from within steps... a man.</span>")
	user << "<span class='cultitalic'>Your blood begins flowing into [src]. You must remain in place and conscious to maintain the forms of those summoned. This will hurt you slowly but surely...</span>"
	new_human.key = ghost_to_spawn.key
	ticker.mode.add_cultist(new_human.mind)
	new_human << "<span class='cultitalic'><b>You are a servant of the Geometer. You have been made semi-corporeal by the cult of Nar-Sie, and you are to serve them at all costs.</b></span>"

	while(user in get_turf(src))
		if(user.stat)
			break
		user.apply_damage(1, BRUTE)
		sleep(30)

	if(new_human)
		new_human.visible_message("<span class='warning'>[new_human] suddenly dissolves into bones and ashes.</span>", \
								  "<span class='cultlarge'>Your link to the world fades. Your form breaks apart.</span>")
		for(var/obj/I in new_human)
			new_human.unEquip(I)
		new_human.dust()
