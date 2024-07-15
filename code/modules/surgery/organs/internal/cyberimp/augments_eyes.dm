/obj/item/organ/internal/cyberimp/eyes
	name = "cybernetic eye implant"
	desc = "Implants for your eyes."
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = ORGAN_SLOT_EYES
	zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY

// HUD implants
/obj/item/organ/internal/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = ORGAN_SLOT_HUD
	actions_types = list(/datum/action/item_action/toggle_hud)
	var/HUD_trait = null
	/// Whether the HUD implant is on or off
	var/toggled_on = TRUE


/obj/item/organ/internal/cyberimp/eyes/hud/proc/toggle_hud(mob/living/carbon/eye_owner)
	if(toggled_on)
		toggled_on = FALSE
		ADD_TRAIT(eye_owner, HUD_trait, ORGAN_TRAIT)
		balloon_alert(eye_owner, "hud disabled")
		return
	toggled_on = TRUE
	REMOVE_TRAIT(eye_owner, HUD_trait, ORGAN_TRAIT)
	balloon_alert(eye_owner, "hud enabled")

/obj/item/organ/internal/cyberimp/eyes/hud/Insert(mob/living/carbon/eye_owner, special = FALSE, movement_flags)
	. = ..()
	if(!.)
		return
	if(HUD_trait)
		ADD_TRAIT(eye_owner, HUD_trait, ORGAN_TRAIT)
	toggled_on = TRUE

/obj/item/organ/internal/cyberimp/eyes/hud/Remove(mob/living/carbon/eye_owner, special, movement_flags)
	. = ..()
	if(HUD_trait)
		REMOVE_TRAIT(eye_owner, HUD_trait, ORGAN_TRAIT)
	toggled_on = FALSE

/obj/item/organ/internal/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	HUD_trait = TRAIT_MEDICAL_HUD

/obj/item/organ/internal/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	HUD_trait = TRAIT_SECURITY_HUD

/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	name = "Diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see."

/obj/item/organ/internal/cyberimp/eyes/hud/security/syndicate
	name = "Contraband Security HUD Implant"
	desc = "A Cybersun Industries brand Security HUD Implant. These illicit cybernetic eye implants will display a security HUD over everything you see."
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
