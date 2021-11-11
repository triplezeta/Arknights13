/// Default value for the max_complexity var on modsuits
#define DEFAULT_MAX_COMPLEXITY 15

/// Passive module, just acts when put in naturally.
#define MODULE_PASSIVE 0
/// Usable module, does something when you press a button.
#define MODULE_USABLE 1
/// Toggle module, you turn it on/off and it does stuff.
#define MODULE_TOGGLE 2
/// Actively usable module, you may only have one selected at a time.
#define MODULE_ACTIVE 3

//Defines used by the theme for clothing flags
#define HELMET_FLAGS "helmet_flags"
#define CHESTPLATE_FLAGS "chestplate_flags"
#define GAUNTLETS_FLAGS "gauntlets_flags"
#define BOOTS_FLAGS "boots_flags"

#define UNSEALED_CLOTHING "unsealed_clothing"
#define SEALED_CLOTHING "sealed_clothing"
#define UNSEALED_INVISIBILITY "unsealed_invisibility"
#define SEALED_INVISIBILITY "sealed_invisibility"
#define UNSEALED_COVER "unsealed_cover"
#define SEALED_COVER "sealed_cover"

/// Global list of all /datum/mod_theme
GLOBAL_LIST_INIT(mod_themes, setup_mod_themes())
