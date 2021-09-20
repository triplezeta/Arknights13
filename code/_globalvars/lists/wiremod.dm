/// The basic player-facing types that don't have any super special behaviour.
GLOBAL_LIST_INIT(wiremod_basic_types, list(
	PORT_TYPE_ANY,
	PORT_TYPE_STRING,
	PORT_TYPE_NUMBER,
	PORT_TYPE_SIGNAL,
	PORT_TYPE_LIST,
	PORT_TYPE_TABLE,
	PORT_TYPE_ATOM,
))

/// All basic types that don't have any super special behavior. This includes the admin-only datum type.
GLOBAL_LIST_INIT(wiremod_admin_basic_types, list(
	PORT_TYPE_ANY,
	PORT_TYPE_STRING,
	PORT_TYPE_NUMBER,
	PORT_TYPE_SIGNAL,
	PORT_TYPE_LIST,
	PORT_TYPE_TABLE,
	PORT_TYPE_ATOM,
	PORT_TYPE_DATUM,
))

/// The fundamental datatypes of the byond game engine.
GLOBAL_LIST_INIT(wiremod_fundamental_types, list(
	PORT_TYPE_ANY,
	PORT_TYPE_NUMBER,
	PORT_TYPE_ATOM,
	PORT_TYPE_DATUM,
	PORT_TYPE_STRING,
	PORT_TYPE_LIST,
))
