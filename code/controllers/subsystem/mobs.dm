var/datum/subsystem/mobs/SSmob

/datum/subsystem/mobs
	name = "Mobs"
	priority = 4


/datum/subsystem/mobs/New()
	NEW_SS_GLOBAL(SSmob)


/datum/subsystem/mobs/stat_entry()
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%) [mob_list.len]")


/datum/subsystem/mobs/fire()
	var/seconds = wait * 0.1
	for(var/thing in mob_list)
		if(thing)
			thing:Life(seconds)
			continue
		mob_list.Remove(thing)