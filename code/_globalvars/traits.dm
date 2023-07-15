/*
	FUN ZONE OF ADMIN LISTINGS
	Try to keep this in sync with __DEFINES/traits.dm
	quirks have it's own panel so we don't need them here.
*/
GLOBAL_LIST_INIT(traits_by_type, list(
	/mob = list(
		"TRAIT_KNOCKEDOUT" = TRAIT_KNOCKEDOUT,
		"TRAIT_IMMOBILIZED" = TRAIT_IMMOBILIZED,
		"TRAIT_FLOORED" = TRAIT_FLOORED,
		"TRAIT_FORCED_STANDING" = TRAIT_FORCED_STANDING,
		"TRAIT_HANDS_BLOCKED" = TRAIT_HANDS_BLOCKED,
		"TRAIT_UI_BLOCKED" = TRAIT_UI_BLOCKED,
		"TRAIT_PULL_BLOCKED" = TRAIT_PULL_BLOCKED,
		"TRAIT_RESTRAINED" = TRAIT_RESTRAINED,
		"TRAIT_PERFECT_ATTACKER" = TRAIT_PERFECT_ATTACKER,
		"TRAIT_GREENTEXT_CURSED" = TRAIT_GREENTEXT_CURSED,
		"TRAIT_INCAPACITATED" = TRAIT_INCAPACITATED,
		"TRAIT_CRITICAL_CONDITION" = TRAIT_CRITICAL_CONDITION,
		"TRAIT_LITERATE" = TRAIT_LITERATE,
		"TRAIT_ILLITERATE" = TRAIT_ILLITERATE,
		"TRAIT_MUTE" = TRAIT_MUTE,
		"TRAIT_EMOTEMUTE " = TRAIT_EMOTEMUTE,
		"TRAIT_DEAF" = TRAIT_DEAF,
		"TRAIT_FAT" = TRAIT_FAT,
		"TRAIT_HUSK" = TRAIT_HUSK,
		"TRAIT_DEFIB_BLACKLISTED" = TRAIT_DEFIB_BLACKLISTED,
		"TRAIT_BADDNA" = TRAIT_BADDNA,
		"TRAIT_CLUMSY" = TRAIT_CLUMSY,
		"TRAIT_CHUNKYFINGERS" = TRAIT_CHUNKYFINGERS,
		"TRAIT_CHUNKYFINGERS_IGNORE_BATON" = TRAIT_CHUNKYFINGERS_IGNORE_BATON,
		"TRAIT_FIST_MINING" = TRAIT_FIST_MINING,
		"TRAIT_DUMB" = TRAIT_DUMB,
		"TRAIT_ADVANCEDTOOLUSER" = TRAIT_ADVANCEDTOOLUSER,
		"TRAIT_DISCOORDINATED_TOOL_USER" = TRAIT_DISCOORDINATED_TOOL_USER,
		"TRAIT_PACIFISM" = TRAIT_PACIFISM,
		"TRAIT_IGNORESLOWDOWN" = TRAIT_IGNORESLOWDOWN,
		"TRAIT_IGNOREDAMAGESLOWDOWN" = TRAIT_IGNOREDAMAGESLOWDOWN,
		"TRAIT_DEATHCOMA" = TRAIT_DEATHCOMA,
		"TRAIT_FAKEDEATH" = TRAIT_FAKEDEATH,
		"TRAIT_DISFIGURED" = TRAIT_DISFIGURED,
		"TRAIT_XENO_HOST" = TRAIT_XENO_HOST,
		"TRAIT_STUNIMMUNE" = TRAIT_STUNIMMUNE,
		"TRAIT_BATON_RESISTANCE" = TRAIT_BATON_RESISTANCE,
		"TRAIT_IWASBATONED" = TRAIT_IWASBATONED,
		"TRAIT_SLEEPIMMUNE" = TRAIT_SLEEPIMMUNE,
		"TRAIT_PUSHIMMUNE" = TRAIT_PUSHIMMUNE,
		"TRAIT_SHOCKIMMUNE" = TRAIT_SHOCKIMMUNE,
		"TRAIT_TESLA_SHOCKIMMUNE" = TRAIT_TESLA_SHOCKIMMUNE,
		"TRAIT_STABLEHEART" = TRAIT_STABLEHEART,
		"TRAIT_STABLELIVER" = TRAIT_STABLELIVER,
		"TRAIT_RESISTHEAT" = TRAIT_RESISTHEAT,
		"TRAIT_USED_DNA_VAULT" = TRAIT_USED_DNA_VAULT,
		"TRAIT_RESISTHEATHANDS" = TRAIT_RESISTHEATHANDS,
		"TRAIT_RESISTCOLD" = TRAIT_RESISTCOLD,
		"TRAIT_RESISTHIGHPRESSURE" = TRAIT_RESISTHIGHPRESSURE,
		"TRAIT_RESISTLOWPRESSURE" = TRAIT_RESISTLOWPRESSURE,
		"TRAIT_BOMBIMMUNE" = TRAIT_BOMBIMMUNE,
		"TRAIT_RADIMMUNE" = TRAIT_RADIMMUNE,
		"TRAIT_GENELESS" = TRAIT_GENELESS,
		"TRAIT_VIRUSIMMUNE" = TRAIT_VIRUSIMMUNE,
		"TRAIT_PIERCEIMMUNE" = TRAIT_PIERCEIMMUNE,
		"TRAIT_NODISMEMBER" = TRAIT_NODISMEMBER,
		"TRAIT_NOFIRE" = TRAIT_NOFIRE,
		"TRAIT_NOGUNS" = TRAIT_NOGUNS,
		"TRAIT_NOHUNGER" = TRAIT_NOHUNGER,
		"TRAIT_LIVERLESS_METABOLISM" = TRAIT_LIVERLESS_METABOLISM,
		"TRAIT_PLASMA_LOVER_METABOLISM" = TRAIT_PLASMA_LOVER_METABOLISM,
		"TRAIT_NOCLONELOSS" = TRAIT_NOCLONELOSS,
		"TRAIT_TOXIMMUNE" = TRAIT_TOXIMMUNE,
		"TRAIT_EASYDISMEMBER" = TRAIT_EASYDISMEMBER,
		"TRAIT_LIMBATTACHMENT" = TRAIT_LIMBATTACHMENT,
		"TRAIT_NOLIMBDISABLE" = TRAIT_NOLIMBDISABLE,
		"TRAIT_EASILY_WOUNDED" = TRAIT_EASILY_WOUNDED,
		"TRAIT_HARDLY_WOUNDED" = TRAIT_HARDLY_WOUNDED,
		"TRAIT_NEVER_WOUNDED" = TRAIT_NEVER_WOUNDED,
		"TRAIT_TOXINLOVER" = TRAIT_TOXINLOVER,
		"TRAIT_NOCRITOVERLAY" = TRAIT_NOCRITOVERLAY,
		"TRAIT_NOBREATH" = TRAIT_NOBREATH,
		"TRAIT_ANTIMAGIC" = TRAIT_ANTIMAGIC,
		"TRAIT_HOLY" = TRAIT_HOLY,
		"TRAIT_DEPRESSION" = TRAIT_DEPRESSION,
		"TRAIT_BLOOD_DEFICIENCY" = TRAIT_BLOOD_DEFICIENCY,
		"TRAIT_JOLLY" = TRAIT_JOLLY,
		"TRAIT_NOCRITDAMAGE" = TRAIT_NOCRITDAMAGE,
		"TRAIT_NO_SLIP_WATER" = TRAIT_NO_SLIP_WATER,
		"TRAIT_NO_SLIP_ICE" = TRAIT_NO_SLIP_ICE,
		"TRAIT_NO_SLIP_SLIDE" = TRAIT_NO_SLIP_SLIDE,
		"TRAIT_NO_SLIP_ALL" = TRAIT_NO_SLIP_ALL,
		"TRAIT_NODEATH" = TRAIT_NODEATH,
		"TRAIT_NOHARDCRIT" = TRAIT_NOHARDCRIT,
		"TRAIT_NOSOFTCRIT" = TRAIT_NOSOFTCRIT,
		"TRAIT_MINDSHIELD" = TRAIT_MINDSHIELD,
		"TRAIT_DISSECTED" = TRAIT_DISSECTED,
		"TRAIT_SIXTHSENSE" = TRAIT_SIXTHSENSE,
		"TRAIT_FEARLESS" = TRAIT_FEARLESS,
		"TRAIT_PARALYSIS_L_ARM" = TRAIT_PARALYSIS_L_ARM,
		"TRAIT_PARALYSIS_R_ARM" = TRAIT_PARALYSIS_R_ARM,
		"TRAIT_PARALYSIS_L_LEG" = TRAIT_PARALYSIS_L_LEG,
		"TRAIT_PARALYSIS_R_LEG" = TRAIT_PARALYSIS_R_LEG,
		"TRAIT_CANNOT_OPEN_PRESENTS" = TRAIT_CANNOT_OPEN_PRESENTS,
		"TRAIT_PRESENT_VISION" = TRAIT_PRESENT_VISION,
		"TRAIT_DISK_VERIFIER" = TRAIT_DISK_VERIFIER,
		"TRAIT_BYPASS_MEASURES" = TRAIT_BYPASS_MEASURES,
		"TRAIT_NOMOBSWAP" = TRAIT_NOMOBSWAP,
		"TRAIT_XRAY_VISION" = TRAIT_XRAY_VISION,
		"TRAIT_WEB_WEAVER" = TRAIT_WEB_WEAVER,
		"TRAIT_WEB_SURFER" = TRAIT_WEB_SURFER,
		"TRAIT_THERMAL_VISION" = TRAIT_THERMAL_VISION,
		"TRAIT_ABDUCTOR_TRAINING" = TRAIT_ABDUCTOR_TRAINING,
		"TRAIT_ABDUCTOR_SCIENTIST_TRAINING" = TRAIT_ABDUCTOR_SCIENTIST_TRAINING,
		"TRAIT_SURGEON" = TRAIT_SURGEON,
		"TRAIT_STRONG_GRABBER" = TRAIT_STRONG_GRABBER,
		"TRAIT_SOOTHED_THROAT" = TRAIT_SOOTHED_THROAT,
		"TRAIT_BOOZE_SLIDER" = TRAIT_BOOZE_SLIDER,
		"TRAIT_QUICK_CARRY" = TRAIT_QUICK_CARRY,
		"TRAIT_QUICKER_CARRY" = TRAIT_QUICKER_CARRY,
		"TRAIT_PLANT_SAFE" = TRAIT_PLANT_SAFE,
		"TRAIT_UNINTELLIGIBLE_SPEECH" = TRAIT_UNINTELLIGIBLE_SPEECH,
		"TRAIT_UNSTABLE" = TRAIT_UNSTABLE,
		"TRAIT_OIL_FRIED" = TRAIT_OIL_FRIED,
		"TRAIT_MEDICAL_HUD" = TRAIT_MEDICAL_HUD,
		"TRAIT_SECURITY_HUD" = TRAIT_SECURITY_HUD,
		"TRAIT_DIAGNOSTIC_HUD" = TRAIT_DIAGNOSTIC_HUD,
		"TRAIT_TRAIT_MEDIBOTCOMINGTHROUGH" = TRAIT_MEDIBOTCOMINGTHROUGH,
		"TRAIT_PASSTABLE" = TRAIT_PASSTABLE,
		"TRAIT_NOFLASH" = TRAIT_NOFLASH,
		"TRAIT_XENO_IMMUNE" = TRAIT_XENO_IMMUNE,
		"TRAIT_NAIVE" = TRAIT_NAIVE,
		"TRAIT_PRIMITIVE" = TRAIT_PRIMITIVE, //unable to use mechs. Given to Ash Walkers
		"TRAIT_GUNFLIP" = TRAIT_GUNFLIP,
		"TRAIT_SPECIAL_TRAUMA_BOOST" = TRAIT_SPECIAL_TRAUMA_BOOST,
		"TRAIT_SPACEWALK" = TRAIT_SPACEWALK,
		"TRAIT_GAMERGOD" = TRAIT_GAMERGOD,
		"TRAIT_GIANT" = TRAIT_GIANT,
		"TRAIT_DWARF" = TRAIT_DWARF,
		"TRAIT_SILENT_FOOTSTEPS" = TRAIT_SILENT_FOOTSTEPS,
		"TRAIT_NICE_SHOT" = TRAIT_NICE_SHOT,
		"TRAIT_TUMOR_SUPPRESSION" = TRAIT_TUMOR_SUPPRESSED,
		"TRAIT_PERMANENTLY_ONFIRE" = TRAIT_PERMANENTLY_ONFIRE,
		"TRAIT_SIGN_LANG" = TRAIT_SIGN_LANG,
		"TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE" = TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE,
		"TRAIT_WINE_TASTER" = TRAIT_WINE_TASTER,
		"TRAIT_BONSAI" = TRAIT_BONSAI,
		"TRAIT_LIGHTBULB_REMOVER" = TRAIT_LIGHTBULB_REMOVER,
		"TRAIT_KNOW_CYBORG_WIRES" = TRAIT_KNOW_CYBORG_WIRES,
		"TRAIT_KNOW_ENGI_WIRES" = TRAIT_KNOW_ENGI_WIRES,
		"TRAIT_ALCOHOL_TOLERANCE" = TRAIT_ALCOHOL_TOLERANCE,
		"TRAIT_AGEUSIA" = TRAIT_AGEUSIA,
		"TRAIT_HEAVY_SLEEPER" = TRAIT_HEAVY_SLEEPER,
		"TRAIT_NIGHT_VISION" = TRAIT_NIGHT_VISION,
		"TRAIT_LIGHT_STEP" = TRAIT_LIGHT_STEP,
		"TRAIT_SPIRITUAL" = TRAIT_SPIRITUAL,
		"TRAIT_CLOWN_ENJOYER" = TRAIT_CLOWN_ENJOYER,
		"TRAIT_MIME_FAN" = TRAIT_MIME_FAN,
		"TRAIT_VORACIOUS" = TRAIT_VORACIOUS,
		"TRAIT_SELF_AWARE" = TRAIT_SELF_AWARE,
		"TRAIT_FREERUNNING" = TRAIT_FREERUNNING,
		"TRAIT_SKITTISH" = TRAIT_SKITTISH,
		"TRAIT_PROSOPAGNOSIA" = TRAIT_PROSOPAGNOSIA,
		"TRAIT_TAGGER" = TRAIT_TAGGER,
		"TRAIT_PHOTOGRAPHER" = TRAIT_PHOTOGRAPHER,
		"TRAIT_MUSICIAN" = TRAIT_MUSICIAN,
		"TRAIT_LIGHT_DRINKER" = TRAIT_LIGHT_DRINKER,
		"TRAIT_SMOKER" = TRAIT_SMOKER,
		"TRAIT_EMPATH" = TRAIT_EMPATH,
		"TRAIT_FRIENDLY" = TRAIT_FRIENDLY,
		"TRAIT_GRABWEAKNESS" = TRAIT_GRABWEAKNESS,
		"TRAIT_SNOB" = TRAIT_SNOB,
		"TRAIT_BALD" = TRAIT_BALD,
		"TRAIT_BADTOUCH" = TRAIT_BADTOUCH,
		"TRAIT_AGENDER" = TRAIT_AGENDER,
		"TRAIT_BLOOD_CLANS" = TRAIT_BLOOD_CLANS,
		"TRAIT_HAS_MARKINGS" = TRAIT_HAS_MARKINGS,
		"TRAIT_USES_SKINTONES" = TRAIT_USES_SKINTONES,
		"TRAIT_MUTANT_COLORS" = TRAIT_MUTANT_COLORS,
		"TRAIT_FIXED_MUTANT_COLORS" = TRAIT_FIXED_MUTANT_COLORS,
		"TRAIT_NO_BLOOD_OVERLAY" = TRAIT_NO_BLOOD_OVERLAY,
		"TRAIT_NO_UNDERWEAR" = TRAIT_NO_UNDERWEAR,
		"TRAIT_NO_AUGMENTS" = TRAIT_NO_AUGMENTS,
		"TRAIT_NOBLOOD" = TRAIT_NOBLOOD,
		"TRAIT_LIVERLESS_METABOLISM" = TRAIT_LIVERLESS_METABOLISM,
		"TRAIT_NO_ZOMBIFY" = TRAIT_NO_ZOMBIFY,
		"TRAIT_NO_TRANSFORMATION_STING" = TRAIT_NO_TRANSFORMATION_STING,
		"TRAIT_NO_DNA_COPY" = TRAIT_NO_DNA_COPY,
		"TRAIT_DRINKS_BLOOD" = TRAIT_DRINKS_BLOOD,
		"TRAIT_KISS_OF_DEATH" = TRAIT_KISS_OF_DEATH,
		"TRAIT_ANXIOUS" = TRAIT_ANXIOUS,
		"TRAIT_WEAK_SOUL" = TRAIT_WEAK_SOUL,
		"TRAIT_NO_SOUL" = TRAIT_NO_SOUL,
		"TRAIT_INVISIBLE_MAN" = TRAIT_INVISIBLE_MAN,
		"TRAIT_HIDE_EXTERNAL_ORGANS" = TRAIT_HIDE_EXTERNAL_ORGANS,
		"TRAIT_CULT_HALO" = TRAIT_CULT_HALO,
		"TRAIT_UNNATURAL_RED_GLOWY_EYES" = TRAIT_UNNATURAL_RED_GLOWY_EYES,
		"TRAIT_BLOODSHOT_EYES" = TRAIT_BLOODSHOT_EYES,
		"TRAIT_SHIFTY_EYES" = TRAIT_SHIFTY_EYES,
		"TRAIT_CANNOT_BE_UNBUCKLED" = TRAIT_CANNOT_BE_UNBUCKLED,
		"TRAIT_GAMER" = TRAIT_GAMER,
		"TRAIT_UNKNOWN" = TRAIT_UNKNOWN,
		"TRAIT_CHASM_DESTROYED" = TRAIT_CHASM_DESTROYED,
		"TRAIT_MIMING" = TRAIT_MIMING,
		"TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION" = TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION,
		"TRAIT_UNOBSERVANT" = TRAIT_UNOBSERVANT,
		"TRAIT_MORBID" = TRAIT_MORBID,
	),
	/obj/item/bodypart = list(
		"TRAIT_PARALYSIS" = TRAIT_PARALYSIS,
		),
	/obj/item/organ/internal/lungs = list(
		"TRAIT_SPACEBREATHING" = TRAIT_SPACEBREATHING,
		),
	/obj/item/organ/internal/liver = list(
		"TRAIT_LAW_ENFORCEMENT_METABOLISM" = TRAIT_LAW_ENFORCEMENT_METABOLISM,
		"TRAIT_CULINARY_METABOLISM" = TRAIT_CULINARY_METABOLISM,
		"TRAIT_COMEDY_METABOLISM" = TRAIT_COMEDY_METABOLISM,
		"TRAIT_MEDICAL_METABOLISM" = TRAIT_MEDICAL_METABOLISM,
		"TRAIT_ENGINEER_METABOLISM" = TRAIT_ENGINEER_METABOLISM,
		"TRAIT_ROYAL_METABOLISM" = TRAIT_ROYAL_METABOLISM,
		"TRAIT_PRETENDER_ROYAL_METABOLISM" = TRAIT_PRETENDER_ROYAL_METABOLISM,
		"TRAIT_BALLMER_SCIENTIST" = TRAIT_BALLMER_SCIENTIST,
		"TRAIT_MAINTENANCE_METABOLISM" = TRAIT_MAINTENANCE_METABOLISM,
		"TRAIT_CORONER_METABOLISM" = TRAIT_CORONER_METABOLISM,
		),
	/obj/item = list(
		"TRAIT_NODROP" = TRAIT_NODROP,
		"TRAIT_NO_STORAGE_INSERT" = TRAIT_NO_STORAGE_INSERT,
		"TRAIT_T_RAY_VISIBLE" = TRAIT_T_RAY_VISIBLE,
		"TRAIT_NO_TELEPORT" = TRAIT_NO_TELEPORT,
		"TRAIT_APC_SHOCKING" = TRAIT_APC_SHOCKING,
		"TRAIT_UNCATCHABLE" = TRAIT_UNCATCHABLE,
		"TRAIT_DANGEROUS_OBJECT" = TRAIT_DANGEROUS_OBJECT,
		"TRAIT_GERM_SENSITIVE" = TRAIT_GERM_SENSITIVE,
		),
	/atom = list(
		"TRAIT_KEEP_TOGETHER" = TRAIT_KEEP_TOGETHER,
		),
	/atom/movable = list(
		"TRAIT_MOVE_GROUND" = TRAIT_MOVE_GROUND,
		"TRAIT_MOVE_FLYING" = TRAIT_MOVE_FLYING,
		"TRAIT_MOVE_VENTCRAWLING" = TRAIT_MOVE_VENTCRAWLING,
		"TRAIT_MOVE_FLOATING" = TRAIT_MOVE_FLOATING,
		"TRAIT_MOVE_PHASING" = TRAIT_MOVE_PHASING,
		"TRAIT_LAVA_IMMUNE" = TRAIT_LAVA_IMMUNE,
		"TRAIT_ASHSTORM_IMMUNE" = TRAIT_ASHSTORM_IMMUNE,
		"TRAIT_SNOWSTORM_IMMUNE" = TRAIT_SNOWSTORM_IMMUNE,
		"TRAIT_VOIDSTORM_IMMUNE" = TRAIT_VOIDSTORM_IMMUNE,
		"TRAIT_WEATHER_IMMUNE" = TRAIT_WEATHER_IMMUNE,
		"TRAIT_RUNECHAT_HIDDEN" = TRAIT_RUNECHAT_HIDDEN,
		"TRAIT_HAS_LABEL" = TRAIT_HAS_LABEL,
		),
	/obj/item/card/id = list(
		"TRAIT_MAGNETIC_ID_CARD" = TRAIT_MAGNETIC_ID_CARD,
	),
))

/// value -> trait name, generated on use from trait_by_type global
GLOBAL_LIST(trait_name_map)

/proc/generate_trait_name_map()
	. = list()
	for(var/key in GLOB.traits_by_type)
		for(var/tname in GLOB.traits_by_type[key])
			var/val = GLOB.traits_by_type[key][tname]
			.[val] = tname

GLOBAL_LIST_INIT(movement_type_trait_to_flag, list(
	TRAIT_MOVE_GROUND = GROUND,
	TRAIT_MOVE_FLYING = FLYING,
	TRAIT_MOVE_VENTCRAWLING = VENTCRAWLING,
	TRAIT_MOVE_FLOATING = FLOATING,
	TRAIT_MOVE_PHASING = PHASING
	))

GLOBAL_LIST_INIT(movement_type_addtrait_signals, set_movement_type_addtrait_signals())
GLOBAL_LIST_INIT(movement_type_removetrait_signals, set_movement_type_removetrait_signals())

/proc/set_movement_type_addtrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_ADDTRAIT(trait)

/proc/set_movement_type_removetrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_REMOVETRAIT(trait)
