//Fires five times every second.

var/datum/subsystem/processing/fastprocess/SSfastprocess
/datum/subsystem/processing/fastprocess
	name = "Fast Processing"
	priority = 25
	wait = 2
	stat_tag = "FP"

/datum/subsystem/processing/fastprocess/New()
	NEW_SS_GLOBAL(SSfastprocess)

/datum/subsystem/processing/fastprocess/Recover()
	..(SSfastprocess)