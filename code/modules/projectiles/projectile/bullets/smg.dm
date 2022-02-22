// .45 (M1911 & C20r)

/obj/projectile/bullet/c45
	name = ".45 bullet"
	damage = 30
	wound_bonus = -10
	wound_falloff_tile = -10

/obj/projectile/bullet/c45/ap
	name = ".45 armor-piercing bullet"
	armour_penetration = HEAVY_ARMOR_PENETRATION

/obj/projectile/bullet/incendiary/c45
	name = ".45 incendiary bullet"
	damage = 15
	fire_stacks = 2

// 4.6x30mm (Autorifles)

/obj/projectile/bullet/c46x30mm
	name = "4.6x30mm bullet"
	damage = 20
	wound_bonus = -5
	bare_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c46x30mm/ap
	name = "4.6x30mm armor-piercing bullet"
	damage = 15
	armour_penetration = HEAVY_ARMOR_PENETRATION
	embedding = null

/obj/projectile/bullet/incendiary/c46x30mm
	name = "4.6x30mm incendiary bullet"
	damage = 10
	fire_stacks = 1
