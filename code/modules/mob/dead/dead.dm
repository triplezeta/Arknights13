//Dead mobs can exist whenever. This is needful
/mob/dead/New(loc)
	..()
	if(!initialized)
		if(args.len)
			args[1] = FALSE
			Initialize(arglist(args))	//EXIST DAMN YOU!!!
		else
			Initialize()

/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return
