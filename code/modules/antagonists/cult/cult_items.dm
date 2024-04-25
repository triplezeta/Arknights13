/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon = 'icons/obj/antags/cult/items.dmi'
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/melee/cultblade/dagger
	name = "ritual dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
	inhand_icon_state = "cultdagger"
	worn_icon_state = "render"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	block_chance = 25
	wound_bonus = -10
	bare_wound_bonus = 20
	armour_penetration = 35
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/melee/cultblade/dagger/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/blood.dmi' , icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_dagger", silicon_image)

	var/examine_text = {"Allows the scribing of blood runes of the cult of Nar'Sie.
Hitting a cult structure will unanchor or reanchor it. Cult Girders will be destroyed in a single blow.
Can be used to scrape blood runes away, removing any trace of them.
Striking another cultist with it will purge all holy water from them and transform it into unholy water.
Striking a noncultist, however, will tear their flesh."}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text))

/obj/item/melee/cultblade/dagger/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	var/block_message = "[owner] parries [attack_text] with [src]"
	if(owner.get_active_held_item() != src)
		block_message = "[owner] parries [attack_text] with [src] in their offhand"

	if(IS_CULTIST(owner) && prob(final_block_chance) && attack_type != PROJECTILE_ATTACK)
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		owner.visible_message(span_danger("[block_message]"))
		return TRUE
	else
		return FALSE

/obj/item/melee/cultblade
	name = "eldritch longsword"
	desc = "A sword humming with unholy energy. It glows with a dim red light."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "cultblade"
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	obj_flags = CONDUCTS_ELECTRICITY
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 30 // whoever balanced this got beat in the head by a bible too many times good lord
	throwforce = 10
	block_chance = 50 // now it's officially a cult esword
	wound_bonus = -50
	bare_wound_bonus = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	// If it can be used at will by any nerd
	var/free_use = FALSE

/obj/item/melee/cultblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 4 SECONDS, \
	effectiveness = 100, \
	)

/obj/item/melee/cultblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(IS_CULTIST(owner) && prob(final_block_chance))
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
		return TRUE
	else
		return FALSE

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!IS_CULTIST(user) && !free_use)
		user.Paralyze(100)
		user.dropItemToGround(src, TRUE)
		user.visible_message(span_warning("A powerful force shoves [user] away from [target]!"), \
				span_cult_large("\"You shouldn't play with sharp things. You'll poke someone's eye out.\""))
		if(ishuman(user))
			var/mob/living/carbon/human/miscreant = user
			miscreant.apply_damage(rand(force/2, force), BRUTE, pick(GLOB.arm_zones))
		else
			user.adjustBruteLoss(rand(force/2,force))
		return
	..()

#define WIELDER_SPELL "wielder_spell"
#define SWORD_SPELL "sword_spell"
#define SWORD_PREFIX "sword_prefix"

GLOBAL_LIST_INIT(heretic_paths_to_haunted_sword_abilities,list(
	// Ash
	PATH_ASH = list(WIELDER_SPELL = /datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash, \
	SWORD_SPELL = /datum/action/cooldown/spell/charged/beam/fire_blast, SWORD_PREFIX = "ashen"), \
	// Flesh
	PATH_FLESH = list(WIELDER_SPELL = /datum/action/cooldown/spell/pointed/blood_siphon, \
	SWORD_SPELL = /datum/action/cooldown/spell/pointed/cleave, SWORD_PREFIX = "bleeding"), \
	// Void
	PATH_VOID = list(WIELDER_SPELL = /datum/action/cooldown/spell/pointed/void_phase, \
	SWORD_SPELL = /datum/action/cooldown/spell/cone/staggered/cone_of_cold/void, SWORD_PREFIX = "icy"), \
	// Blade
	PATH_BLADE = list(WIELDER_SPELL = /datum/action/cooldown/spell/pointed/projectile/furious_steel/haunted, \
	SWORD_SPELL = /datum/action/cooldown/spell/pointed/projectile/furious_steel/solo, SWORD_PREFIX = "keen"), \
	// Rust
	PATH_RUST = list(WIELDER_SPELL = /datum/action/cooldown/spell/cone/staggered/entropic_plume, \
	SWORD_SPELL = list(/datum/action/cooldown/spell/aoe/rust_conversion/small, /datum/action/cooldown/spell/pointed/rust_construction), SWORD_PREFIX = "rusted"), \
	// Cosmic
	PATH_COSMIC = list(WIELDER_SPELL = /datum/action/cooldown/spell/conjure/cosmic_expansion, \
	SWORD_SPELL = /datum/action/cooldown/spell/pointed/projectile/star_blast, SWORD_PREFIX = "astral"), \
	// Lock
	PATH_LOCK = list(WIELDER_SPELL = /datum/action/cooldown/spell/pointed/burglar_finesse, \
	SWORD_SPELL = /datum/action/cooldown/spell/pointed/apetra_vulnera, SWORD_PREFIX = "incisive"), \
	// Moon
	PATH_MOON = list(WIELDER_SPELL = /datum/action/cooldown/spell/pointed/projectile/moon_parade, \
	SWORD_SPELL = /datum/action/cooldown/spell/pointed/moon_smile, SWORD_PREFIX = "shimmering"), \
	// Starter
	PATH_START = list(WIELDER_SPELL = null, SWORD_SPELL = null, SWORD_PREFIX = "nascent") // lol loser
))

/* List of issues to fix0

7. check to make sure you cant spawn holes next to eachother doesnt work (fixed?)

B. Proteon hole turns into a monser when rusted // later

*/

/mob/living/carbon/human/proc/test(hooman = pick(TRUE,FALSE))
	var/datum/antagonist/heretic/heredat = mind.add_antag_datum(/datum/antagonist/heretic)
	heredat.heretic_path = tgui_input_list(src, "x", "y", list(PATH_RUST,PATH_FLESH,PATH_ASH,PATH_VOID,PATH_BLADE,PATH_COSMIC,PATH_LOCK,PATH_MOON))
	var/obj/item/melee/cultblade/haunted/evil = new(loc, src)
	//evil.bind_soul(src,null)
	if(hooman)
		var/mob/living/carbon/human/homan = new(loc)
		homan.put_in_hands(evil)

/obj/item/melee/cultblade/haunted
	name = "haunted longsword"
	desc = "An eerie sword with a blade that is less 'black' than it is 'absolute nothingness'. It glows with furious, restrained green energy."
	icon_state = "hauntedblade"
	inhand_icon_state = "hauntedblade"
	worn_icon_state = "hauntedblade"
	force = 35
	throwforce = 15
	block_chance = 55
	wound_bonus = -25
	bare_wound_bonus = 30
	free_use = TRUE
	light_color = COLOR_BLACK
	light_system = OVERLAY_LIGHT
	light_range = 4
	// holder for the actual action when created.
	var/datum/action/cooldown/spell/path_wielder_action
	var/mob/living/trapped_entity
	var/heretic_path

/obj/item/melee/cultblade/haunted/Initialize(mapload, mob/soul_to_bind, mob/awakener, no_binding)
	. = ..()

	if(!no_binding)
		bind_soul(soul_to_bind, awakener)
	ADD_TRAIT(src, TRAIT_CASTABLE_LOC, INNATE_TRAIT)
	AddElement(/datum/element/heretic_focus)

/obj/item/melee/cultblade/haunted/proc/bind_soul(mob/soul_to_bind, mob/awakener)

	var/datum/mind/trapped_mind = soul_to_bind.mind

	if(soul_to_bind)
		AddComponent(/datum/component/spirit_holding,\
			soul_to_bind = soul_to_bind.mind,\
			awakener = awakener,\
			allow_renaming = FALSE,\
		)

	// Get the heretic's new body and antag datum.
	trapped_entity = trapped_mind.current
	var/datum/antagonist/heretic/heretic_holder = IS_HERETIC(trapped_entity)
	if(!heretic_holder)
		CRASH("[soul_to_bind] not a heretic on the heretic soul blade.")

	// Set the sword's path for spell selection.
	heretic_path = heretic_holder.heretic_path

	// Copy the objectives to keep for roundend, remove the datum as neither us nor the heretic need it anymore
	var/list/copied_objectives = heretic_holder.objectives.Copy()
	trapped_entity.mind.remove_antag_datum(/datum/antagonist/heretic)

	// Add the fallen antag datum, give them a heads-up of what's happening.
	var/datum/antagonist/soultrapped_heretic/fallen = trapped_entity.mind.add_antag_datum(/datum/antagonist/soultrapped_heretic)
	fallen.objectives = copied_objectives
	// Unrelated bug: Objectives dont show up on the you are X thing as they are varsetted post-facto
	to_chat(trapped_entity, span_alert("You've been sacrificed to the Enemy, and trapped inside a haunted blade! While you cannot escape, you may decide by yourself to be a nuisance with the few abilities you still have, or if you wish to aid whoever wields it."))

	// Assigning the spells to give to the wielder and spirit.
	// Let them cast the given spell.
	ADD_TRAIT(trapped_entity, TRAIT_ALLOW_HERETIC_CASTING, INNATE_TRAIT)

	var/list/path_spells = GLOB.heretic_paths_to_haunted_sword_abilities[heretic_path]

	var/list/wielder_spells = list(path_spells[WIELDER_SPELL])
	var/list/sword_spells = list(path_spells[SWORD_SPELL])

	name = path_spells[SWORD_PREFIX] + " " + name

	// Granting the spells. The sword spirit gains it outright, while it's just defined for wielders to be added on pickup.

	if(length(sword_spells))
		for(var/datum/action/cooldown/spell/sword_spell as anything in sword_spells)
			sword_spell = new sword_spell(trapped_entity)
			sword_spell.Grant(trapped_entity)

	if(length(wielder_spells))
		for(var/datum/action/cooldown/spell/wielder_spell as anything in wielder_spells)
			path_wielder_action = new wielder_spell(src)

/obj/item/melee/cultblade/haunted/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_HANDS)
		path_wielder_action?.Grant(user)

/obj/item/melee/cultblade/haunted/dropped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		path_wielder_action?.Remove(user)

/obj/item/melee/cultblade/haunted/proc/cebug(mob/dude,mob/man)
	bind_soul(dude, man)

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 19 //can't break normal airlocks
	item_flags = NEEDS_PERMIT | DROPDEL
	flags_1 = NONE
	block_chance = 25 //these dweebs don't get full block chance, because they're free cultists
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/melee/cultblade/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/melee/cultblade/pickup(mob/living/user)
	..()
	if(!IS_CULTIST(user) && !free_use)
		to_chat(user, span_cult_large("\"I wouldn't advise that.\""))

/datum/action/innate/dash/cult
	name = "Rend the Veil"
	desc = "Use the sword to shear open the flimsy fabric of this reality and teleport to your target."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "phaseshift"
	dash_sound = 'sound/magic/enter_blood.ogg'
	recharge_sound = 'sound/magic/exit_blood.ogg'
	beam_effect = "sendbeam"
	phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	phaseout = /obj/effect/temp_visual/dir_setting/cult/phase/out

/datum/action/innate/dash/cult/IsAvailable(feedback = FALSE)
	if(IS_CULTIST(owner) && current_charges)
		return TRUE
	else
		return FALSE

/obj/item/restraints/legcuffs/bola/cult
	name = "\improper Nar'Sien bola"
	desc = "A strong bola, bound with dark magic that allows it to pass harmlessly through Nar'Sien cultists. Throw it to trip and slow your victim."
	icon_state = "bola_cult"
	inhand_icon_state = "bola_cult"
	breakouttime = 6 SECONDS
	knockdown = 30

#define CULT_BOLA_PICKUP_STUN (6 SECONDS)
/obj/item/restraints/legcuffs/bola/cult/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()

	if(IS_CULTIST(user) || !iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	if(user.num_legs < 2 || carbon_user.legcuffed) //if they can't be ensnared, stun for the same time as it takes to breakout of bola
		to_chat(user, span_cult_large("\"I wouldn't advise that.\""))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(CULT_BOLA_PICKUP_STUN)
	else
		to_chat(user, span_warning("The bola seems to take on a life of its own!"))
		ensnare(user)
#undef CULT_BOLA_PICKUP_STUN


/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/mob/hit_mob = hit_atom
	if (istype(hit_mob) && IS_CULTIST(hit_mob))
		return
	. = ..()


/obj/item/clothing/head/hooded/cult_hoodie
	name = "ancient cultist hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "culthood"
	inhand_icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor_type = /datum/armor/hooded_cult_hoodie
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/datum/armor/hooded_cult_hoodie
	melee = 40
	bullet = 30
	laser = 40
	energy = 40
	bomb = 25
	bio = 10
	fire = 10
	acid = 10

/obj/item/clothing/suit/hooded/cultrobes
	name = "ancient cultist robes"
	desc = "A ragged, dusty set of robes. Strange letters line the inside."
	icon_state = "cultrobes"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/hooded_cultrobes
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie
	/// Whether the hood is flipped up
	var/hood_up = FALSE

/// Called when the hood is worn
/obj/item/clothing/suit/hooded/cultrobes/on_hood_up(obj/item/clothing/head/hooded/hood)
	hood_up = TRUE

/// Called when the hood is hidden
/obj/item/clothing/suit/hooded/cultrobes/on_hood_down(obj/item/clothing/head/hooded/hood)
	hood_up = FALSE

/datum/armor/hooded_cultrobes
	melee = 40
	bullet = 30
	laser = 40
	energy = 40
	bomb = 25
	bio = 10
	fire = 10
	acid = 10

/obj/item/clothing/head/hooded/cult_hoodie/alt
	name = "cultist hood"
	desc = "An armored hood worn by the followers of Nar'Sie."
	icon_state = "cult_hoodalt"
	inhand_icon_state = null

/obj/item/clothing/suit/hooded/cultrobes/alt
	name = "cultist robes"
	desc = "An armored set of robes worn by the followers of Nar'Sie."
	icon_state = "cultrobesalt"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/alt

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/head/wizard/magus
	name = "magus helm"
	icon_state = "magus"
	inhand_icon_state = null
	desc = "A helm worn by the followers of Nar'Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor_type = /datum/armor/wizard_magus
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/datum/armor/wizard_magus
	melee = 50
	bullet = 30
	laser = 50
	energy = 50
	bomb = 25
	bio = 10
	fire = 10
	acid = 10

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar'Sie."
	icon_state = "magusred"
	icon = 'icons/obj/clothing/suits/wizard.dmi'
	worn_icon = 'icons/mob/clothing/suits/wizard.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/suit_magusred
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/datum/armor/suit_magusred
	melee = 50
	bullet = 30
	laser = 50
	energy = 50
	bomb = 25
	bio = 10
	fire = 10
	acid = 10

/obj/item/clothing/suit/hooded/cultrobes/hardened
	name = "\improper Nar'Sien hardened armor"
	desc = "A heavily-armored exosuit worn by warriors of the Nar'Sien cult. It can withstand hard vacuum."
	icon_state = "cult_armor"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade, /obj/item/tank/internals)
	armor_type = /datum/armor/cultrobes_hardened
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/hardened
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	flags_inv = HIDEGLOVES | HIDEJUMPSUIT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = NONE

/datum/armor/cultrobes_hardened
	melee = 50
	bullet = 40
	laser = 50
	energy = 60
	bomb = 50
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/head/hooded/cult_hoodie/hardened
	name = "\improper Nar'Sien hardened helmet"
	desc = "A heavily-armored helmet worn by warriors of the Nar'Sien cult. It can withstand hard vacuum."
	icon_state = "cult_helmet"
	inhand_icon_state = null
	armor_type = /datum/armor/cult_hoodie_hardened
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | STACKABLE_HELMET_EXEMPT | HEADINTERNALS
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE

/datum/armor/cult_hoodie_hardened
	melee = 50
	bullet = 40
	laser = 50
	energy = 60
	bomb = 50
	bio = 100
	fire = 100
	acid = 100

/obj/item/sharpener/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon = 'icons/obj/antags/cult/items.dmi'
	icon_state = "cult_sharpener"
	uses = 1
	increment = 5
	max = 40
	prefix = "darkened"

/obj/item/sharpener/cult/update_icon_state()
	icon_state = "cult_sharpener[(uses == 0) ? "_used" : ""]"
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "Empowered armor which creates a powerful shield around the user."
	icon_state = "cult_armor"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	armor_type = /datum/armor/cultrobes_cult_shield
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/cult_shield

/datum/armor/cultrobes_cult_shield
	melee = 50
	bullet = 40
	laser = 50
	energy = 50
	bomb = 50
	bio = 30
	fire = 50
	acid = 60

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/shielded, \
		recharge_start_delay = 0 SECONDS, \
		shield_icon_file = 'icons/effects/cult/effects.dmi', \
		shield_icon = "shield-cult", \
		run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)), \
	)

/// A proc for callback when the shield breaks, since cult robes are stupid and have different effects
/obj/item/clothing/suit/hooded/cultrobes/cult_shield/proc/shield_damaged(mob/living/wearer, attack_text, new_current_charges)
	wearer.visible_message(span_danger("[wearer]'s robes neutralize [attack_text] in a burst of blood-red sparks!"))
	new /obj/effect/temp_visual/cult/sparks(get_turf(wearer))
	if(new_current_charges == 0)
		wearer.visible_message(span_danger("The runed shield around [wearer] suddenly disappears!"))

/obj/item/clothing/head/hooded/cult_hoodie/cult_shield
	name = "empowered cultist helmet"
	desc = "Empowered helmet which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor_type = /datum/armor/cult_hoodie_cult_shield

/datum/armor/cult_hoodie_cult_shield
	melee = 50
	bullet = 40
	laser = 50
	energy = 50
	bomb = 50
	bio = 30
	fire = 50
	acid = 60

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cult_large("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage. Provides an even greater speed boost if its hood is worn."
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/cultrobes_berserker
	slowdown = -0.3 //the hood gives an additional -0.3 if you have it flipped up, for a total of -0.6
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/berserkerhood

/datum/armor/cultrobes_berserker
	melee = -45
	bullet = -45
	laser = -45
	energy = -55
	bomb = -45

/obj/item/clothing/head/hooded/cult_hoodie/berserkerhood
	name = "flagellant's hood"
	desc = "A blood-soaked hood infused with dark magic."
	armor_type = /datum/armor/cult_hoodie_berserkerhood
	slowdown = -0.3

/datum/armor/cult_hoodie_berserkerhood
	melee = -45
	bullet = -45
	laser = -45
	energy = -55
	bomb = -45

/obj/item/clothing/suit/hooded/cultrobes/berserker/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cult_large("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "May Nar'Sie guide you through the darkness and shield you from the light."
	flags_cover = GLASSESCOVERSEYES
	name = "zealot's blindfold"
	icon_state = "blindfold"
	inhand_icon_state = "blindfold"
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(user.stat != DEAD && !IS_CULTIST(user) && (slot & ITEM_SLOT_EYES))
		to_chat(user, span_cult_large("\"You want to be blind, do you?\""))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)
		user.adjust_temp_blindness(60 SECONDS)

/obj/item/reagent_containers/cup/beaker/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; reinvigorating to the faithful - this flask may be sipped or thrown."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "unholyflask"
	inhand_icon_state = "holyflask"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/fuel/unholywater = 50)

///how many times can the shuttle be cursed?
#define MAX_SHUTTLE_CURSES 3
///if the max number of shuttle curses are used within this duration, the entire cult gets an achievement
#define SHUTTLE_CURSE_OMFG_TIMESPAN (10 SECONDS)

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the emergency escape shuttle. "
	icon = 'icons/obj/antags/cult/items.dmi'
	icon_state = "shuttlecurse"
	///how many times has the shuttle been cursed so far?
	var/static/totalcurses = 0
	///when was the first shuttle curse?
	var/static/first_curse_time
	///curse messages that have already been used
	var/static/list/remaining_curses

/obj/item/shuttle_curse/attack_self(mob/living/user)
	if(!IS_CULTIST(user))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(100)
		to_chat(user, span_warning("A powerful force shoves you away from [src]!"))
		return
	if(totalcurses >= MAX_SHUTTLE_CURSES)
		to_chat(user, span_warning("You try to shatter the orb, but it remains as solid as a rock!"))
		to_chat(user, span_danger(span_big("It seems that the blood cult has exhausted its ability to curse the emergency escape shuttle. It would be unwise to create more cursed orbs or to continue to try to shatter this one.")))
		return
	if(locate(/obj/narsie) in SSpoints_of_interest.narsies)
		to_chat(user, span_warning("Nar'Sie is already on this plane, there is no delaying the end of all things."))
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 3 MINUTES
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		var/security_num = SSsecurity_level.get_current_level_as_number()
		var/set_coefficient = 1

		if(totalcurses == 0)
			first_curse_time = world.time

		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1
			else
				set_coefficient = 0.5
		var/surplus = timer - (SSshuttle.emergency_call_time * set_coefficient)
		SSshuttle.emergency.setTimer(timer)
		if(surplus > 0)
			SSshuttle.block_recall(surplus)
		totalcurses++
		to_chat(user, span_danger("You shatter the orb! A dark essence spirals into the air, then disappears."))
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, TRUE)

		if(!remaining_curses)
			remaining_curses = strings(CULT_SHUTTLE_CURSE, "curse_announce")

		var/curse_message = pick_n_take(remaining_curses) || "Something has gone horrendously wrong..."

		curse_message += " The shuttle will be delayed by three minutes."
		priority_announce("[curse_message]", "System Failure", 'sound/misc/notice1.ogg')
		if(MAX_SHUTTLE_CURSES-totalcurses <= 0)
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can no longer be cursed. It would be unwise to create more cursed orbs.")))
		else if(MAX_SHUTTLE_CURSES-totalcurses == 1)
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can only be cursed one more time.")))
		else
			to_chat(user, span_danger(span_big("You sense that the emergency escape shuttle can only be cursed [MAX_SHUTTLE_CURSES-totalcurses] more times.")))

		if(totalcurses >= MAX_SHUTTLE_CURSES && (world.time < first_curse_time + SHUTTLE_CURSE_OMFG_TIMESPAN))
			var/omfg_message = pick_list(CULT_SHUTTLE_CURSE, "omfg_announce") || "LEAVE US ALONE!"
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), omfg_message, "Priority Alert", 'sound/misc/announce_syndi.ogg', null, "Nanotrasen Department of Transportation: Central Command"), rand(2 SECONDS, 6 SECONDS))
			for(var/mob/iter_player as anything in GLOB.player_list)
				if(IS_CULTIST(iter_player))
					iter_player.client?.give_award(/datum/award/achievement/misc/cult_shuttle_omfg, iter_player)

		qdel(src)

#undef MAX_SHUTTLE_CURSES

/obj/item/proteon_orb
	name = "summoning orb"
	desc = "An eerie translucent orb that feels impossibly light. Legends say summoning orbs are created from corrupted scrying orbs. If you hold it close to your ears, you can hear the screams of the damned."
	icon = 'icons/obj/antags/cult/items.dmi'
	icon_state = "summoning_orb"
	light_range = 3
	light_color = "#ff0000"

/obj/item/proteon_orb/examine(mob/user)
	. = ..()
	if(!IS_CULTIST(user) && isliving(user))
		var/mob/living/luser = user
		luser.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
		. += span_danger("It hurts just to look at it. Better keep away.")
	else
		. += span_cult("It can be used to create a gateway to Nar'Sie's domain, which will summon weak, sentient constructs over time.")

/obj/item/proteon_orb/attack_self(mob/living/user)

	var/list/turfs_to_scan = detect_room(get_turf(user), max_size = 40)

	if(!IS_CULTIST(user))
		to_chat(user, span_cult_large("\"You want to enter my domain? Go ahead.\""))
		turfs_to_scan = null // narsie wants to have some fun and the veil wont stop her

	for(var/turf/hole_candidate as anything in turfs_to_scan)
		if(locate(/obj/structure/spawner/sentient/proteon_spawner) in hole_candidate)
			to_chat(user, span_cult_bold("There's a gateway too close nearby. The veil is not yet weak enough to allow such close rips in its fabric."))
			return
	to_chat(user, span_cult_bold_italic("You focus on [src] and direct it into the ground. It rumbles..."))

	var/turf/open/hole_spot = get_turf(user)
	if(!istype(hole_spot) || istype(hole_spot, /turf/open/space))
		to_chat(user, span_notice("This is not a suitable spot."))
		return

	INVOKE_ASYNC(hole_spot, TYPE_PROC_REF(/turf/open, quake_gateway), user)
	qdel(src)

/turf/open/proc/quake_gateway(mob/living/user)
	Shake(2, 2, 5 SECONDS)
	narsie_act(TRUE, TRUE, 100)
	var/fucked = FALSE
	if(!IS_CULTIST(user))
		fucked = TRUE
		ADD_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src)) // keep em in place
		user.add_atom_colour(COLOR_CULT_RED, TEMPORARY_COLOUR_PRIORITY)
		user.visible_message(span_cult_bold("Dark tendrils appear from the ground and root [user] in place!"))
	sleep(5 SECONDS) // can we still use these or. i mean its async
	new /obj/structure/spawner/sentient/proteon_spawner(src)
	visible_message(span_cult_bold("A mysterious hole appears out of nowhere!"))
	if(!fucked)
		return
	if(get_turf(user) != src) // they get away. for now
		REMOVE_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src))
		return
	user.visible_message(span_cult_bold("[user] is pulled into the portal through an infinitesmally minuscule hole, shredding [user.p_their()] body!"))
	user.visible_message(span_cult_italic("An unusually large construct appears through the portal..."))
	user.gib() // total destruction
	var/mob/living/basic/construct/proteon/hostile/remnant = new(get_step_rand(src))
	remnant.name = "[user]" // no, they do not become it
	remnant.transform *= 1.5

/obj/item/cult_shift
	name = "veil shifter"
	desc = "This relic instantly teleports you, and anything you're pulling, forward by a moderate distance."
	icon = 'icons/obj/antags/cult/items.dmi'
	icon_state ="shifter"
	///How many uses does the item have before becoming inert
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += span_cult("It has [uses] use\s remaining.")
	else
		. += span_cult("It seems drained.")

///Handles teleporting the atom we're pulling along with us when using the shifter
/obj/item/cult_shift/proc/handle_teleport_grab(turf/target_turf, mob/user)
	var/mob/living/carbon/pulling_user = user
	if(pulling_user.pulling)
		var/atom/movable/pulled = pulling_user.pulling
		do_teleport(pulled, target_turf, channel = TELEPORT_CHANNEL_CULT)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, span_warning("\The [src] is dull and unmoving in your hands."))
		return
	if(!IS_CULTIST(user))
		user.dropItemToGround(src, TRUE)
		step(src, pick(GLOB.alldirs))
		to_chat(user, span_warning("\The [src] flickers out of your hands, your connection to this dimension is too strong!"))
		return

	//The user of the shifter
	var/mob/living/carbon/user_cultist = user
	//Initial teleport location
	var/turf/mobloc = get_turf(user_cultist)
	//Teleport target turf, with some error to spice it up
	var/turf/destination = get_teleport_loc(location = mobloc, target = user_cultist, distance = 9, density_check = TRUE, errorx = 3, errory = 1, eoffsety = 1)
	//The atom the user was pulling when using the shifter; we handle it here before teleporting the user as to not lose their 'pulling' var
	var/atom/movable/pulled = handle_teleport_grab(destination, user_cultist)

	if(!destination || !do_teleport(user_cultist, destination, channel = TELEPORT_CHANNEL_CULT))
		playsound(src, 'sound/items/haunted/ghostitemattack.ogg', 100, TRUE)
		balloon_alert(user, "teleport failed!")
		return

	uses--
	if(uses <= 0)
		icon_state = "shifter_drained"

	if(pulled)
		user_cultist.start_pulling(pulled) //forcemove (teleporting) resets pulls, so we need to re-pull

	new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, user_cultist.dir)
	new /obj/effect/temp_visual/dir_setting/cult/phase(destination, user_cultist.dir)

	playsound(mobloc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, 'sound/effects/phasein.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/flashlight/flare/culttorch
	name = "void torch"
	desc = "Used by veteran cultists to instantly transport items to their needful brethren."
	w_class = WEIGHT_CLASS_SMALL
	light_range = 1
	icon_state = "torch"
	inhand_icon_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	color = "#ff0000"
	on_damage = 15
	slot_flags = null
	var/charges = 5
	start_on = TRUE

/obj/item/flashlight/flare/culttorch/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return
	if(!IS_CULTIST(user))
		to_chat(user, "That doesn't seem to do anything useful.")
		return

	if(!isitem(A))
		..()
		to_chat(user, span_warning("\The [src] can only transport items!"))
		return

	. |= AFTERATTACK_PROCESSED_ITEM

	var/list/cultists = list()
	for(var/datum/mind/M as anything in get_antag_minds(/datum/antagonist/cult))
		if(M.current && M.current.stat != DEAD)
			cultists |= M.current
	var/mob/living/cultist_to_receive = tgui_input_list(user, "Who do you wish to call to [src]?", "Followers of the Geometer", (cultists - user))
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(isnull(cultist_to_receive))
		to_chat(user, "<span class='cult italic'>You require a destination!</span>")
		log_game("[key_name(user)]'s Void torch failed - no target.")
		return
	if(cultist_to_receive.stat == DEAD)
		to_chat(user, "<span class='cult italic'>[cultist_to_receive] has died!</span>")
		log_game("[key_name(user)]'s Void torch failed - target died.")
		return
	if(!IS_CULTIST(cultist_to_receive))
		to_chat(user, "<span class='cult italic'>[cultist_to_receive] is not a follower of the Geometer!</span>")
		log_game("[key_name(user)]'s Void torch failed - target was deconverted.")
		return
	if(A in user.get_all_contents())
		to_chat(user, "<span class='cult italic'>[A] must be on a surface in order to teleport it!</span>")
		return
	to_chat(user, "<span class='cult italic'>You ignite [A] with \the [src], turning it to ash, but through the torch's flames you see that [A] has reached [cultist_to_receive]!</span>")
	user.log_message("teleported [A] to [cultist_to_receive] with \the [src].", LOG_GAME)
	cultist_to_receive.put_in_hands(A)
	charges--
	to_chat(user, "\The [src] now has [charges] charge\s.")
	if(charges == 0)
		qdel(src)

/obj/item/melee/cultblade/halberd
	name = "bloody halberd"
	desc = "A halberd with a volatile axehead made from crystallized blood. It seems linked to its creator. And, admittedly, more of a poleaxe than a halberd."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "occultpoleaxe0"
	base_icon_state = "occultpoleaxe"
	inhand_icon_state = "occultpoleaxe0"
	w_class = WEIGHT_CLASS_HUGE
	force = 17
	throwforce = 40
	throw_speed = 2
	armour_penetration = 30
	block_chance = 30
	slot_flags = null
	attack_verb_continuous = list("attacks", "slices", "shreds", "sunders", "lacerates", "cleaves")
	attack_verb_simple = list("attack", "slice", "shred", "sunder", "lacerate", "cleave")
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	var/datum/action/innate/cult/halberd/halberd_act

/obj/item/melee/cultblade/halberd/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 10 SECONDS, \
		effectiveness = 90, \
	)
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 17, \
		force_wielded = 24, \
	)

/obj/item/melee/cultblade/halberd/update_icon_state()
	icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "[base_icon_state]1" : "[base_icon_state]0"
	inhand_icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "[base_icon_state]1" : "[base_icon_state]0"
	return ..()

/obj/item/melee/cultblade/halberd/Destroy()
	if(halberd_act)
		QDEL_NULL(halberd_act)
	return ..()

/obj/item/melee/cultblade/halberd/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/target = hit_atom

		if(IS_CULTIST(target) && target.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			target.visible_message(span_warning("[target] catches [src] out of the air!"))
			return
		if(target.can_block_magic() || IS_CULTIST(target))
			target.visible_message(span_warning("[src] bounces off of [target], as if repelled by an unseen force!"))
			return
		if(!..())
			target.Paralyze(50)
			break_halberd(T)
	else
		..()

/obj/item/melee/cultblade/halberd/proc/break_halberd(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T)
			T.visible_message(span_warning("[src] shatters and melts back into blood!"))
			new /obj/effect/temp_visual/cult/sparks(T)
			new /obj/effect/decal/cleanable/blood/splatter(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/obj/item/melee/cultblade/halberd/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		final_block_chance *= 2
	if(IS_CULTIST(owner) && prob(final_block_chance))
		owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		return TRUE
	else
		return FALSE

/datum/action/innate/cult/halberd
	name = "Bloody Bond"
	desc = "Call the bloody halberd back to your hand!"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon_state = "bloodspear"
	default_button_position = "6:157,4:-2"
	var/obj/item/melee/cultblade/halberd/halberd
	var/cooldown = 0

/datum/action/innate/cult/halberd/Grant(mob/user, obj/blood_halberd)
	. = ..()
	halberd = blood_halberd

/datum/action/innate/cult/halberd/Activate()
	if(owner == halberd.loc || cooldown > world.time)
		return
	var/halberd_location = get_turf(halberd)
	var/owner_location = get_turf(owner)
	if(get_dist(owner_location, halberd_location) > 10)
		to_chat(owner,span_cult("The halberd is too far away!"))
	else
		cooldown = world.time + 20
		if(isliving(halberd.loc))
			var/mob/living/current_owner = halberd.loc
			current_owner.dropItemToGround(halberd)
			current_owner.visible_message(span_warning("An unseen force pulls the bloody halberd from [current_owner]'s hands!"))
		halberd.throw_at(owner, 10, 2, owner)


/obj/item/gun/magic/wand/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	color = "#ff0000"
	ammo_type =  /obj/item/ammo_casing/magic/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/projectile/magic/arcane_barrage/blood
	firing_effect_type = /obj/effect/temp_visual/cult/sparks

/obj/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "mini_leaper"
	nondirectional_sprite = TRUE
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter

/obj/projectile/magic/arcane_barrage/blood/Bump(atom/target)
	. = ..()
	var/turf/our_turf = get_turf(target)
	playsound(our_turf , 'sound/effects/splat.ogg', 50, TRUE)
	new /obj/effect/temp_visual/cult/sparks(our_turf)

/obj/projectile/magic/arcane_barrage/blood/prehit_pierce(atom/target)
	. = ..()
	if(!ismob(target))
		return PROJECTILE_PIERCE_NONE

	var/mob/living/our_target = target
	if(!IS_CULTIST(our_target))
		return PROJECTILE_PIERCE_NONE

	if(iscarbon(our_target) && our_target.stat != DEAD)
		var/mob/living/carbon/carbon_cultist = our_target
		carbon_cultist.reagents.add_reagent(/datum/reagent/fuel/unholywater, 4)
	if(isshade(our_target) || isconstruct(our_target))
		var/mob/living/basic/construct/undead_abomination = our_target
		if(undead_abomination.health + 5 < undead_abomination.maxHealth)
			undead_abomination.adjust_health(-5)
	return PROJECTILE_DELETE_WITHOUT_HITTING

/obj/item/blood_beam
	name = "\improper magical aura"
	desc = "Sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/weapons/hand.dmi'
	lefthand_file = 'icons/mob/inhands/items/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charging = FALSE
	var/firing = FALSE
	var/angle

/obj/item/blood_beam/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/blood_beam/afterattack(atom/A, mob/living/user, proximity_flag, clickparams)
	. = ..()
	if(firing || charging)
		return
	if(ishuman(user))
		angle = get_angle(user, A)
	else
		qdel(src)
		return . | AFTERATTACK_PROCESSED_ITEM
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user)
	if(do_after(user, 9 SECONDS, target = user))
		firing = TRUE
		ADD_TRAIT(user, TRAIT_IMMOBILIZED, CULT_TRAIT)
		INVOKE_ASYNC(src, PROC_REF(pewpew), user, clickparams)
		var/obj/structure/emergency_shield/cult/weak/N = new(user.loc)
		if(do_after(user, 9 SECONDS, target = user))
			user.Paralyze(40)
			to_chat(user, "<span class='cult italic'>You have exhausted the power of this spell!</span>")
		REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, CULT_TRAIT)
		firing = FALSE
		if(N)
			qdel(N)
		qdel(src)
	charging = FALSE

/obj/item/blood_beam/proc/charge(mob/user)
	var/obj/O
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, TRUE)
	for(var/i in 1 to 12)
		if(!charging)
			break
		if(i > 1)
			sleep(1.5 SECONDS)
		if(i < 4)
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune1/inner(user.loc, 30, "#ff0000")
		else
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune5(user.loc, 30, "#ff0000")
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(user.loc, user.dir)
	if(O)
		qdel(O)

/obj/item/blood_beam/proc/pewpew(mob/user, proximity_flag)
	var/turf/targets_from = get_turf(src)
	var/spread = 40
	var/second = FALSE
	var/set_angle = angle
	for(var/i in 1 to 12)
		if(second)
			set_angle = angle - spread
			spread -= 8
		else
			sleep(1.5 SECONDS)
			set_angle = angle + spread
		second = !second //Handles beam firing in pairs
		if(!firing)
			break
		playsound(src, 'sound/magic/exit_blood.ogg', 75, TRUE)
		new /obj/effect/temp_visual/dir_setting/cult/phase(user.loc, user.dir)
		var/turf/temp_target = get_turf_in_angle(set_angle, targets_from, 40)
		for(var/turf/T in get_line(targets_from,temp_target))
			if (locate(/obj/effect/blessing, T))
				temp_target = T
				playsound(T, 'sound/effects/parry.ogg', 50, TRUE)
				new /obj/effect/temp_visual/at_shield(T, T)
				break
			T.narsie_act(TRUE, TRUE)
			for(var/mob/living/target in T.contents)
				if(IS_CULTIST(target))
					new /obj/effect/temp_visual/cult/sparks(T)
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						if(H.stat != DEAD)
							H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 7)
					if(isshade(target) || isconstruct(target))
						var/mob/living/basic/construct/healed_guy = target
						if(healed_guy.health + 15 < healed_guy.maxHealth)
							healed_guy.adjust_health(-15)
						else
							healed_guy.health = healed_guy.maxHealth
				else
					var/mob/living/L = target
					if(L.density)
						L.Paralyze(20)
						L.adjustBruteLoss(45)
						playsound(L, 'sound/hallucinations/wail.ogg', 50, TRUE)
						L.emote("scream")
		user.Beam(temp_target, icon_state="blood_beam", time = 7, beam_type = /obj/effect/ebeam/blood)


/obj/effect/ebeam/blood
	name = "blood beam"

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "An infamous shield used by Nar'Sien sects to confuse and disorient their enemies. Its edges are weighted for use as a throwing weapon - capable of disabling multiple foes with preternatural accuracy."
	icon_state = "mirror_shield" // eshield1 for expanded
	inhand_icon_state = "mirror_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bumps", "prods")
	attack_verb_simple = list("bump", "prod")
	hitsound = 'sound/weapons/smash.ogg'
	block_sound = 'sound/weapons/effects/ric5.ogg'
	var/illusions = 2

/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(IS_CULTIST(owner))
		if(attack_type == PROJECTILE_ATTACK)
			if(damage_type == BRUTE || damage_type == BURN)
				if(damage >= 30)
					var/turf/T = get_turf(owner)
					T.visible_message(span_warning("The sheer force from [hitby] shatters the mirror shield!"))
					new /obj/effect/temp_visual/cult/sparks(T)
					playsound(T, 'sound/effects/glassbr3.ogg', 100)
					owner.Paralyze(25)
					qdel(src)
					return FALSE
			var/obj/projectile/projectile = hitby
			if(projectile.reflectable & REFLECT_NORMAL)
				return FALSE //To avoid reflection chance double-dipping with block chance
		. = ..()
		if(.)
			if(illusions > 0)
				illusions--
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/shield/mirror, readd)), 45 SECONDS)
				if(prob(60))
					var/mob/living/simple_animal/hostile/illusion/M = new(owner.loc)
					M.faction = list(FACTION_CULT)
					M.Copy_Parent(owner, 70, 10, 5)
					M.move_to_delay = owner.cached_multiplicative_slowdown
				else
					var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
					E.Copy_Parent(owner, 70, 10)
					E.GiveTarget(owner)
					E.Goto(owner, owner.cached_multiplicative_slowdown, E.minimum_distance)
			return TRUE
	else
		if(prob(50))
			var/mob/living/simple_animal/hostile/illusion/H = new(owner.loc)
			H.Copy_Parent(owner, 100, 20, 5)
			H.faction = list(FACTION_CULT)
			H.GiveTarget(owner)
			H.move_to_delay = owner.cached_multiplicative_slowdown
			to_chat(owner, span_danger("<b>[src] betrays you!</b>"))
		return FALSE

/obj/item/shield/mirror/proc/readd()
	illusions++
	if(illusions == initial(illusions) && isliving(loc))
		var/mob/living/holder = loc
		to_chat(holder, "<span class='cult italic'>The shield's illusions are back at full strength!</span>")

/obj/item/shield/mirror/IsReflect()
	if(prob(block_chance))
		return TRUE
	return FALSE

/obj/item/shield/mirror/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/impact_turf = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/target = hit_atom

		if(target.can_block_magic() || IS_CULTIST(target))
			target.visible_message(span_warning("[src] bounces off of [target], as if repelled by an unseen force!"))
			return
		if(IS_CULTIST(target) && target.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			target.visible_message(span_warning("[target] catches [src] out of the air!"))
			return
		if(!..())
			target.Paralyze(30)
			var/mob/thrower = throwingdatum?.get_thrower()
			if(thrower)
				for(var/mob/living/Next in orange(2, impact_turf))
					if(!Next.density || IS_CULTIST(Next))
						continue
					throw_at(Next, 3, 1, thrower)
					return
				throw_at(thrower, 7, 1, null)
	else
		..()

#undef SHUTTLE_CURSE_OMFG_TIMESPAN
