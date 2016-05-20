/*
 * Contains:
 *		Security
 *		Detective
 *		Navy uniforms
 */
var/list/sec_outfits = list()
var/list/warden_outfits = list()
var/list/hos_outfits = list()
/*
 * Security
 */

/obj/item/clothing/under/rank/security
	name = "security jumpsuit"
	desc = "A tactical security jumpsuit for officers complete with nanotrasen belt buckle."
	icon_state = "sec_alt1"
	item_state = "sec_alt1"
	item_color = "sec_alt1"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	strip_delay = 50
	alt_covers_chest = 1

/obj/item/clothing/under/rank/security/New()
	..()
	sec_outfits += src

/obj/item/clothing/under/rank/security/Destroy()
	sec_outfits -= src
	..()

/obj/item/clothing/under/rank/warden
	name = "security suit"
	desc = "A formal security suit for officers complete with nanotrasen belt buckle."
	icon_state = "warden_alt1"
	item_state = "warden_alt1"
	item_color = "warden_alt1"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	strip_delay = 50
	alt_covers_chest = 1

/obj/item/clothing/under/rank/warden/New()
	..()
	warden_outfits += src

/obj/item/clothing/under/rank/warden/Destroy()
	warden_outfits -= src
	..()

/*
 * Detective
 */
/obj/item/clothing/under/rank/det
	name = "hard-worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det"
	item_color = "detective"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	strip_delay = 50
	alt_covers_chest = 1

/obj/item/clothing/under/rank/det/grey
	name = "noir suit"
	desc = "A hard-boiled private investigator's grey suit, complete with tie clip."
	icon_state = "greydet"
	item_state = "greydet"
	item_color = "greydet"
	alt_covers_chest = 1

/*
 * Head of Security
 */
/obj/item/clothing/under/rank/head_of_security
	name = "head of security's jumpsuit"
	desc = "A security jumpsuit decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "hos_alt1"
	item_state = "hos_alt1"
	item_color = "hos_alt1"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	strip_delay = 60
	alt_covers_chest = 1

/obj/item/clothing/under/rank/head_of_security/New()
	..()
	hos_outfits += src

/obj/item/clothing/under/rank/head_of_security/Destroy()
	hos_outfits -= src
	..()

/obj/item/clothing/under/rank/head_of_security/alt
	name = "head of security's turtleneck"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with tactical pants."
	icon_state = "hosalt"
	item_state = "bl_suit"
	item_color = "hosalt"

/*
 * Navy uniforms
 */

/obj/item/clothing/under/rank/security/navyblue
	name = "security officer's formal uniform"
	desc = "The latest in fashionable security outfits."
	icon_state = "officerblueclothes"
	item_state = "officerblueclothes"
	item_color = "officerblueclothes"
	alt_covers_chest = 1

/obj/item/clothing/under/rank/head_of_security/navyblue
	desc = "The insignia on this uniform tells you that this uniform belongs to the Head of Security."
	name = "head of security's formal uniform"
	icon_state = "hosblueclothes"
	item_state = "hosblueclothes"
	item_color = "hosblueclothes"
	alt_covers_chest = 1

/obj/item/clothing/under/rank/warden/navyblue
	desc = "The insignia on this uniform tells you that this uniform belongs to the Warden."
	name = "warden's formal uniform"
	icon_state = "wardenblueclothes"
	item_state = "wardenblueclothes"
	item_color = "wardenblueclothes"
	alt_covers_chest = 1