//schools of magic - unused for years and years on end, finally has a use with chaplains getting punished for using "evil" spells

//use this if your spell isn't actually a spell, it's set by default (and actually, i really suggest if that's the case you should use datum/actions instead - see spider.dm for an example)
#define SCHOOL_UNSET "unset"

//GOOD SCHOOLS (allowed by honorbound gods, some of these you can get on station)
#define SCHOOL_HOLY "holy"
#define SCHOOL_MIME "mime"
#define SCHOOL_RESTORATION "restoration" //heal shit

//NEUTRAL SPELLS (punished by honorbound gods if you get caught using it)
#define SCHOOL_EVOCATION "evocation" //kill or destroy shit, usually out of thin air
#define SCHOOL_TRANSMUTATION "transmutation" //transform shit
#define SCHOOL_TRANSLOCATION "translocation" //movement based
#define SCHOOL_CONJURATION "conjuration" //summoning

//EVIL SPELLS (instant smite + banishment)
#define SCHOOL_NECROMANCY "necromancy" //>>>necromancy
#define SCHOOL_FORBIDDEN "forbidden" //>heretic shit and other fucked up magic

//invocation types - what does the wizard need to do to invoke (cast) the spell?

///Forces the wizard to shout (and be able to) to cast the spell.
#define INVOCATION_SHOUT "shout"
///Forces the wizard to emote (and be able to) to cast the spell.
#define INVOCATION_EMOTE "emote"
///Forces the wizard to whisper (and be able to) to cast the spell.
#define INVOCATION_WHISPER "whisper"

// magic resistance bitflags - used by /mob/proc/anti_magic_check and anti_magic componenent
/// Default magic resistance that blocks normal magic (wizard, spells, staffs)
#define MAGIC_RESISTANCE (1<<0)
/// Tinfoil hat magic resistance that blocks mental magic (telepathy, abductors, jelly people)
#define MAGIC_RESISTANCE_MIND (1<<1)
/// Holy magic resistance that blocks unholy magic (revenant, cult, vampire, voice of god, )
#define MAGIC_RESISTANCE_UNHOLY (1<<2)
/// Prevents a user from casting magic
#define MAGIC_CASTING_RESTRICTION (1<<3)
/// All magic resistances combined
#define MAGIC_RESISTANCE_ALL (MAGIC_RESISTANCE | MAGIC_RESISTANCE_MIND | MAGIC_RESISTANCE_UNHOLY | MAGIC_CASTING_RESTRICTION)
