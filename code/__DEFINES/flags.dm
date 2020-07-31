/*
	These defines are specific to the atom/flags_1 bitmask
*/
#define ALL (~0) //For convenience.
#define NONE 0

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

// for /datum/var/datum_flags
#define DF_USE_TAG		(1<<0)
#define DF_VAR_EDITED	(1<<1)
#define DF_ISPROCESSING (1<<2)

//FLAGS BITMASK

/// This flag is what recursive_hear_check() uses to determine wether to add an item to the hearer list or not.
#define HEAR_1						(1<<3)
/// conducts electricity (metal etc.)
#define CONDUCT_1					(1<<5)
/// For machines and structures that should not break into parts, eg, holodeck stuff
#define NODECONSTRUCT_1				(1<<7)
/// atom queued to SSoverlay
#define OVERLAY_QUEUED_1			(1<<8)
/// item has priority to check when entering or leaving
#define ON_BORDER_1					(1<<9)
/// Prevent clicking things below it on the same turf eg. doors/ fulltile windows
#define PREVENT_CLICK_UNDER_1		(1<<11)
#define HOLOGRAM_1					(1<<12)
/// Prevents mobs from getting chainshocked by teslas and the supermatter
#define SHOCKED_1 					(1<<13)
///Whether /atom/Initialize() has already run for the object
#define INITIALIZED_1				(1<<14)
/// was this spawned by an admin? used for stat tracking stuff.
#define ADMIN_SPAWNED_1			    (1<<15)
/// should not get harmed if this gets caught by an explosion?
#define PREVENT_CONTENTS_EXPLOSION_1 (1<<16)
/// should the contents of this atom be acted upon
#define RAD_PROTECT_CONTENTS_1 (1 << 17)
/// should this object be allowed to be contaminated
#define RAD_NO_CONTAMINATE_1 (1 << 18)


/// If the thing can reflect light (lasers/energy)
#define RICOCHET_SHINY			(1<<0)
/// If the thing can reflect matter (bullets/bomb shrapnel)
#define RICOCHET_HARD			(1<<1)

//turf-only flags
#define NOJAUNT_1					(1<<0)
#define UNUSED_RESERVATION_TURF_1	(1<<1)
/// If a turf can be made dirty at roundstart. This is also used in areas.
#define CAN_BE_DIRTY_1				(1<<2)
/// If blood cultists can draw runes or build structures on this turf
#define CULT_PERMITTED_1			(1<<3)
/// Blocks lava rivers being generated on the turf
#define NO_LAVA_GEN_1				(1<<6)
/// Blocks ruins spawning on the turf
#define NO_RUINS_1					(1<<10)

/*
	These defines are used specifically with the atom/pass_flags bitmask
	the atom/checkpass() proc uses them (tables will call movable atom checkpass(PASSTABLE) for example)
*/
//flags for pass_flags
#define PASSTABLE		(1<<0)
#define PASSGLASS		(1<<1)
#define PASSGRILLE		(1<<2)
#define PASSBLOB		(1<<3)
#define PASSMOB			(1<<4)
#define PASSCLOSEDTURF	(1<<5)
#define LETPASSTHROW	(1<<6)
#define	PASSMACHINE		(1<<7)
#define PASSSTRUCTURE	(1<<8)

//Movement Types
#define GROUND			(1<<0)
#define FLYING			(1<<1)
#define VENTCRAWLING	(1<<2)
#define FLOATING		(1<<3)
/// When moving, will Bump()/Cross()/Uncross() everything, but won't be stopped.
#define UNSTOPPABLE		(1<<4)

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF		(1<<0)
/// 100% immune to fire damage (but not necessarily to lava or heat)
#define FIRE_PROOF		(1<<1)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
/// acid can't even appear on it, let alone melt it.
#define UNACIDABLE		(1<<4)
/// acid stuck on it doesn't melt it.
#define ACID_PROOF		(1<<5)
/// doesn't take damage
#define INDESTRUCTIBLE	(1<<6)
/// can't be frozen
#define FREEZE_PROOF	(1<<7)

//tesla_zap
#define ZAP_MACHINE_EXPLOSIVE		(1<<0)
#define ZAP_ALLOW_DUPLICATES		(1<<1)
#define ZAP_OBJ_DAMAGE			(1<<2)
#define ZAP_MOB_DAMAGE			(1<<3)
#define ZAP_MOB_STUN			(1<<4)

#define ZAP_DEFAULT_FLAGS ALL
#define ZAP_FUSION_FLAGS ZAP_OBJ_DAMAGE | ZAP_MOB_DAMAGE | ZAP_MOB_STUN
#define ZAP_SUPERMATTER_FLAGS NONE

//EMP protection
#define EMP_PROTECT_SELF (1<<0)
#define EMP_PROTECT_CONTENTS (1<<1)
#define EMP_PROTECT_WIRES (1<<2)

//Mob mobility var flags
/// can move
#define MOBILITY_MOVE			(1<<0)
/// can, and is, standing up
#define MOBILITY_STAND			(1<<1)
/// can pickup items
#define MOBILITY_PICKUP			(1<<2)
/// can hold and use items
#define MOBILITY_USE			(1<<3)
/// can use interfaces like machinery
#define MOBILITY_UI				(1<<4)
/// can use storage item
#define MOBILITY_STORAGE		(1<<5)
/// can pull things
#define MOBILITY_PULL			(1<<6)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL)
#define MOBILITY_FLAGS_INTERACTION (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_UI | MOBILITY_STORAGE)

//alternate appearance flags
#define AA_TARGET_SEE_APPEARANCE (1<<0)
#define AA_MATCH_TARGET_OVERLAYS (1<<1)

#define KEEP_TOGETHER_ORIGINAL "keep_together_original"

//setter for KEEP_TOGETHER to allow for multiple sources to set and unset it
#define ADD_KEEP_TOGETHER(x, source)\
	if ((x.appearance_flags & KEEP_TOGETHER) && !HAS_TRAIT(x, TRAIT_KEEP_TOGETHER)) ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL); \
	ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	x.appearance_flags |= KEEP_TOGETHER

#define REMOVE_KEEP_TOGETHER(x, source)\
	REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	if(HAS_TRAIT_FROM_ONLY(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL))\
		REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL);\
	else if(!HAS_TRAIT(x, TRAIT_KEEP_TOGETHER))\
	 	x.appearance_flags &= ~KEEP_TOGETHER

//religious_tool flags
#define RELIGION_TOOL_INVOKE (1<<0)
#define RELIGION_TOOL_SACRIFICE (1<<1)
#define RELIGION_TOOL_SECTSELECT (1<<2)

//skillchip flags
//Skillchip type can be implanted multiple times
#define SKILLCHIP_ALLOWS_MULTIPLE (1<<0)
// Job skillchip, only one job skillchip can be implanted.
#define SKILLCHIP_JOB_TYPE (1<<1)
// Skillchip requires the target to be mindshielded to be implanted.
#define SKILLCHIP_REQUIRE_MINDSHIELD (1<<2)
