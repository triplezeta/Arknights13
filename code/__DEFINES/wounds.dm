#define WOUND_DAMAGE_EXPONENT	1.4

#define WOUND_SEVERITY_TRIVIAL	0 // for jokey/meme wounds like stubbed toe, no standard messages/sounds or second winds
#define WOUND_SEVERITY_MODERATE	1
#define WOUND_SEVERITY_SEVERE	2
#define WOUND_SEVERITY_CRITICAL	3
#define WOUND_SEVERITY_LOSS		4 // theoretical total limb loss, like dismemberment for cuts

#define WOUND_BLUNT		0
#define WOUND_SLASH		1
#define WOUND_PIERCE	2
#define WOUND_BURN		3

// How much determination reagent to add each time someone gains a new wound in [/datum/wound/proc/second_wind()]
#define WOUND_DETERMINATION_MODERATE	1
#define WOUND_DETERMINATION_SEVERE		2.5
#define WOUND_DETERMINATION_CRITICAL	5

#define WOUND_DETERMINATION_MAX			10

// set wound_bonus on an item or attack to this to disable checking wounding for the attack
#define CANT_WOUND -100

// list in order of highest severity to lowest
#define WOUND_LIST_BLUNT		list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate)
#define WOUND_LIST_SLASH		list(/datum/wound/slash/loss, /datum/wound/slash/critical, /datum/wound/slash/severe, /datum/wound/slash/moderate)
#define WOUND_LIST_PIERCE		list(/datum/wound/pierce/critical, /datum/wound/pierce/severe, /datum/wound/pierce/moderate)
#define WOUND_LIST_BURN		list(/datum/wound/burn/critical, /datum/wound/burn/severe, /datum/wound/burn/moderate)

// Thresholds for infection for burn wounds, once infestation hits each threshold, things get steadily worse
#define WOUND_INFECTION_MODERATE	4 // below this has no ill effects from infection
#define WOUND_INFECTION_SEVERE		8 // then below here, you ooze some pus and suffer minor tox damage, but nothing serious
#define WOUND_INFECTION_CRITICAL	12 // then below here, your limb occasionally locks up from damage and infection and briefly becomes disabled. Things are getting really bad
#define WOUND_INFECTION_SEPTIC		20 // below here, your skin is almost entirely falling off and your limb locks up more frequently. You are within a stone's throw of septic paralysis and losing the limb
// above WOUND_INFECTION_SEPTIC, your limb is completely putrid and you start rolling to lose the entire limb by way of paralyzation. After 3 failed rolls (~4-5% each probably), the limb is paralyzed

#define WOUND_BURN_SANITIZATION_RATE 0.15 // how quickly sanitization removes infestation and decays per tick
#define WOUND_CUT_MAX_BLOODFLOW	8 // how much blood you can lose per tick per cut max. 8 is a LOT of blood for one cut so don't worry about hitting it easily
#define WOUND_BONE_HEAD_TIME_VARIANCE 20 // if we suffer a bone wound to the head that creates brain traumas, the timer for the trauma cycle is +/- by this percent (0-100)

// The following are for persistent scar save formats
#define SCAR_SAVE_VERS				1 // The version number of the scar we're saving
#define SCAR_SAVE_ZONE				2 // The body_zone we're applying to on granting
#define SCAR_SAVE_DESC				3 // The description we're loading
#define SCAR_SAVE_PRECISE_LOCATION	4 // The precise location we're loading
#define SCAR_SAVE_SEVERITY			5 // The severity the scar had

// increment this number when you update the persistent scarring format in a way that invalidates previous saved scars (new fields, reordering, etc)
// saved scars with a version lower than this will be discarded
#define SCAR_CURRENT_VERSION				1

#define BODYPART_MANGLED_NONE	0
#define BODYPART_MANGLED_BONE	1
#define BODYPART_MANGLED_SKIN	2
#define BODYPART_MANGLED_BOTH	3
