#define WHITE_TEAM "White"
#define RED_TEAM "Blue"
#define BLUE_TEAM "Red"
#define CTF_RESPAWN_COOLDOWN 150 // 15 seconds
#define FLAG_RETURN_TIME 200 // 20 seconds



/obj/item/weapon/twohanded/required/ctf
	name = "banner"
	icon = 'icons/obj/items.dmi'
	icon_state = "banner"
	item_state = "banner"
	desc = "A banner with Nanotrasen's logo on it."
	slowdown = 2
	throw_speed = 0
	var/team = WHITE_TEAM
	var/reset_cooldown = 0

/obj/item/weapon/twohanded/required/ctf/process()
	if(world.time > reset_cooldown)
		src.loc = initial(src.loc)
		for(var/mob/M in player_list)
			if (M.z == src.z)
				M << "<span class='userdanger'>/The [src] has been returned to base!</span>"
		SSobj.processing.Remove(src)

/obj/item/weapon/twohanded/required/ctf/attack_hand(mob/living/user)
	if (!user)
		return
	if(user.faction == team)
		user << "You can't move your own flag!"
		return

	pickup(user)
	for(var/mob/M in player_list)
		if (M.z == src.z)
			M << "<span class='userdanger'>/The [src] has been taken!</span>"
	if(!user.put_in_active_hand(src))
		dropped(user)
		return
	for(var/mob/M in player_list)
		if (M.z == src.z)
			M << "<span class='userdanger'>/The [src] has been taken!</span>"
	SSobj.processing.Remove(src)

/obj/item/weapon/twohanded/required/ctf/dropped(mob/user)
	reset_cooldown = world.time + 200 //20 seconds
	SSobj.processing |= src
	for(var/mob/M in player_list)
		if (M.z == src.z)
			M << "<span class='userdanger'>/The [src] has been dropped!</span>"


/obj/item/weapon/twohanded/required/ctf/red
	name = "red flag"
	icon_state = "banner-red"
	item_state = "banner-red"
	desc = "A red banner, used to play capture the flag."


/obj/item/weapon/twohanded/required/ctf/blue
	name = "blue flag"
	icon_state = "banner-blue"
	item_state = "banner-blue"
	desc = "A blue banner, used to play capture the flag."



/obj/machinery/capture_the_flag
	name = "CTF Controller"
	desc = "Used for running friendly games of capture the flag."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	var/team = WHITE_TEAM
	var/points = 0
	var/points_to_win = 3
	var/list/team_members = list()
	var/ctf_enabled = FALSE
	var/ctf_gear = /datum/outfit/ctf

/obj/machinery/capture_the_flag/red
	team = RED_TEAM
	ctf_gear = /datum/outfit/ctf/red

/obj/machinery/capture_the_flag/blue
	team = BLUE_TEAM
	ctf_gear = /datum/outfit/ctf/blue

/obj/machinery/capture_the_flag/attack_ghost(mob/user)
	if(ctf_enabled == FALSE)
		return
	if(user.ckey in team_members)
		if(user.timeofdeath + CTF_RESPAWN_COOLDOWN < world.time) //If we've been dead for at least 15 seconds)
			spawn_team_member(user)
	for(var/obj/machinery/capture_the_flag/CTF in machines)
		if(CTF == src || CTF.ctf_enabled == FALSE)
			continue
		if(CTF.team_members.len > src.team_members.len)
			user << "[src] has more team members than [CTF]. Try joining [CTF.team] to even things up."
			return
		if(user.ckey in CTF.team_members)
			user << "No switching teams while the round is going!"
	team_members |= user.ckey
	var/client/new_team_member = user.client
	spawn_team_member(new_team_member)

/obj/machinery/capture_the_flag/proc/spawn_team_member(client/new_team_member)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(src))
	new_team_member.prefs.copy_to(M)
	M.key = new_team_member.key
	M.faction = team
	M.equipOutfit(ctf_gear)

/obj/machinery/capture_the_flag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/twohanded/required/ctf))
		var/obj/item/weapon/twohanded/required/ctf/flag = I
		if(flag.team != src.team)
			for(var/mob/M in player_list)
				if (M.z == src.z)
					M << "<span class='userdanger'>[user.real_name] has captured /the [src], scoring a point for [team] team! They now have [points]/[points_to_win] points!</span>"
		if(points == points_to_win)
			victory()



/obj/machinery/capture_the_flag/proc/victory()
	for(var/mob/M in player_list)
		if (M.z == src.z)
			M << "<span class='narsie'>[team] team wins!</span>"
			M.dust()
	for(var/obj/machinery/capture_the_flag/CTF in machines)
		points = 0
		ctf_enabled = FALSE
		team_members = list()


/obj/item/weapon/gun/projectile/automatic/pistol/deagle/CTF
	desc = "This looks like it could really hurt in melee."
	force = 50

/obj/item/weapon/gun/projectile/automatic/wt550/CTF
	desc = "This looks like it could relaly hurt in melee."
	force = 50

/datum/outfit/ctf
	name = "CTF"
	/obj/item/device/radio/headset
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/weapon/card/id/syndicate
	belt = /obj/item/weapon/gun/projectile/automatic/pistol/deagle/CTF
	l_pocket = /obj/item/ammo_box/magazine/wt550m9
	r_pocket = /obj/item/ammo_box/magazine/wt550m9
	r_hand = /obj/item/weapon/gun/projectile/automatic/wt550/CTF

/datum/outfit/ctf/red
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/red

/datum/outfit/ctf/blue
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue

/datum/outfit/ctf/red/post_equip(mob/living/carbon/human/H)
	var/obj/item/device/radio/R = H.ears
	R.set_frequency(SYND_FREQ)
	R.freqlock = 1

/datum/outfit/ctf/blue/post_equip(mob/living/carbon/human/H)
	var/obj/item/device/radio/R = H.ears
	R.set_frequency(CENTCOM_FREQ)
	R.freqlock = 1



/obj/structure/divine/trap/ctf
	name = "Spawn protection"
	desc = "Stay outta the enemy spawn!"
	icon_state = "trap"
	var/team = WHITE_TEAM
	time_between_triggers = 0
	alpha = 255

/obj/structure/divine/trap/examine(mob/user)
	return

/obj/structure/divine/trap/ctf/trap_effect(mob/living/L)
	if(L.faction != src.team)
		L << "<span class='danger'><B>Stay out of the enemy spawn!</B></span>"
		L.dust()


/obj/structure/divine/trap/ctf/red
	team = RED_TEAM
	icon_state = "trap-fire"

/obj/structure/divine/trap/ctf/blue
	team = BLUE_TEAM
	icon_state = "trap-frost"

/obj/structure/barricade/security/CTF
	health = INFINITY

//Areas

/area/ctf
	name = "Capture the Flag"
	icon_state = "yellow"
	requires_power = 0
	has_gravity = 1

/area/ctf/control_room
	name = "Control Room A"

/area/ctf/control_room2
	name = "Control Room B"

/area/ctf/central
	name = "Central"

/area/ctf/main_hall
	name = "Main Hall A"

/area/ctf/main_hall2
	name = "Main Hall B"

/area/ctf/corridor
	name = "Corridor A"

/area/ctf/corridor2
	name = "Corridor B"

/area/ctf/flag_room
	name = "Flag Room A"

/area/ctf/flag_room2
	name = "Flag Room B"