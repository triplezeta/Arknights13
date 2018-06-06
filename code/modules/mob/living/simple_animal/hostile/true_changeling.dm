#define TRUE_CHANGELING_REFORM_THRESHOLD 0 //Can turn back at will, by default
#define TRUE_CHANGELING_PASSIVE_HEAL 3 //Amount of brute damage restored per tick

//Changelings in their true form.
//Massive health and damage, but all of their chems and it's really obvious it's >them

/mob/living/simple_animal/hostile/true_changeling
	name = "horror"
	real_name = "horror"
	desc = "Holy shit, what the fuck is that thing?!"
	speak_emote = list("says with one of its faces")
	emote_hear = list("says with one of its faces")
	icon = 'icons/mob/changeling.dmi'
	icon_state = "horror1"
	icon_living = "horror1"
	icon_dead = "horror_dead"
	speed = 0.5
	gender = NEUTER
	a_intent = "harm"
	stop_automated_movement = TRUE
	status_flags = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	health = 240
	maxHealth = 240 //pretty durable
	damage_coeff = list(BRUTE = 0.75, BURN = 2, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) //feel the burn!!
	force_threshold = 10
	healable = 0
	environment_smash = 1 //Tables, closets, etc.
	melee_damage_lower = 35
	melee_damage_upper = 35
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	wander = 0
	attacktext = "tears into"
	attack_sound = 'sound/creatures/hit3.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 15) //It's a pretty big dude. Actually killing one is a feat.
	var/playstyle_string = "<b><span class='big danger'>We have entered our true form!</span><br>We are unbelievably deadly, and regenerate life at a steady rate. We must utilise the abilities that we have gained as a result of our transformation, as our old ones are not usable in this form. Taking too much damage will also turn us back into a \
	human in addition to knocking us out. We are not as strong health-wise as we are damage, and we must avoid fire at all costs. Finally, we will uncontrollably revert into a human after some time due to our inability to maintain this form.</b>"
	var/mob/living/carbon/human/stored_changeling = null //The changeling that transformed

	var/devouring = FALSE
	var/assimilation = FALSE
	var/tendrilgrab = FALSE
	var/wallcrawl = FALSE

	var/range = 7
	var/datum/action/innate/changeling/devour/devour
	var/datum/action/innate/changeling/tendril_grab/tendril_grab
	var/datum/action/innate/changeling/assimilate/assimilate
	var/datum/action/innate/changeling/spine_crawl/spine_crawl

/mob/living/simple_animal/hostile/true_changeling/Initialize()
	. = ..()
	icon_state = "horror[rand(1, 5)]"
	devour = new
	devour.Grant(src)
	tendril_grab = new
	tendril_grab.Grant(src)
	assimilate = new
	assimilate.Grant(src)
	spine_crawl = new
	spine_crawl.Grant(src)
	var/datum/atom_hud/hud = GLOB.huds[ANTAG_HUD_CHANGELING]
	hud.add_hud_to(src)

/mob/living/simple_animal/hostile/true_changeling/Destroy()
	QDEL_NULL(devour)
	QDEL_NULL(tendril_grab)
	QDEL_NULL(assimilate)
	QDEL_NULL(spine_crawl)
	stored_changeling = null
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_CHANGELING]
	hud.remove_hud_from(src)
	return ..()

/mob/living/simple_animal/hostile/true_changeling/Login()
	. = ..()
	to_chat(usr, playstyle_string)

/mob/living/simple_animal/hostile/true_changeling/Life()
	..()
	adjustBruteLoss(-TRUE_CHANGELING_PASSIVE_HEAL) //True changelings slowly regenerate

/mob/living/simple_animal/hostile/true_changeling/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Ignoring Gravity: [wallcrawl ? "YES" : "NO"]")

/mob/living/simple_animal/hostile/true_changeling/death()
	..(1)
	new /obj/effect/gibspawner/human(get_turf(src))
	if(stored_changeling && mind)
		visible_message("<span class='warning'>[src] lets out a furious scream as it shrinks into its human form.</span>", \
						"<span class='userdanger'>We lack the power to maintain this form! We helplessly turn back into a human...</span>")
		stored_changeling.loc = get_turf(src)
		mind.transfer_to(stored_changeling)
		stored_changeling.Unconscious(300) //Make them helpless for some time
		stored_changeling.status_flags &= ~GODMODE
		qdel(src)
	else
		visible_message("<span class='warning'>[src] lets out a waning scream as it falls, twitching, to the floor.</span>", \
						"<span class='userdanger'>We have fallen! We begin the revival process...</span>")
		addtimer(CALLBACK(src, .proc/lingreform), 450)

/mob/living/simple_animal/hostile/true_changeling/proc/lingreform()
	if(!src)
		return FALSE
	visible_message("<span class='userdanger'>the twitching corpse of [src] reforms!</span>")
	for(var/mob/M in view(7, src))
		flash_color(M, flash_color = list("#db0000", "#db0000", "#db0000", rgb(0,0,0)), flash_time = 5)
	new /obj/effect/gibspawner/human(get_turf(src))
	revive() //Changelings can self-revive, and true changelings are no exception

/mob/living/simple_animal/hostile/true_changeling/mob_negates_gravity()
	return wallcrawl

/mob/living/simple_animal/hostile/true_changeling/adjustFireLoss(amount)
	if(!stat)
		playsound(src, 'sound/creatures/ling_scream.ogg', 100, 1)
	..()

/datum/action/innate/changeling
	icon_icon = 'icons/mob/changeling.dmi'
	background_icon_state = "bg_ling"

/datum/action/innate/changeling/devour
	name = "Devour"
	desc = "We tear into the innards of a human. After some time, they will be significantly damaged and our health partially restored."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "devour"

/datum/action/innate/changeling/devour/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return
	if(M.devouring)
		to_chat(M, "<span class='warning'>We are already feasting on a victim!</span>")
		return FALSE
	if(M.assimilation)
		to_chat(M, "<span class='warning'>We are already busy with assimilation.</span>")
		return FALSE
	if(M.tendrilgrab)
		to_chat(M, "<span class='warning'>We are already busy grabbing someone!</span>")
		return FALSE
	var/list/potential_targets = list()
	for(var/mob/living/carbon/human/H in range(1, M))
		potential_targets.Add(H)
	if(!potential_targets.len)
		to_chat(M, "<span class='warning'>There are no victims nearby!</span>")
		return FALSE
	var/mob/living/carbon/human/lunch
	if(potential_targets.len == 1)
		lunch = potential_targets[1]
	else
		lunch = input(src, "Choose a victim to devour.", "Lunch") as null|anything in potential_targets
	if(!lunch)
		return FALSE
	if(lunch.getBruteLoss() >= 200)
		to_chat(M, "<span class='warning'>This victim's flesh is too mangled to devour!</span>")
		return FALSE
	M.devouring = TRUE
	M.visible_message("<span class='warning'>[M] begins ripping apart and feasting on [lunch]!</span>", \
						"<span class='danger'>We begin to feast upon [lunch]...</span>")
	if(!do_mob(M, 50, target = lunch))
		M.devouring = FALSE
		return FALSE
	M.devouring = FALSE
	M.visible_message("<span class='warning'>[M] tears a chunk from [lunch]'s flesh!</span>", \
						"<span class='danger'>We tear a chunk of flesh from [lunch] and devour it!</span>")
	lunch.adjustBruteLoss(60)
	to_chat(lunch, "<span class='userdanger'>[M] tears into you!</span>")
	var/obj/effect/decal/cleanable/blood/gibs/G = new(get_turf(lunch))
	step(G, pick(GLOB.alldirs)) //Make some gibs spray out for dramatic effect
	playsound(lunch, 'sound/creatures/hit6.ogg', 100, 1)
	if(!lunch.stat)
		lunch.emote("scream")
	M.adjustBruteLoss(-50)

/datum/action/innate/changeling/assimilate
	name = "Assimilate"
	desc = "We replace a victim's simple consciousness with our own, adding them to our hivemind. victim must be conscious for this."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "assimilate"

/datum/action/innate/changeling/assimilate/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return
	if(M.devouring)
		to_chat(M, "<span class='warning'>We are already busy feasting on a target!</span>")
		return FALSE
	if(M.assimilation)
		to_chat(M, "<span class='warning'>Assimilation already in progress.</span>")
		return FALSE
	if(M.tendrilgrab)
		to_chat(M, "<span class='warning'>We are already busy grabbing someone!</span>")
		return FALSE
	var/list/potential_targets = list()
	for(var/mob/living/carbon/human/H in range(1, M))
		potential_targets.Add(H)
	if(!potential_targets.len)
		to_chat(M, "<span class='warning'>There are no valid targets nearby.</span>")
		return FALSE
	var/mob/living/carbon/human/target
	if(potential_targets.len == 1)
		target = potential_targets[1]
	else
		target = input(src, "Choose a target to assimilate.", "Assimilation") as null|anything in potential_targets
	if(!target)
		return FALSE
	if(target.stat != CONSCIOUS)
		to_chat(M, "<span class='warning'>Target not suitable for assimilation: Target is not conscious.</span>")
		return FALSE
	if(!target.mind)
		to_chat(M, "<span class='warning'>Target not suitable for assimilation: Target has no mind.</span>")
		return FALSE
	if(target.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(M, "<span class='warning'>Target not suitable for assimilation: Target is already a changeling!</span>")
		return FALSE
	M.visible_message("<span class='warning'>[M] begins to convulse!</span>", "<span class='warning'>Target suitable for assimilation. We begin to ready our appendages...</span>")
	M.Shake(15, 15, 350)
	M.assimilation = TRUE
	for(var/progress = 0, progress <= 3, progress++)
		var/datum/beam/B = M.Beam(target, icon_state = "cord-[progress]", time=INFINITY)
		switch(progress)
			if(1)
				M.visible_message("<span class='warning'>[M] constricts [target]!</span>", "<span class='notice'>We constrict [target] with our appendages...</span>")
				target.handcuffed = new/obj/item/restraints/handcuffs/horrorform(target)
				target.update_handcuffed()
			if(2)
				to_chat(M, "<span class='notice'>We begin to assimilate [target].</span>")
				to_chat(target, "<span class='danger'>You suddenly feel like your skin is <i>wrong</i>...</span>")
				if(target.isloyal())
					to_chat(M, "<span class='notice'>They are protected by a mindshield implant. The creature will have to destroy it - it will take time.</span>")
					to_chat(target, "<span class='boldannounce'>You feel a sharp pain in your head!</span>")
					sleep(100) //10 seconds
					to_chat(M, "<span class='notice'>The creature has destroyed the mindshield. Assimilation will resume.</span>")
					for(var/obj/item/implant/mindshield/L in target.implants)
						if(L)
							qdel(L)
					to_chat(target, "<span class='boldannounce'>You feel the protection from your mindshield implant strain and fail.</span>")
			if(3)
				target.visible_message("<span class='danger'>[M] extends a proboscis!</span>")
				to_chat(M, "<span class='notice'>We prepare to finalize [target]'s assimilation process...</span>")
				to_chat(target, "<span class='boldannounce'>Your skin is wriggling and peeling apart. Your memories are contorting into horror.</span>")
		if(!do_mob(M, target, 70)) //around 23 seconds total for enthralling, 33 for someone with a mindshield implant
			to_chat(M, "<span class='danger'>Assimilation interrupted!</span>")
			target.uncuff()
			to_chat(target, "<span class='userdanger'>You wrest yourself away from [M]'s tendrils and compose yourself.</span>")
			qdel(B)
			M.assimilation = FALSE
			return
		qdel(B)

	M.assimilation = FALSE
	target.uncuff()
	target.visible_message("<span class='big'>[target] shudders, and looks around curiously.</span>", \
						   "<span class='boldannounce'>False faces all f<span class='big'>ake not real not real not--</span></span>")
	to_chat(M, "<span class='shadowling'><b>[target.real_name]</b> has joined the hivemind.</span>")
	var/datum/antagonist/changeling/lesser/ASSIMILATEEE = new()
	//try assimilateee.horrormaster = src!
	target.mind.add_antag_datum(ASSIMILATEEE)
	return

/datum/action/innate/changeling/tendril_grab //TODO: ADD ASSIMILATION COMBO HERE.
	name = "Tendril Grab"
	desc = "Lash a tendril out, grabbing prey. We must be spine crawling to do this. We can begin assimilation from a tendril grab too, keep in mind."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "jammer"

/datum/action/innate/changeling/tendril_grab/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return
	if(M.devouring)
		to_chat(M, "<span class='warning'>We are already busy feasting on a target!</span>")
		return FALSE
	if(M.assimilation)
		to_chat(M, "<span class='warning'>We are already busy with assimilation.</span>")
		return FALSE
	if(M.tendrilgrab)
		to_chat(M, "<span class='warning'>We are already grabbing someone!</span>")
		return FALSE
	if(!M.wallcrawl)
		to_chat(M, "<span class='warning'>We must be spine crawling to pull someone!</span>")
		return FALSE
	var/list/potential_targets = list()
	for(var/mob/living/carbon/human/H in view(7, M))
		potential_targets.Add(H)
	if(!potential_targets.len)
		to_chat(M, "<span class='warning'>There are no valid targets nearby.</span>")
		return FALSE
	var/mob/living/carbon/human/target
	if(potential_targets.len == 1)
		target = potential_targets[1]
	else
		target = input(src, "Choose a target to assimilate.", "Grabby grabbing time") as null|anything in potential_targets
	if(!target)
		return FALSE
	if(!target in view(7, M))
		to_chat(M, "<span class='warning'>Target left our sight!</span>")
		return FALSE
	M.tendrilgrab = TRUE
	M.visible_message("<span class='danger'>[M] shoots out a tendril!</span>", "<span class='notice'>We have constricted [target]! We will now reel him in, and moving will cancel the pull.</span>")
	var/obj/item/restraints/handcuffs/horrorform/cuffs = new(target)
	target.handcuffed = cuffs
	target.update_handcuffed()
	var/turf/T = get_turf(M)
	to_chat(target, "<span class='userdanger'>You have been constricted by [M]! Resist to escape!</span>")
	var/datum/beam/B = M.Beam(target, icon_state = "cord-2", time=INFINITY)
	var/ticker = 0
	while(target.handcuffed && M.loc == T && target in view(7, M))
		to_chat(target, "<span class='userdanger'>You're getting pulled to [M]!</span>")
		target.Stun(6)
		sleep(5)
		if(ticker == 2)
			ticker = 0
			var/turf/REELEMINBOYS = get_step_to(target, M)
			if(REELEMINBOYS != T)
				target.forceMove(REELEMINBOYS)
		else
			ticker++
	to_chat(M, "<span class='userdanger'>Tendril grab has ended!</span>")
	qdel(B)
	target.uncuff()
	M.tendrilgrab = FALSE

/datum/action/innate/changeling/spine_crawl
	name = "Spine Crawl"
	desc = "We use our spines to gouge into terrain and crawl along it, negating gravity loss. This makes us slower."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "spine"

/datum/action/innate/changeling/spine_crawl/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return FALSE
	if(M.tendrilgrab)
		to_chat(M, "<span class='warning'>We are grabbing someone, release them to undo our spines.</span>")
		return FALSE
	M.wallcrawl = !M.wallcrawl
	if(M.wallcrawl)
		M.visible_message("<span class='danger'>[M] begins gouging its spines into the terrain!</span>", \
							"<span class='notice'>We begin using our spines for movement.</span>")
		M.speed = 1
	else
		M.visible_message("<span class='danger'>[M] recedes their spines back into their body!</span>", \
							"<span class='notice'>We return moving normally.</span>")
		M.speed = initial(M.speed)

/obj/item/restraints/handcuffs/horrorform
	name = "writhing tentacles"
	desc = "appendages from a hideous creature."
	icon_state = "cordgrab"
	item_flags = DROPDEL
	cufficon = 'icons/mob/changeling.dmi'
	cuffsprite = "cordgrab"
	breakouttime = 350 //BARELY enough for assimilation cuffs

/obj/item/restraints/handcuffs/horrorform/dropped(mob/user)
	user.visible_message("<span class='danger'>The [name] holding [user] violently jerk and recede!</span>", \
	"<span class='userdanger'>The [name] convulse and recede!</span>")
	. = ..()

#undef TRUE_CHANGELING_REFORM_THRESHOLD
#undef TRUE_CHANGELING_PASSIVE_HEAL