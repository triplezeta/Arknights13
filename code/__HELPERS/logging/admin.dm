/* Items with ADMINPRIVATE prefixed are stripped from public logs. */

/// General logging for admin actions
/proc/log_admin(text)
	GLOB.admin_log.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN, text)

/// Logging for admin actions on or with circuits
/proc/log_admin_circuit(text)
	GLOB.admin_log.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN_CIRCUIT, text)

/// General logging for admin actions
/proc/log_admin_private(text)
	GLOB.admin_log.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN_PRIVATE, text)

/// Logging for AdminSay (ASAY) messages
/proc/log_adminsay(text)
	GLOB.admin_log.Add(text)
	logger.Log(LOG_CATEGORY_ADMIN_PRIVATE_ASAY, text)

/// Logging for DeachatSay (DSAY) messages
/proc/log_dsay(text)
	logger.Log(LOG_CATEGORY_ADMIN_DSAY, text)

/**
 * Writes to a special log file if the log_suspicious_login config flag is set,
 * which is intended to contain all logins that failed under suspicious circumstances.
 *
 * Mirrors this log entry to log_access when access_log_mirror is TRUE, so this proc
 * doesn't need to be used alongside log_access and can replace it where appropriate.
 */
/proc/log_suspicious_login(text, access_log_mirror = TRUE)
	logger.Log(LOG_CATEGORY_SUSPICIOUS_LOGIN, text)
	if(access_log_mirror)
		log_access(text)
