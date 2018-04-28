GLOBAL_LIST_INIT(bitfields, list(
	"appearance_flags" = list(
		"LONG_GLIDE" = LONG_GLIDE,
		"RESET_COLOR" = RESET_COLOR,
		"RESET_ALPHA" = RESET_ALPHA,
		"RESET_TRANSFORM" = RESET_TRANSFORM,
		"NO_CLIENT_COLOR" = NO_CLIENT_COLOR,
		"KEEP_TOGETHER" = KEEP_TOGETHER,
		"KEEP_APART" = KEEP_APART,
		"PLANE_MASTER" = PLANE_MASTER,
		"TILE_BOUND" = TILE_BOUND,
		"PIXEL_SCALE" = PIXEL_SCALE
		),
	"sight" = list(
		"SEE_INFRA" = SEE_INFRA,
		"SEE_SELF" = SEE_SELF,
		"SEE_MOBS" = SEE_MOBS,
		"SEE_OBJS" = SEE_OBJS,
		"SEE_TURFS" = SEE_TURFS,
		"SEE_PIXELS" = SEE_PIXELS,
		"SEE_THRU" = SEE_THRU,
		"SEE_BLACKNESS" = SEE_BLACKNESS,
		"BLIND" = BLIND
		),
	"obj_flags" = list(
		"EMAGGED" = EMAGGED,
		"IN_USE" = IN_USE,
		"CAN_BE_HIT" = CAN_BE_HIT,
		"BEING_SHOCKED" = BEING_SHOCKED,
		"DANGEROUS_POSSESSION" = DANGEROUS_POSSESSION,
		"ON_BLUEPRINTS" = ON_BLUEPRINTS,
		"UNIQUE_RENAME" = UNIQUE_RENAME,
		"USES_TGUI" = USES_TGUI,
		"FROZEN" = FROZEN,
		),
	"datum_flags" = list(
		"DF_USE_TAG" = DF_USE_TAG,
		"DF_VAR_EDITED" = DF_VAR_EDITED
		),
	"item_flags" = list(
		"BEING_REMOVED" = BEING_REMOVED,
		"IN_INVENTORY" = IN_INVENTORY,
		"FORCE_STRING_OVERRIDE" = FORCE_STRING_OVERRIDE,
		"NEEDS_PERMIT" = NEEDS_PERMIT,
		"SLOWS_WHILE_IN_HAND" = SLOWS_WHILE_IN_HAND,
		),
	"admin_flags" = list(
		"BUILDMODE" = R_BUILDMODE,
		"ADMIN" = R_ADMIN,
		"BAN" = R_BAN,
		"FUN" = R_FUN,
		"SERVER" = R_SERVER,
		"DEBUG" = R_DEBUG,
		"POSSESS" = R_POSSESS,
		"PERMISSIONS" = R_PERMISSIONS,
		"STEALTH" = R_STEALTH,
		"POLL" = R_POLL,
		"VAREDIT" = R_VAREDIT,
		"SOUNDS" = R_SOUNDS,
		"SPAWN" = R_SPAWN,
		"AUTOLOGIN" = R_AUTOLOGIN,
		"DBRANKS" = R_DBRANKS
		),
	"interaction_flags_atom" = list(
		"INTERACT_ATOM_REQUIRES_ANCHORED" = INTERACT_ATOM_REQUIRES_ANCHORED,
		"INTERACT_ATOM_ATTACK_HAND" = INTERACT_ATOM_ATTACK_HAND,
		"INTERACT_ATOM_UI_INTERACT" = INTERACT_ATOM_UI_INTERACT,
		"INTERACT_ATOM_REQUIRES_DEXTERITY" = INTERACT_ATOM_REQUIRES_DEXTERITY,
		"INTERACT_ATOM_IGNORE_INCAPACITATED" = INTERACT_ATOM_IGNORE_INCAPACITATED,
		"INTERACT_ATOM_IGNORE_RESTRAINED" = INTERACT_ATOM_IGNORE_RESTRAINED,
		"INTERACT_ATOM_CHECK_GRAB" = INTERACT_ATOM_CHECK_GRAB,
		"INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND" = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND,
		"INTERACT_ATOM_NO_FINGERPRINT_INTERACT" = INTERACT_ATOM_NO_FINGERPRINT_INTERACT
		),
	"interaction_flags_machine" = list(
		"INTERACT_MACHINE_OPEN" = INTERACT_MACHINE_OPEN,
		"INTERACT_MACHINE_OFFLINE" = INTERACT_MACHINE_OFFLINE,
		"INTERACT_MACHINE_WIRES_IF_OPEN" = INTERACT_MACHINE_WIRES_IF_OPEN,
		"INTERACT_MACHINE_ALLOW_SILICON" = INTERACT_MACHINE_ALLOW_SILICON,
		"INTERACT_MACHINE_OPEN_SILICON" = INTERACT_MACHINE_OPEN_SILICON,
		"INTERACT_MACHINE_REQUIRES_SILICON" = INTERACT_MACHINE_REQUIRES_SILICON,
		"INTERACT_MACHINE_SET_MACHINE" = INTERACT_MACHINE_SET_MACHINE
		),
	"pass_flags" = list(
		"PASSTABLE" = PASSTABLE,
		"PASSGLASS" = PASSGLASS,
		"PASSGRILLE" = PASSGRILLE,
		"PASSBLOB" = PASSBLOB,
		"PASSMOB" = PASSMOB,
		"PASSCLOSEDTURF" = PASSCLOSEDTURF,
		"LETPASSTHROW" = LETPASSTHROW
		),
	"movement_type" = list(
		"GROUND" = GROUND,
		"FLYING" = FLYING
		),
	"resistance_flags" = list(
		"LAVA_PROOF" = LAVA_PROOF,
		"FIRE_PROOF" = FIRE_PROOF,
		"FLAMMABLE" = FLAMMABLE,
		"ON_FIRE" = ON_FIRE,
		"UNACIDABLE" = UNACIDABLE,
		"ACID_PROOF" = ACID_PROOF,
		"INDESTRUCTIBLE" = INDESTRUCTIBLE,
		"FREEZE_PROOF" = FREEZE_PROOF
		),
	"reagents_holder_flags" = list(
		"REAGENT_NOREACT" = REAGENT_NOREACT
		),
	"flags_1" = list(
		"NOJAUNT_1" = NOJAUNT_1,
		"NODROP_1 / UNUSED_TRANSIT_TURF_1 (turfs)" = NODROP_1,
		"NOBLUDGEON_1 / CAN_BE_DIRTY_1 (turfs)" = NOBLUDGEON_1,
		"HEAR_1 / NO_DEATHRATTLE_1 (turfs)" = HEAR_1,
		"CHECK_RICOCHET_1 / NO_RUINS_1 (turfs)" = CHECK_RICOCHET_1,
		"CONDUCT_1 / NO_LAVA_GEN_1" = CONDUCT_1,
		"ABSTRACT_1" = ABSTRACT_1,
		"NODECONSTRUCT_1" = NODECONSTRUCT_1,
		"OVERLAY_QUEUED_1" = OVERLAY_QUEUED_1,
		),
	"flags_2" = list(
		"NO_EMP_WIRES_2" = NO_EMP_WIRES_2,
		"HOLOGRAM_2" = HOLOGRAM_2,
		"BANG_PROTECT_2" = BANG_PROTECT_2,
		"HEALS_EARS_2" = HEALS_EARS_2,
		"OMNITONGUE_2" = OMNITONGUE_2,
		"TESLA_IGNORE_2" = TESLA_IGNORE_2,
		"NO_MAT_REDEMPTION_2" = NO_MAT_REDEMPTION_2
		),
	"clothing_flags" = list(
		"LAVAPROTECT" = LAVAPROTECT,
		"STOPSPRESSUREDAMAGE" = STOPSPRESSUREDAMAGE,
		"BLOCK_GAS_SMOKE_EFFECT" = BLOCK_GAS_SMOKE_EFFECT,
		"MASKINTERNALS" = MASKINTERNALS,
		"NOSLIP" = NOSLIP,
		"THICKMATERIAL" = THICKMATERIAL,
	)
	))
