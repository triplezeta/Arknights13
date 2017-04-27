/obj/item/weapon/melee
	needs_permit = 1

/obj/item/weapon/melee/proc/check_martial_counter(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(target.check_block())
		target.visible_message("<span class='danger'>[target.name] blocks [src] and twists [user]'s arm behind their back!</span>",
					"<span class='userdanger'>You block the attack!</span>")
		user.Stun(2)
		return TRUE


/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=5"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/chainhit.ogg'
	materials = list(MAT_METAL = 1000)

/obj/item/weapon/melee/chainofcommand/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/weapon/melee/synthetic_arm_blade
	name = "synthetic arm blade"
	desc = "A grotesque blade that on closer inspection seems made of synthentic flesh, it still feels like it would hurt very badly as a weapon."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	origin_tech = "combat=5;biotech=5"
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharpness = IS_SHARP

/obj/item/weapon/melee/buff_arm
	name = "extremely buff arm"
	desc = "An extremely buff mass of muscle that on closer inspection seems to be trying to immitate an arm. You probably don't \
		want to be on the recieving end of this."
	icon = 'icons/obj/items.dmi'
	icon_state = "buff_arm"
	item_state = "buff_arm"
	block_chance = 15 //2 arms, total 30% chance to block shots.
	flags = NODROP|ABSTRACT|DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	force = 45 //5 hit kill on unarmored opponents
	hitsound = 'sound/weapons/punch3.ogg'
	attack_verb = list("smashed", "pummeled", "punched", "mashed", "demolished", "destroyed")

/obj/item/weapon/melee/buff_arm/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == THROWN_PROJECTILE_ATTACK)
		final_block_chance += 10 //50% total to block thrown items
	if(attack_type == MELEE_ATTACK)
		final_block_chance -= 5 //20% total to block melee attacks
	if(attack_type == UNARMED_ATTACK) //unarmed and xeno leaps fully blocked.
		final_block_chance = 100
	if(attack_type == LEAP_ATTACK)
		final_block_chance = 100
	return ..()

 //at least look cool when accidently hitting yourself
/obj/item/weapon/melee/buff_arm/afterattack(target, mob/user)
	if(user && target == user)
		user.visible_message("<span class='danger'>[user] beats their chest in a fit of primal rage!</span>")
		user.say(pick("GRRAAAGHHH!!!", "RAAAAAAGHH!!!", "AAAAAGGRHHHH!!!"))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
		return

//random special weaken when attacking
	else if(iscarbon(target))
		var/mob/living/carbon/T = target
		if(!T.lying && prob(35)) //don't want stun locking, not like you'd survive long enough for it to happen in the first place
			T.visible_message("<span class='warning'>[T] cries out in pain as [user] slams them into the ground!</span>", \
							 "<span class='danger'>You cry out in vain as [T] slams you into the ground, knocking the air out of your lungs!</span>")
			T.emote("gasp")
			T.adjustOxyLoss(-25)
			T.Weaken(4)
			for(var/mob/M in range(5, src))
				shake_camera(M, 5, 1)

//eating corpses, 15 second delay for 25 brute/burn heal.
		if(T.stat == DEAD)
			var/mob/living/carbon/U = user
			user.visible_message("<span class='warning'>[user] starts trying to devour [T]!", "<span class='notice'>You start to devour [T]..</span>")
			if(do_after(user, 100, target = T )) //10 seconds to consume
				U.adjustBruteLoss(-25)
				U.adjustFireLoss(-25)
				user.visible_message("<span class='danger'>[user] devours [T]!", "<span class='notice'>You devour[T].</span>")
				T.gib()
				U.emote("burp")

 //shameless copy from armblade please don't hurt me, allows prying open unbolted doors
	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		if(!A.requiresID() || A.allowed(user))
			return

		if(A.locked)
			to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
			return

		if(A.hasPower())
			user.visible_message("<span class='warning'>[user] jams their hands into the central section of the airlock, trying to pry it open!</span>", "<span class='warning'>You start prying open the door..</span>", \
			"<span class='italics'>You hear a metal screeching sound.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 100, 1)
			if(!do_after(user, 100, target = A))
				return
		user.visible_message("<span class='warning'>[user] forces the airlock to open with their [src]!</span>", "<span class='warning'>You managed to pry the door open.</span>", \
		"<span class='italics'>You hear a metal screeching sound.</span>")
		A.open(2)

/obj/item/weapon/melee/sabre
	name = "officer's sabre"
	desc = "An elegant weapon, its monomolecular edge is capable of cutting through flesh and bone with ease."
	icon_state = "sabre"
	item_state = "sabre"
	flags = CONDUCT
	unique_rename = 1
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharpness = IS_SHARP
	origin_tech = "combat=5"
	attack_verb = list("slashed", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(MAT_METAL = 1000)

/obj/item/weapon/melee/sabre/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL
	var/cooldown = 0
	var/on = 1

/obj/item/weapon/melee/classic_baton/attack(mob/target, mob/living/user)
	if(!on)
		return ..()

	add_fingerprint(user)
	if((CLUMSY in user.disabilities) && prob(50))
		to_chat(user, "<span class ='danger'>You club yourself over the head.</span>")
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, "head")
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		..()
		return
	if(!isliving(target))
		return
	if (user.a_intent == INTENT_HARM)
		if(!..())
			return
		if(!iscyborg(target))
			return
	else
		if(cooldown <= world.time)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.check_shields(0, "[user]'s [name]", src, MELEE_ATTACK))
					return
				if(check_martial_counter(H, user))
					return
			playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
			target.Weaken(3)
			add_logs(user, target, "stunned", src)
			src.add_fingerprint(user)
			target.visible_message("<span class ='danger'>[user] has knocked down [target] with [src]!</span>", \
				"<span class ='userdanger'>[user] has knocked down [target] with [src]!</span>")
			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = user
			cooldown = world.time + 40

/obj/item/weapon/melee/classic_baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = null
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	needs_permit = 0
	force = 0
	on = 0

/obj/item/weapon/melee/classic_baton/telescopic/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)

	user.visible_message("<span class='suicide'>[user] stuffs [src] up [user.p_their()] nose and presses the 'extend' button! It looks like [user.p_theyre()] trying to clear their mind.</span>")
	if(!on)
		src.attack_self(user)
	else
		playsound(loc, 'sound/weapons/batonextend.ogg', 50, 1)
		add_fingerprint(user)
	sleep(3)
	if (H && !QDELETED(H))
		if (B && !QDELETED(B))
			H.internal_organs -= B
			qdel(B)
		new /obj/effect/gibspawner/generic(H.loc, H.viruses, H.dna)
		return (BRUTELOSS)

/obj/item/weapon/melee/classic_baton/telescopic/attack_self(mob/user)
	on = !on
	if(on)
		to_chat(user, "<span class ='warning'>You extend the baton.</span>")
		icon_state = "telebaton_1"
		item_state = "nullrod"
		w_class = WEIGHT_CLASS_BULKY //doesnt fit in backpack when its on for balance
		force = 10 //stunbaton damage
		attack_verb = list("smacked", "struck", "cracked", "beaten")
	else
		to_chat(user, "<span class ='notice'>You collapse the baton.</span>")
		icon_state = "telebaton_0"
		item_state = null //no sprite for concealment even when in hand
		slot_flags = SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = 0 //not so robust now
		attack_verb = list("hit", "poked")

	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)

/obj/item/weapon/melee/supermatter_sword
	name = "supermatter sword"
	desc = "In a station full of bad ideas, this might just be the worst."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "supermatter_sword"
	item_state = "supermatter_sword"
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	force = 0.001
	armour_penetration = 1000
	var/obj/machinery/power/supermatter_shard/shard
	var/balanced = 1
	origin_tech = "combat=7;materials=6"

/obj/item/weapon/melee/supermatter_sword/New()
	..()
	shard = new /obj/machinery/power/supermatter_shard(src)
	qdel(shard.countdown)
	shard.countdown = null
	START_PROCESSING(SSobj, src)
	visible_message("<span class='warning'>[src] appears, balanced ever so perfectly on its hilt. This isn't ominous at all.</span>")

/obj/item/weapon/melee/supermatter_sword/process()
	if(balanced || throwing || ismob(src.loc) || isnull(src.loc))
		return
	if(!isturf(src.loc))
		var/atom/target = src.loc
		loc = target.loc
		consume_everything(target)
	else
		var/turf/T = get_turf(src)
		if(!isspaceturf(T))
			consume_turf(T)

/obj/item/weapon/melee/supermatter_sword/afterattack(target, mob/user, proximity_flag)
	if(user && target == user)
		user.drop_item()
	if(proximity_flag)
		consume_everything(target)
	..()

/obj/item/weapon/melee/supermatter_sword/throw_impact(target)
	..()
	if(ismob(target))
		var/mob/M
		if(src.loc == M)
			M.drop_item()
	consume_everything(target)

/obj/item/weapon/melee/supermatter_sword/pickup(user)
	..()
	balanced = 0

/obj/item/weapon/melee/supermatter_sword/ex_act(severity, target)
	visible_message("<span class='danger'>The blast wave smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything()

/obj/item/weapon/melee/supermatter_sword/acid_act()
	visible_message("<span class='danger'>The acid smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything()

/obj/item/weapon/melee/supermatter_sword/bullet_act(obj/item/projectile/P)
	visible_message("<span class='danger'>[P] smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	consume_everything()

/obj/item/weapon/melee/supermatter_sword/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] touches [src]'s blade. It looks like [user.p_theyre()] tired of waiting for the radiation to kill [user.p_them()]!</span>")
	user.drop_item()
	shard.Bumped(user)

/obj/item/weapon/melee/supermatter_sword/proc/consume_everything(target)
	if(isnull(target))
		shard.Consume()
	else if(!isturf(target))
		shard.Bumped(target)
	else
		consume_turf(target)

/obj/item/weapon/melee/supermatter_sword/proc/consume_turf(turf/T)
	if(istype(T, T.baseturf))
		return //Can't void the void, baby!
	playsound(T, 'sound/effects/supermatter.ogg', 50, 1)
	T.visible_message("<span class='danger'>[T] smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	shard.Consume()
	T.ChangeTurf(T.baseturf)
	T.CalculateAdjacentTurfs()

/obj/item/weapon/melee/supermatter_sword/add_blood(list/blood_dna)
	return 0

/obj/item/weapon/melee/curator_whip
	name = "curator's whip"
	desc = "Somewhat eccentric and outdated, it still stings like hell to be hit by."
	icon_state = "whip"
	item_state = "chain"
	slot_flags = SLOT_BELT
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/chainhit.ogg'

/obj/item/weapon/melee/curator_whip/afterattack(target, mob/user, proximity_flag)
	if(ishuman(target) && proximity_flag)
		var/mob/living/carbon/human/H = target
		H.drop_all_held_items()
		H.visible_message("<span class='danger'>[user] disarms [H]!</span>", "<span class='userdanger'>[user] disarmed you!</span>")
	..()
