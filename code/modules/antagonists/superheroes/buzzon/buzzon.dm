/datum/outfit/superhero/buzzon
	name = "BuzzOn"
	uniform = /obj/item/clothing/under/color/yellow
	suit = /obj/item/clothing/suit/hooded/bee_costume/buzzon
	shoes = /obj/item/clothing/shoes/sneakers/buzzon
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated/buzzon
	back = /obj/item/melee/beesword/buzzon
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/grenade/spawnergrenade/buzzkill/non_toxic
	r_pocket = /obj/item/restraints/handcuffs
	implants = list(/obj/item/implant/spell/specified_type/bees)

/datum/outfit/superhero/buzzon/post_equip(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/clothing/suit/hooded/bee_costume/buzzon/suit = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		suit.ToggleHood()
		suit.recall_sword()
	else if(istype(H.get_item_by_slot(ITEM_SLOT_OCLOTHING), /obj/item/clothing/suit/space/hardsuit/syndi/buzzon))
		var/obj/item/clothing/suit/space/hardsuit/syndi/buzzon/hardsuit = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		hardsuit.recall_sword()

/datum/outfit/superhero/buzzon/cryo
	name = "BuzzOn (Operation Cryostung)"
	uniform = /obj/item/clothing/under/color/blue
	suit = /obj/item/clothing/suit/hooded/bee_costume/buzzon/cryo
	shoes = /obj/item/clothing/shoes/sneakers/buzzon/cryo
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated/buzzon/cryo
	back = /obj/item/melee/beesword/buzzon/cryo
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/blue
	implants = list(/obj/item/implant/spell/specified_type/bees/cryo)

/datum/outfit/superhero/buzzon
	name = "BuzzOn (Operation Starbird)"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/buzzon
	suit_store = /obj/item/tank/internals/oxygen
	mask = /obj/item/clothing/mask/gas
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/superhero/buzzon_nude
	name = "BuzzOn (Nude)"
	uniform = /obj/item/clothing/under/color/yellow
	shoes = /obj/item/clothing/shoes/sneakers/buzzon
	ears = /obj/item/radio/headset
	implants = list(/obj/item/implant/spell/specified_type/bees)

/obj/machinery/suit_storage_unit/superhero/buzzon
	suit_type = /obj/item/clothing/suit/space/hardsuit/syndi/buzzon
	helmet_type = null
	mask_type = /obj/item/clothing/mask/gas
	storage_type = /obj/item/tank/internals/oxygen
