#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

datum/reagent/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	description = "This antibacterial compound is used to treat burn victims."
	reagent_state = LIQUID
	color = "#E1D00F"
	metabolization_rate = 2

datum/reagent/silver_sulfadiazine/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		M.adjustFireLoss(-volume*2)
		if(show_message)
			M << "<span class='notice'>The silver sulfadiazine soothes your burns.</span>"
		M.emote("scream")
	if(method == INGEST)
		M.adjustToxLoss(0.5*volume)
		if(show_message)
			M << "<span class='notice'>You feel sick...</span>"
	..()
	return

datum/reagent/silver_sulfadiazine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustFireLoss(-2*REM)
	..()
	return

datum/reagent/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	description = "Styptic (aluminium sulfate) powder helps control bleeding and heal physical wounds."
	reagent_state = LIQUID
	color = "#FF9696"
	metabolization_rate = 2

datum/reagent/styptic_powder/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		M.adjustBruteLoss(-volume)
		if(show_message)
			M << "<span class='notice'>The styptic powder stings like hell as it closes some of your wounds.</span>"
		M.emote("scream")
	if(method == INGEST)
		M.adjustToxLoss(0.5*volume)
		if(show_message)
			M << "<span class='notice'>You feel gross!</span>"
	..()
	return

datum/reagent/styptic_powder/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustBruteLoss(-8*REM)
	..()
	return

datum/reagent/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	description = "This saline and glucose solution can help stabilize critically injured patients and cleanse wounds."
	reagent_state = LIQUID
	color = "#696969" // rgb: 200, 165, 220
	metabolization_rate = 0.15

datum/reagent/salglu_solution/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(33))
		M.adjustBruteLoss(-2*REM)
		M.adjustFireLoss(-2*REM)
	..()
	return

datum/reagent/synthflesh
	name = "Synthetic flesh"
	id = "synthflesh"
	description = "A resorbable microfibrillar collagen and protein mixture that can rapidly heal injuries when applied topically."
	reagent_state = LIQUID
	color = "#FFEBEB"

datum/reagent/synthflesh/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume,var/show_message = 1)
	if(!M) M = holder.my_atom
	if(method == TOUCH)
		M.adjustBruteLoss(-1.5*volume)
		M.adjustFireLoss(-1.5*volume)
		if(show_message)
			M << "<span class='notice'>The synthetic flesh integrates itself into your wounds, healing you.</span>"
	..()
	return

datum/reagent/charcoal
	name = "Charcoal"
	id = "charcoal"
	description = "Activated charcoal helps to absorb toxins."
	reagent_state = LIQUID
	color = "#333333" // rgb: 200, 165, 220

datum/reagent/charcoal/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(-3*REM)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,1)
	..()
	return

/datum/chemical_reaction/charcoal
	name = "Charcoal"
	id = "charcoal"
	result = "charcoal"
	required_reagents = list("ash" = 1, "sodiumchloride" = 1)
	result_amount = 2
	mix_message = "The mixture yields a fine black powder."
	required_temp = 380

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	result = "silver_sulfadiazine"
	required_reagents = list("ammonia" = 1, "silver" = 1, "sulfur" = 1, "oxygen" = 1, "chlorine" = 1)
	result_amount = 5
	mix_message = "The solution thickens then breaks into a odorous powder."

/datum/chemical_reaction/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	result = "salglu_solution"
	required_reagents = list("sodiumchloride" = 1, "water" = 1, "sugar" = 1)
	result_amount = 3
	mix_message = "The mixtures gives off a sweet smell as it mixes."

/datum/chemical_reaction/synthflesh
	name = "Synthetic flesh"
	id = "synthflesh"
	result = "synthflesh"
	required_reagents = list("blood" = 1, "carbon" = 1, "styptic_powder" = 1)
	result_amount = 3
	mix_message = "Large chunks of rubbery flesh form in the beaker."

/datum/chemical_reaction/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	result = "styptic_powder"
	required_reagents = list("aluminium" = 1, "hydrogen" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 4
	mix_message = "The solution yields an astringent powder."

datum/reagent/omnizine
	name = "Omnizine"
	id = "omnizine"
	description = "Heals one each of OXY, TOX, BRUTE and BURN per cycle."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.2
	overdose_threshold = 30

datum/reagent/omnizine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(-1*REM)
	M.adjustOxyLoss(-1*REM)
	M.adjustBruteLoss(-1*REM)
	M.adjustFireLoss(-1*REM)
	..()
	return

datum/reagent/omnizine/overdose_process(var/mob/living/M as mob)
	M.adjustToxLoss(3*REM)
	M.adjustOxyLoss(3*REM)
	M.adjustBruteLoss(3*REM)
	M.adjustFireLoss(3*REM)
	..()
	return

datum/reagent/calomel
	name = "Calomel"
	id = "calomel"
	description = "This potent purgative rids the body of impurities. It is highly toxic however and close supervision is required."
	reagent_state = LIQUID
	color = "#54BA63"

datum/reagent/calomel/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,5)
	if(M.health > 20)
		M.adjustToxLoss(5*REM)
	..()
	return

/datum/chemical_reaction/calomel
	name = "Calomel"
	id = "calomel"
	result = "calomel"
	required_reagents = list("mercury" = 1, "chlorine" = 1)
	result_amount = 2
	required_temp = 374

datum/reagent/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	description = "Potassium Iodide is a medicinal drug used to counter the effects of radiation poisoning."
	reagent_state = LIQUID
	color = "#6C9070"

datum/reagent/potass_iodide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.radiation > 0)
		if(prob(80))
			M.radiation--
	if(M.radiation < 0)
		M.radiation = 0
	..()
	return

/datum/chemical_reaction/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	result = "potass_iodide"
	required_reagents = list("potassium" = 1, "iodine" = 1)
	result_amount = 2

datum/reagent/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	description = "Pentetic Acid is an aggressive chelation agent. May cause tissue damage. Use with caution."
	reagent_state = LIQUID
	color = "#E5FFF0"

datum/reagent/pen_acid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.radiation > 0)
		M.radiation -= 7
	M.adjustToxLoss(-4*REM)
	if(prob(33))
		M.adjustBruteLoss(1*REM)
	if(M.radiation < 0)
		M.radiation = 0
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,4)
	..()
	return

/datum/chemical_reaction/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	result = "pen_acid"
	required_reagents = list("fuel" = 1, "chlorine" = 1, "ammonia" = 1, "formaldehyde" = 1, "sodium" = 1, "cyanide" = 1)
	result_amount = 6
	mix_message = "You hear a quiet sizzling as the chemicals react with one another."

datum/reagent/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	description = "This is a is a standard salicylate pain reliever and fever reducer."
	reagent_state = LIQUID
	color = "#1B1B1B"
	overdose_threshold = 25

datum/reagent/sal_acid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.getBruteLoss() < 50)
		if(prob(50))
			M.adjustBruteLoss(-1*REM)
	..()
	return

datum/reagent/sal_acid/overdose_process(var/mob/living/M as mob)
	if(M.getBruteLoss() < 50)
		if(prob(50))
			M.adjustBruteLoss(2*REM)
	..()
	return

/datum/chemical_reaction/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	result = "sal_acid"
	required_reagents = list("sodium" = 1, "phenol" = 1, "carbon" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 5
	mix_message = "The mixture gives off soothing vapors."

datum/reagent/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	description = "Salbutamol is a common bronchodilation medication for asthmatics. It may help with other breathing problems as well."
	reagent_state = LIQUID
	color = "#00FFFF"
	metabolization_rate = 0.2

datum/reagent/salbutamol/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-6*REM)
	if(M.losebreath >= 4)
		M.losebreath -= 4
	..()
	return

/datum/chemical_reaction/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	result = "salbutamol"
	required_reagents = list("sal_acid" = 1, "lithium" = 1, "aluminium" = 1, "bromine" = 1, "ammonia" = 1)
	result_amount = 5
	mix_message = "The solution gives off a large puff of oxygen!"

datum/reagent/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	description = "This experimental perfluoronated solvent has applications in liquid breathing and tissue oxygenation. Use with caution."
	reagent_state = LIQUID
	color = "#FFFFFF"
	metabolization_rate = 0.2

datum/reagent/perfluorodecalin/on_mob_life(var/mob/living/carbon/human/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-25*REM)
	M.silent = max(M.silent, 5)
	if(prob(33))
		M.adjustBruteLoss(-1*REM)
		M.adjustFireLoss(-1*REM)
	..()
	return

/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	result = "perfluorodecalin"
	required_reagents = list("hydrogen" = 1, "fluorine" = 1, "oil" = 1)
	result_amount = 3
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense, milky liquid."

datum/reagent/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	description = "Ephedrine is a plant-derived stimulant."
	reagent_state = LIQUID
	color = "#AFC9C5"
	metabolization_rate = 0.3
	overdose_threshold = 45
	addiction_threshold = 30

datum/reagent/ephedrine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= IGNORESLOWDOWN
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.adjustStaminaLoss(-1*REM)
	..()
	return

datum/reagent/ephedrine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(1*REM)
		M.losebreath++
	..()
	return

datum/reagent/ephedrine/addiction_act_stage1(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(2*REM)
		M.losebreath += 2
	..()
	return
datum/reagent/ephedrine/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(3*REM)
		M.losebreath += 3
	..()
	return
datum/reagent/ephedrine/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(4*REM)
		M.losebreath += 4
	..()
	return
datum/reagent/ephedrine/addiction_act_stage4(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(5*REM)
		M.losebreath += 5
	..()
	return

/datum/chemical_reaction/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	result = "ephedrine"
	required_reagents = list("sugar" = 1, "oil" = 1, "hydrogen" = 1, "diethylamine" = 1)
	result_amount = 4
	mix_message = "The solution fizzes and gives off toxic fumes."

datum/reagent/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	description = "Anti-allergy medication. May cause drowsiness, do not operate heavy machinery while using this."
	reagent_state = LIQUID
	color = "#67D6ED"
datum/reagent/diphenhydramine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.drowsyness += 1
	M.jitteriness -= 1
	M.reagents.remove_reagent("histamine",3)
	..()
	return

/datum/chemical_reaction/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	result = "diphenhydramine"
	required_reagents = list("oil" = 1, "carbon" = 1, "bromine" = 1, "diethylamine" = 1, "ethanol" = 1)
	result_amount = 4
	mix_message = "The mixture dries into a pale blue powder."

datum/reagent/morphine
	name = "Morphine"
	id = "morphine"
	description = "Dramatically counters movement reduction from severe injury. Reduces jitteriness if someone is shaking like crazy from whatever. Will knock you out within 36 cycles if any remains in you."
	reagent_state = LIQUID
	color = "#898989"
	var/cycle_count = 0
	overdose_threshold = 30
	addiction_threshold = 25


datum/reagent/morphine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= IGNORESLOWDOWN
	if(cycle_count == 36)
		M.drowsyness += 1
	cycle_count++
	..()
	return

datum/reagent/morphine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(1)
		M.Jitter(1)
	..()
	return

datum/reagent/morphine/addiction_act_stage1(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(2)
		M.Jitter(2)
	..()
	return
datum/reagent/morphine/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(1*REM)
		M.Dizzy(3)
		M.Jitter(3)
	..()
	return
datum/reagent/morphine/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(2*REM)
		M.Dizzy(4)
		M.Jitter(4)
	..()
	return
datum/reagent/morphine/addiction_act_stage4(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(3*REM)
		M.Dizzy(5)
		M.Jitter(5)
	..()
	return

datum/reagent/oculine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	cycle_amount++
	if(M.eye_blind > 0 && cycle_amount > 20)
		if(prob(30))
			M.eye_blind = 0
		else if(prob(80))
			M.eye_blind = 0
			M.eye_blurry = 1
		if(M.eye_blurry > 0)
			if(prob(80))
				M.eye_blurry = 0
	..()
	return

/datum/chemical_reaction/oculine
	name = "Oculine"
	id = "oculine"
	result = "oculine"
	required_reagents = list("charcoal" = 1, "carbon" = 1, "hydrogen" = 1)
	result_amount = 3
	mix_message = "The mixture sputters loudly and becomes a pale pink color."

datum/reagent/oculine
	name = "Oculine"
	id = "oculine"
	description = "Oculine is a saline eye medication with mydriatic and antibiotic effects."
	reagent_state = LIQUID
	color = "#B5B4B4"
	metabolization_rate = 0.4
	var/cycle_amount = 0

datum/reagent/atropine
	name = "Atropine"
	id = "atropine"
	description = "Atropine is a potent cardiac resuscitant but it can causes confusion, dizzyness and hyperthermia."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.2
	overdose_threshold = 35

datum/reagent/atropine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.health > -60)
		M.adjustToxLoss(1*REM)
	if(M.health < -25)
		M.adjustBruteLoss(-3*REM)
		M.adjustFireLoss(-3*REM)
	if(M.oxyloss > 65)
		M.setOxyLoss(65)
	if(M.losebreath > 5)
		M.losebreath = 5
	if(prob(30))
		M.Dizzy(5)
		M.Jitter(5)
	..()
	return

datum/reagent/atropine/overdose_process(var/mob/living/M as mob)
	if(prob(50))
		M.adjustToxLoss(2*REM)
		M.Dizzy(1)
		M.Jitter(1)
	..()
	return

/datum/chemical_reaction/atropine
	name = "Atropine"
	id = "atropine"
	result = "atropine"
	required_reagents = list("ethanol" = 1, "acetone" = 1, "diethylamine" = 1, "phenol" = 1, "sacid" = 1)
	result_amount = 5
	mix_message = "The contents of the beaker quickly decay into an oily mess."

datum/reagent/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	description = "Epinephrine is a potent neurotransmitter, used in medical emergencies to halt anaphylactic shock and prevent cardiac arrest."
	reagent_state = LIQUID
	color = "#AFC9C5"
	metabolization_rate = 0.2
	overdose_threshold = 30

datum/reagent/epinephrine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.health < -10 && M.health > -65)
		M.adjustToxLoss(-1*REM)
		M.adjustBruteLoss(-1*REM)
		M.adjustFireLoss(-1*REM)
	if(M.oxyloss > 35)
		M.setOxyLoss(35)
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-5)
	M.adjustStaminaLoss(-1*REM)
	if(prob(30))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
	..()
	return

datum/reagent/epinephrine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustStaminaLoss(5*REM)
		M.adjustToxLoss(2*REM)
		M.losebreath++
	..()
	return

/datum/chemical_reaction/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	result = "epinephrine"
	required_reagents = list("phenol" = 1, "acetone" = 1, "diethylamine" = 1, "oxygen" = 1, "chlorine" = 1, "hydrogen" = 1)
	result_amount = 6
	mix_message = "The mixture fizzes and sputters!"

datum/reagent/strange_reagent
	name = "Strange Reagent"
	id = "strange_reagent"
	description = "A miracle medical chem, this little beauty can bring the dead back to life!"
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/strange_reagent/reaction_mob(var/mob/living/carbon/human/M as mob, var/method=TOUCH, var/volume)
	if(M.stat == DEAD)
		if(M.getBruteLoss() >= 100 || M.getFireLoss() >= 100)
			M.visible_message("<span class='warning'>[M]'s body convulses a bit, and then falls still once more.</span>")
			return
		var/mob/dead/observer/ghost = M.get_ghost()
		M.visible_message("<span class='warning'>[M]'s body convulses a bit.</span>")
		if(!M.suiciding && !ghost && !(NOCLONE in M.mutations))
			M.stat = 1
			M.adjustOxyLoss(-20)
			M.adjustToxLoss(-20)
			dead_mob_list -= M
			living_mob_list |= list(M)
			M.emote("gasp")
			add_logs(M, M, "revived", object="strange reagent")
			hardset_dna(M, null, null, null, null, /datum/species/zombie)
	..()
	return
datum/reagent/strange_reagent/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(rand(1,100)))
		M.adjustBruteLoss(2*REM)
		M.adjustFireLoss(2*REM)
	..()
	return

/datum/chemical_reaction/strange_reagent
	name = "Strange Reagent"
	id = "strange_reagent"
	result = "strange_reagent"
	required_reagents = list("omnizine" = 1, "holywater" = 1, "mutagen" = 1)
	result_amount = 3
	mix_message = "The beaker shines and sparkles!"

datum/reagent/life
	name = "Life"
	id = "life"
	description = ""
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.2

/datum/chemical_reaction/life
	name = "Life"
	id = "life"
	result = "life"
	required_reagents = list("strange_reagent" = 1, "synthflesh" = 1, "blood" = 1)
	result_amount = 3
	required_temp = 374

/datum/chemical_reaction/life/on_reaction(var/datum/reagents/holder, var/created_volume)
	chemical_mob_spawn(holder, 1, "Life")

proc/chemical_mob_spawn(var/datum/reagents/holder, var/amount_to_spawn, var/reaction_name, var/mob_faction = "chemicalsummon")
	if(holder && holder.my_atom)
		var/blocked = list(/mob/living/simple_animal/hostile,
			/mob/living/simple_animal/hostile/pirate,
			/mob/living/simple_animal/hostile/pirate/ranged,
			/mob/living/simple_animal/hostile/russian,
			/mob/living/simple_animal/hostile/russian/ranged,
			/mob/living/simple_animal/hostile/syndicate,
			/mob/living/simple_animal/hostile/syndicate/melee,
			/mob/living/simple_animal/hostile/syndicate/melee/space,
			/mob/living/simple_animal/hostile/syndicate/ranged,
			/mob/living/simple_animal/hostile/syndicate/ranged/space,
			/mob/living/simple_animal/hostile/alien/queen/large,
			/mob/living/simple_animal/hostile/retaliate,
			/mob/living/simple_animal/hostile/retaliate/clown,
			/mob/living/simple_animal/hostile/mushroom,
			/mob/living/simple_animal/hostile/asteroid,
			/mob/living/simple_animal/hostile/asteroid/basilisk,
			/mob/living/simple_animal/hostile/asteroid/goldgrub,
			/mob/living/simple_animal/hostile/asteroid/goliath,
			/mob/living/simple_animal/hostile/asteroid/hivelord,
			/mob/living/simple_animal/hostile/asteroid/hivelordbrood,
			/mob/living/simple_animal/hostile/carp/holocarp,
			/mob/living/simple_animal/hostile/mining_drone,
			/mob/living/simple_animal/hostile/poison
			)//exclusion list for things you don't want the reaction to create.
		var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/area/my_area = get_area(T)
		var/message = "A [reaction_name] reaction has occured in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>)"
		message += " (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/human/H in viewers(get_turf(holder.my_atom), null))
			if(H:eyecheck() <= 0)
				flick("e_flash", H.flash)
		for(var/i = 1, i <= amount_to_spawn, i++)
			var/chosen = pick(critters)
			var/mob/living/simple_animal/hostile/C = new chosen
			C.faction |= mob_faction
			C.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))

/datum/reagent/mannitol/on_mob_life(mob/living/M as mob)
	M.adjustBrainLoss(-3)
	..()
	return

/datum/chemical_reaction/mannitol
	name = "Mannitol"
	id = "mannitol"
	result = "mannitol"
	required_reagents = list("sugar" = 1, "hydrogen" = 1, "water" = 1)
	result_amount = 3
	mix_message = "The solution slightly bubbles, becoming thicker."

/datum/reagent/mannitol
	name = "Mannitol"
	id = "mannitol"
	description = "Mannitol is a sugar alcohol that can help alleviate cranial swelling."
	color = "#D6D6F6"

/datum/reagent/mutadone/on_mob_life(var/mob/living/carbon/human/M as mob)
	M.jitteriness = 0
	if(istype(M) && M.dna)
		M.dna.remove_all_mutations()
	..()
	return

/datum/chemical_reaction/mutadone
	name = "Mutadone"
	id = "mutadone"
	result = "mutadone"
	required_reagents = list("mutagen" = 1, "acetone" = 1, "bromine" = 1)
	result_amount = 3


/datum/reagent/mutadone
	name = "Mutadone"
	id = "mutadone"
	description = "Mutadone is an experimental bromide that can cure genetic abnomalities."
	color = "#5096C8"

datum/reagent/antihol
	name = "Antihol"
	id = "antihol"
	description = "A medicine which quickly eliminates alcohol in the body."
	color = "#12BEAD"

datum/reagent/antihol/on_mob_life(var/mob/living/M as mob)
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.confused = 0
	M.reagents.remove_reagent("ethanol", 8)
	M.adjustToxLoss(-0.2*REM)
	..()

/datum/chemical_reaction/antihol
	name = "antihol"
	id = "antihol"
	result = "antihol"
	required_reagents = list("ethanol" = 1, "charcoal" = 1)
	result_amount = 2

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	result = "cryoxadone"
	required_reagents = list("stable_plasma" = 1, "acetone" = 1, "mutagen" = 1)
	result_amount = 3

/datum/reagent/stimulants
	name = "Stimulants"
	id = "stimulants"
	description = "Sets all stun-related vars to zero, gets you running really fast. Heals 5 OXY, TOX, BRUTE, and BURN damage if health is below 50. Reduces all stuns."
	color = "#8E18A9"
	metabolization_rate = 0.4
	overdose_threshold = 60

datum/reagent/stimulants/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= IGNORESLOWDOWN
	if(M.health < 50 && M.health > 0)
		if(prob(50))
			M.adjustOxyLoss(-5*REM)
			M.adjustToxLoss(-5*REM)
			M.adjustBruteLoss(-5*REM)
			M.adjustFireLoss(-5*REM)
	M.adjustFireLoss(-3*REM)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.adjustStaminaLoss(-3*REM)
	..()

datum/reagent/stimulants/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustStaminaLoss(5*REM)
		M.adjustToxLoss(2*REM)
		M.losebreath++
	..()
	return

datum/reagent/insulin
	name = "Insulin"
	id = "insulin"
	description = "Increases sugar depletion rates."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
datum/reagent/insulin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.sleeping)
		M.sleeping--
	M.reagents.remove_reagent("sugar", 5)
	..()
	return
