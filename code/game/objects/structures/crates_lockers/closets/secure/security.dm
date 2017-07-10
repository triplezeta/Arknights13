/obj/structure/closet/secure_closet/captains
	name = "\proper captain's locker"
	req_access = list(GLOB.access_captain)
	icon_state = "cap"

/obj/structure/closet/secure_closet/captains/PopulateContents()
	..()
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/captain(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/cap(src)
	new /obj/item/clothing/neck/cloak/cap(src)
	new /obj/item/weapon/storage/backpack/duffelbag/captain(src)
	new /obj/item/clothing/head/crown/fancy(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/under/captainparade(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/alt(src)
	new /obj/item/weapon/cartridge/captain(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/storage/box/silver_ids(src)
	new /obj/item/device/radio/headset/heads/captain/alt(src)
	new /obj/item/device/radio/headset/heads/captain(src)
	new /obj/item/clothing/glasses/sunglasses/gar/supergar(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/storage/belt/sabre(src)
	new /obj/item/weapon/gun/energy/e_gun(src)
	new /obj/item/weapon/door_remote/captain(src)

/obj/structure/closet/secure_closet/hop
	name = "\proper head of personnel's locker"
	req_access = list(GLOB.access_hop)
	icon_state = "hop"

/obj/structure/closet/secure_closet/hop/PopulateContents()
	..()
	new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/clothing/under/rank/head_of_personnel(src)
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/weapon/cartridge/hop(src)
	new /obj/item/device/radio/headset/heads/hop(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/storage/box/ids(src)
	new /obj/item/weapon/storage/box/ids(src)
	new /obj/item/device/megaphone/command(src)
	new /obj/item/clothing/suit/armor/vest/alt(src)
	new /obj/item/device/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
	new /obj/item/weapon/gun/energy/e_gun(src)
	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/weapon/door_remote/civillian(src)

/obj/structure/closet/secure_closet/hos
	name = "\proper head of security's locker"
	req_access = list(GLOB.access_hos)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/PopulateContents()
	..()
	new /obj/item/clothing/neck/cloak/hos(src)
	new /obj/item/weapon/cartridge/hos(src)
	new /obj/item/device/radio/headset/heads/hos(src)
	new /obj/item/clothing/under/hosparadefem(src)
	new /obj/item/clothing/under/hosparademale(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/under/rank/head_of_security/alt(src)
	new /obj/item/clothing/head/HoS(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars(src)
	new /obj/item/clothing/under/rank/head_of_security/grey(src)
	new /obj/item/weapon/storage/lockbox/medal/sec(src)
	new /obj/item/device/megaphone/sec(src)
	new /obj/item/weapon/holosign_creator/security(src)
	new /obj/item/weapon/storage/lockbox/loyalty(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/shield/riot/tele(src)
	new /obj/item/weapon/storage/belt/security/full(src)
	new /obj/item/weapon/gun/energy/e_gun/hos(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/weapon/pinpointer(src)

/obj/structure/closet/secure_closet/warden
	name = "\proper warden's locker"
	req_access = list(GLOB.access_armory)
	icon_state = "warden"

/obj/structure/closet/secure_closet/warden/PopulateContents()
	..()
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/warden(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/warden/navyblue(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/weapon/holosign_creator/security(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/weapon/storage/box/zipties(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/storage/belt/security/full(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/clothing/gloves/krav_maga/sec(src)
	new /obj/item/weapon/door_remote/head_of_security(src)
	new /obj/item/weapon/gun/ballistic/shotgun/automatic/combat/compact(src)

/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(GLOB.access_security)
	icon_state = "sec"

/obj/structure/closet/secure_closet/security/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet/sec(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/device/flashlight/seclite(src)

/obj/structure/closet/secure_closet/security/sec

/obj/structure/closet/secure_closet/security/sec/PopulateContents()
	..()
	new /obj/item/weapon/storage/belt/security/full(src)

/obj/structure/closet/secure_closet/security/cargo

/obj/structure/closet/secure_closet/security/cargo/PopulateContents()
	..()
	new /obj/item/clothing/accessory/armband/cargo(src)
	new /obj/item/device/encryptionkey/headset_cargo(src)

/obj/structure/closet/secure_closet/security/engine

/obj/structure/closet/secure_closet/security/engine/PopulateContents()
	..()
	new /obj/item/clothing/accessory/armband/engine(src)
	new /obj/item/device/encryptionkey/headset_eng(src)

/obj/structure/closet/secure_closet/security/science

/obj/structure/closet/secure_closet/security/science/PopulateContents()
	..()
	new /obj/item/clothing/accessory/armband/science(src)
	new /obj/item/device/encryptionkey/headset_sci(src)

/obj/structure/closet/secure_closet/security/med

/obj/structure/closet/secure_closet/security/med/PopulateContents()
	..()
	new /obj/item/clothing/accessory/armband/medblue(src)
	new /obj/item/device/encryptionkey/headset_med(src)

/obj/structure/closet/secure_closet/detective
	name = "\proper detective's cabinet"
	req_access = list(GLOB.access_forensics_lockers)
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/clothing/under/rank/det(src)
	new /obj/item/clothing/suit/det_suit(src)
	new /obj/item/clothing/head/fedora/det_hat(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/under/rank/det/grey(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/det_suit/grey(src)
	new /obj/item/clothing/head/fedora(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/weapon/storage/box/evidence(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/detective_scanner(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/weapon/holosign_creator/security(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/clothing/suit/armor/vest/det_suit(src)
	new /obj/item/weapon/storage/belt/holster/full(src)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections"
	req_access = list(GLOB.access_hos)

/obj/structure/closet/secure_closet/injection/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/syringe/lethal/execution(src)

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(GLOB.access_brig)
	anchored = 1
	var/id = null

/obj/structure/closet/secure_closet/evidence
	anchored = TRUE
	name = "Secure Evidence Closet"
	req_access_txt = "0"
	req_one_access_txt = "3,4"

/obj/structure/closet/secure_closet/brig/PopulateContents()
	..()
	new /obj/item/clothing/under/rank/prisoner( src )
	new /obj/item/clothing/shoes/sneakers/orange( src )

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(GLOB.access_court)

/obj/structure/closet/secure_closet/courtroom/PopulateContents()
	..()
	new /obj/item/clothing/shoes/sneakers/brown(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/paper/Court (src)
	new /obj/item/weapon/pen (src)
	new /obj/item/clothing/suit/judgerobe (src)
	new /obj/item/clothing/head/powdered_wig (src)
	new /obj/item/weapon/storage/briefcase(src)

/obj/structure/closet/secure_closet/contraband/armory
	anchored = TRUE
	name = "Contraband Locker"
	req_access = list(GLOB.access_armory)

/obj/structure/closet/secure_closet/contraband/heads
	anchored = TRUE
	name = "Contraband Locker"
	req_access = list(GLOB.access_heads)

/obj/structure/closet/secure_closet/armory1
	name = "armory armor locker"
	req_access = list(GLOB.access_armory)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory1/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/laserproof(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/armor/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/helmet/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/shield/riot(src)

/obj/structure/closet/secure_closet/armory2
	name = "armory ballistics locker"
	req_access = list(GLOB.access_armory)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory2/PopulateContents()
	..()
	new /obj/item/weapon/storage/box/firingpins(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/storage/box/rubbershot(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/gun/ballistic/shotgun/riot(src)

/obj/structure/closet/secure_closet/armory3
	name = "armory energy gun locker"
	req_access = list(GLOB.access_armory)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory3/PopulateContents()
	..()
	new /obj/item/weapon/storage/box/firingpins(src)
	new /obj/item/weapon/gun/energy/ionrifle(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/gun/energy/e_gun(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/gun/energy/laser(src)

/obj/structure/closet/secure_closet/tac
	name = "armory tac locker"
	req_access = list(GLOB.access_armory)
	icon_state = "tac"

/obj/structure/closet/secure_closet/tac/PopulateContents()
	..()
	new /obj/item/weapon/gun/ballistic/automatic/wt550(src)
	new /obj/item/clothing/head/helmet/alt(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/suit/armor/bulletproof(src)

/obj/structure/closet/secure_closet/lethalshots
	name = "shotgun lethal rounds"
	req_access = list(GLOB.access_armory)
	icon_state = "tac"

/obj/structure/closet/secure_closet/lethalshots/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/weapon/storage/box/lethalshot(src)
