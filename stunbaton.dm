/obj/item/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("beaten")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)

	var/stunforce = 140
	var/status = 0
	var/obj/item/stock_parts/cell/cell
	var/hitcost = 1000
	var/throw_hit_chance = 35
	var/preload_cell_type //if not empty the baton starts with this type of cell

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/melee/baton/Initialize()
	. = ..()
	if(preload_cell_type)
		if(!ispath(preload_cell_type,/obj/item/stock_parts/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	update_icon()

/obj/item/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	//Only mob/living types have stun handling
	if(status && prob(throw_hit_chance) && iscarbon(hit_atom))
		baton_stun(hit_atom)

/obj/item/melee/baton/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/proc/deductcharge(chrgdeductamt)
	if(cell)
		//Note this value returned is significant, as it will determine
		//if a stun is applied or not
		. = cell.use(chrgdeductamt)
		if(status && cell.charge < hitcost)
			//we're below minimum, turn off
			status = 0
			update_icon()
			playsound(loc, "sparks", 75, 1, -1)


/obj/item/melee/baton/update_icon()
	if(status)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/melee/baton/examine(mob/user)
	..()
	if(cell)
		to_chat(user, "<span class='notice'>\The [src] is [round(cell.percent())]% charged.</span>")
	else
		to_chat(user, "<span class='warning'>\The [src] does not have a power source installed.</span>")

/obj/item/melee/baton/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		else
			if(C.maxcharge < hitcost)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			update_icon()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(cell)
			cell.update_icon()
			cell.forceMove(get_turf(src))
			cell = null
			to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")
			status = 0
			update_icon()
	else
		return ..()

/obj/item/melee/baton/attack_self(mob/user)
	if(cell && cell.charge > hitcost)
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
		playsound(loc, "sparks", 75, 1, -1)
	else
		status = 0
		if(!cell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/attack(mob/M, mob/living/carbon/human/user)
	if(status && user.has_trait(TRAIT_CLUMSY) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Paralyze(stunforce*3)
		deductcharge(hitcost)
		return

	if(iscyborg(M))
		..()
		return


	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(check_martial_counter(L, user))
			return

	if(user.a_intent != INTENT_HARM)
		if(status)
			if(baton_stun(M, user))
				user.do_attack_animation(M)
				return
		else
			M.visible_message("<span class='warning'>[user] has prodded [M] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
	else
		if(status)
			baton_stun(M, user)
		..()


/obj/item/melee/baton/proc/baton_stun(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/weapons/genhit.ogg', 50, 1)
			return 0
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return 0
	else
		if(!deductcharge(hitcost))
			return 0

	L.Paralyze(stunforce)
	L.apply_effect(EFFECT_STUTTER, stunforce)
	SEND_SIGNAL(L, COMSIG_LIVING_MINOR_SHOCK)
	if(user)
		L.lastattacker = user.real_name
		L.lastattackerckey = user.ckey
		L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
								"<span class='userdanger'>[user] has stunned you with [src]!</span>")
		log_combat(user, L, "stunned")

	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(GLOB.hit_appends)


	return 1

/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		deductcharge(1000 / severity)

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	item_state = "prod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	stunforce = 100
	hitcost = 2000
	throw_hit_chance = 10
	slot_flags = ITEM_SLOT_BACK
	var/obj/item/assembly/igniter/sparkler = 0

/obj/item/melee/baton/cattleprod/Initialize()
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/cattleprod/baton_stun()
	if(sparkler.activate())
		..()

//Security Critical Aeromation Matrices (SCAMs, or Stun-gun Boomerangs). Heavily borrowed from the Bananium Shield Code.

/obj/item/melee/baton/scam
	name = "SCAM Boomerang"
	desc = "A device invented in 2486 for the great Space Emu War by the future confederacy of Neo-Australia, these high-tech boomerangs also work exceptionally well at stunning crewmembers. Just be careful to catch it when you thow!"
	throw_speed = 1
	icon_state = "boomerang"
	item_state = "baton"
	force = 5
	throwforce = 5
	throw_range = 5
	stunforce = 100
	hitcost = 2000
	throw_hit_chance = 99  //Have you prayed today?

/obj/item/melee/baton/scam/Initialize()
	. = ..()

/obj/item/melee/baton/scam/attack_self(mob/living/carbon/human/user)
	..()

/obj/item/melee/baton/scam/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force)
	if(status==1)
		if(iscarbon(thrower))
			var/mob/living/carbon/C = thrower
			C.throw_mode_off() //so they can catch it on the return.
	return ..()

/obj/item/melee/baton/scam/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(status==1)
		var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
		if(iscarbon(hit_atom) && !caught)//if they are a carbon and they didn't catch it
			if(status==1 && prob(throw_hit_chance) && iscarbon(hit_atom))
				baton_stun(hit_atom)
		if(thrownby && !caught)
			sleep(1)
			throw_at(thrownby, throw_range+2, throw_speed, null, TRUE)
	else
		return ..()

/obj/item/melee/baton/scam/Initialize()
	. = ..()

/obj/item/melee/baton/scam/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/upgraded


/obj/item/melee/baton/scam/update_icon()
	if(status)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]"