///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/milk
	name = "10 Milk"
	id = "milk"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 20)
	make_reagents = list("milk" = 10)
	category = list("initial","Food")

/datum/design/cream
	name = "10 Cream"
	id = "cream"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 30)
	make_reagents = list("cream" = 10)
	category = list("initial","Food")

/datum/design/milk_carton
	name = "Milk Carton"
	id = "milk_carton"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 100)
	build_path = /obj/item/weapon/reagent_containers/food/condiment/milk
	category = list("initial","Food")

/datum/design/cream_carton
	name = "Cream Carton"
	id = "cream_carton"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	category = list("initial","Food")

/datum/design/black_pepper
	name = "10u Black Pepper"
	id = "black_pepper"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	make_reagents = list("blackpepper" = 10)
	category = list("initial","Food")

/datum/design/pepper_mill
	name = "Pepper Mill"
	id = "pepper_mill"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/weapon/reagent_containers/food/condiment/peppermill
	make_reagents = list()
	category = list("initial","Food")

/datum/design/monkey_cube
	name = "Monkey Cube"
	id = "mcube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 250)
	build_path = /obj/item/weapon/reagent_containers/food/snacks/monkeycube
	category = list("initial", "Food")

/datum/design/ez_nut
	name = "E-Z Nutrient"
	id = "ez_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 10)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/nutrient/ez
	category = list("initial","Botany Chemicals")

/datum/design/l4z_nut
	name = "Left 4 Zed"
	id = "l4z_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 20)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/nutrient/l4z
	category = list("initial","Botany Chemicals")

/datum/design/rh_nut
	name = "Robust Harvest"
	id = "rh_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/nutrient/rh
	category = list("initial","Botany Chemicals")

/datum/design/weed_killer
	name = "Weed Killer"
	id = "weed_killer"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/killer/weedkiller
	category = list("initial","Botany Chemicals")

/datum/design/pest_spray
	name = "Pest Killer"
	id = "pest_spray"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/killer/pestkiller
	category = list("initial","Botany Chemicals")

/datum/design/botany_bottle
	name = "Empty Bottle"
	id = "botany_bottle"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 5)
	build_path = /obj/item/weapon/reagent_containers/glass/bottle/nutrient/empty
	category = list("initial", "Botany Chemicals")

/datum/design/cloth
	name = "Roll of Cloth"
	id = "cloth"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/stack/sheet/cloth
	category = list("initial","Leather and Cloth")

/datum/design/leather
	name = "Sheet of Leather"
	id = "leather"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 150)
	build_path = /obj/item/stack/sheet/leather
	category = list("initial","Leather and Cloth")

/datum/design/secbelt
	name = "Security Belt"
	id = "secbelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/weapon/storage/belt/security
	category = list("initial","Leather and Cloth")

/datum/design/medbelt
	name = "Medical Belt"
	id = "medbel"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/weapon/storage/belt/medical
	category = list("initial","Leather and Cloth")

/datum/design/janibelt
	name = "Janitorial Belt"
	id = "janibelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/weapon/storage/belt/janitor
	category = list("initial","Leather and Cloth")

/datum/design/s_holster
	name = "Shoulder Holster"
	id = "s_holster"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 400)
	build_path = /obj/item/weapon/storage/belt/holster
	category = list("initial","Leather and Cloth")

/datum/design/rice_hat
	name = "Rice Hat"
	id = "rice_hat"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/clothing/head/rice_hat
	category = list("initial","Leather and Cloth")
