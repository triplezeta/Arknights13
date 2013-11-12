//CORTEX BORER'S - (Baystation's Cortical borers)

/*
With thanks to:
Baystation 12 - For coding this feature
Baystation 12 - For porting permission

RobRichards's notes:
- Removed Baystation 12 only reagent from reagent list
- Prevented Alien drone's "Evolve" verb from allowing Borer's to activate it - It was buggy
- Added some has_brain_worms() stuff on mob transformations etc.
- Renamed Cortical Borers to Cortex Borers, I see where Baystation 12 were going with it but I think Cortex handles the situation better
*/


/mob/living/captive_brain
        name = "host brain"
        real_name = "host brain"

/mob/living/captive_brain/say(var/message)

        if (src.client)
                if(client.prefs.muted & MUTE_IC)
                        src << "\red You cannot speak in IC (muted)."
                        return
                if (src.client.handle_spam_prevention(message,MUTE_IC))
                        return

        if(istype(src.loc,/mob/living/simple_animal/borer))
                var/mob/living/simple_animal/borer/B = src.loc
                src << "You whisper silently, \"[message]\""
                B.host << "The captive mind of [src] whispers, \"[message]\""

/mob/living/captive_brain/emote(var/message)
        return

/mob/living/simple_animal/borer
        name = "Cortex Borer"
        real_name = "Cortex Borer"
        desc = "A small, quivering sluglike creature."
        speak_emote = list("chirrups")
        emote_hear = list("chirrups")
        response_help  = "pokes the"
        response_disarm = "prods the"
        response_harm   = "stomps on the"
        icon_state = "brainslug"
        icon_living = "brainslug"
        icon_dead = "brainslug_dead"
        speed = 4
        a_intent = "harm"
        stop_automated_movement = 1
        status_flags = CANPUSH
        attacktext = "nips"
        friendly = "prods"
        wander = 0
        pass_flags = PASSTABLE

        var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
        var/mob/living/carbon/human/host        // Human host for the brain worm.
        var/truename                            // Name used for brainworm-speak.
        var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
        var/controlling                         // Used in human death check.

/mob/living/simple_animal/borer/Life()

        ..()
        if(host)
                if(!stat && !host.stat) //Need a brain - RR
                        if(chemicals < 250)
                                chemicals++
                        if(controlling)
                                if(prob(5))
                                        host.adjustBrainLoss(rand(1,2))

                                if(prob(host.brainloss/20))
                                        host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")




/mob/living/simple_animal/borer/New()
        ..()
        truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"
        host_brain = new/mob/living/captive_brain(src)

        request_player()


/mob/living/simple_animal/borer/say(var/message)

        message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
        message = capitalize(message)

        if(!message)
                return

        if (stat == 2)
                return say_dead(message)

        if (stat)
                return

        if (src.client)
                if(client.prefs.muted & MUTE_IC)
                        src << "\red You cannot speak in IC (muted)."
                        return
                if (src.client.handle_spam_prevention(message,MUTE_IC))
                        return

        if (copytext(message, 1, 2) == "*")
                return emote(copytext(message, 2))

        if (copytext(message, 1, 2) == ";") //Brain borer hivemind.
                return borer_speak(message)

        if(!host)
                src << "You have no host to speak to."
                return //No host, no audible speech.

        src << "You drop words into [host]'s mind: \"[message]\""
        host << "Your own thoughts speak: \"[message]\""

/mob/living/simple_animal/borer/Stat()
        ..()
        statpanel("Status")

        if(emergency_shuttle)
                if(emergency_shuttle.online && emergency_shuttle.location < 2)
                        var/timeleft = emergency_shuttle.timeleft()
                        if (timeleft)
                                stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

        if (client.statpanel == "Status")
                stat("Chemicals", chemicals)

// VERBS!

/mob/living/simple_animal/borer/proc/borer_speak(var/message)
        if(!message)
                return

        for(var/mob/M in mob_list)
                if(M.mind && (istype(M, /mob/living/simple_animal/borer) || istype(M, /mob/dead/observer)))
                        M << "<i>Cortex link, <b>[truename]:</b> [copytext(message, 2)]</i>"

/mob/living/simple_animal/borer/verb/bond_brain()
        set category = "Borer"
        set name = "Assume Control"
        set desc = "Fully connect to the brain of your host."

        if(!host)
                src << "You are not inside a host body."
                return


        if(src.stat)
                src << "You cannot do that in your current state."
                return

        if(!host.getorgan(/obj/item/organ/brain)) //this should only run in admin-weirdness situations, but it's here non the less - RR
        								src << "<span class='warning'>There is no brain here for us to command!</span>"
        								return



        src << "You begin delicately adjusting your connection to the host brain..."

        spawn(300+(host.brainloss*5))

                if(!host || !src || controlling) return

                else
                        src << "\red <B>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</B>"
                        host << "\red <B>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</B>"

                        host_brain.ckey = host.ckey
                        host.ckey = src.ckey
                        controlling = 1

                        host.verbs += /mob/living/carbon/proc/release_control
                        host.verbs += /mob/living/carbon/proc/punish_host
                        host.verbs += /mob/living/carbon/proc/spawn_larvae

/mob/living/simple_animal/borer/verb/secrete_chemicals()
        set category = "Borer"
        set name = "Secrete Chemicals"
        set desc = "Push some chemicals into your host's bloodstream."

        if(!host)
                src << "You are not inside a host body."
                return

        if(stat)
                src << "You cannot secrete chemicals in your current state."

        if(chemicals < 50)
                src << "You don't have enough chemicals!"

        var/chem = input("Select a chemical to secrete.", "Chemicals") in list("bicaridine","hyperzine")

        if(chemicals < 50 || !host || controlling || !src || stat) //Sanity check.
                return

        src << "\red <B>You squirt a measure of [chem] from your reservoirs into [host]'s bloodstream.</B>"
        host.reagents.add_reagent(chem, 15)
        chemicals -= 50

/mob/living/simple_animal/borer/verb/release_host()
        set category = "Borer"
        set name = "Release Host"
        set desc = "Slither out of your host."

        if(!host)
                src << "You are not inside a host body."
                return

        if(stat)
                src << "You cannot leave your host in your current state."


        if(!host || !src) return

        src << "You begin disconnecting from [host]'s synapses and prodding at their internal ear canal."

        if(!host.stat)
                host << "An odd, uncomfortable pressure begins to build inside your skull, behind your ear..."

        spawn(200)

                if(!host || !src) return

                if(src.stat)
                        src << "You cannot infest a target in your current state."
                        return

                src << "You wiggle out of [host]'s ear and plop to the ground."
                if(!host.stat)
                        host << "Something slimy wiggles out of your ear and plops to the ground!"

                detatch()

mob/living/simple_animal/borer/proc/detatch()

        if(!host) return

        if(istype(host,/mob/living/carbon/human))
                var/mob/living/carbon/human/H = host
                H.contents -= src

        src.loc = get_turf(host)
        controlling = 0

        reset_view(null)
        machine = null

        host.reset_view(null)
        host.machine = null

        host.verbs -= /mob/living/carbon/proc/release_control
        host.verbs -= /mob/living/carbon/proc/punish_host
        host.verbs -= /mob/living/carbon/proc/spawn_larvae

        if(host_brain.ckey)
                src.ckey = host.ckey
                host.ckey = host_brain.ckey
                host_brain.ckey = null
                host_brain.name = "host brain"
                host_brain.real_name = "host brain"

        host = null

/mob/living/simple_animal/borer/verb/infest()
        set category = "Borer"
        set name = "Infest"
        set desc = "Infest a suitable humanoid host."

        if(host)
                src << "You are already within a host."
                return

        if(stat)
                src << "You cannot infest a target in your current state."
                return

        var/list/choices = list()
        for(var/mob/living/carbon/C in view(1,src))
                if(C.stat != 2)
                        choices += C

        var/mob/living/carbon/M = input(src,"Who do you wish to infest?") in null|choices

        if(!M || !src) return

        if(M.has_brain_worms())
                src << "You cannot infest someone who is already infested!"
                return

        M << "Something slimy begins probing at the opening of your ear canal..."
        src << "You slither up [M] and begin probing at their ear canal..."

        if(!do_after(src,50))
                src << "As [M] moves away, you are dislodged and fall to the ground."
                return




        if(!M || !src) return

        if(src.stat)
                src << "You cannot infest a target in your current state."
                return

        if(M.stat == 2)
                src << "That is not an appropriate target."
                return


        if(M in view(1, src))
                src << "You wiggle into [M]'s ear."
                if(!M.stat)
                        M << "Something disgusting and slimy wiggles into your ear!"

                src.host = M
                src.loc = M

                if(istype(M,/mob/living/carbon/human))
                        var/mob/living/carbon/human/H = M
                        H.contents += src


                host_brain.name = M.name
                host_brain.real_name = M.real_name

                return
        else
                src << "They are no longer in range!"
                return

/mob/living/simple_animal/borer/verb/ventcrawl()
        set name = "Crawl through Vent"
        set desc = "Enter an air vent and crawl through the pipe system."
        set category = "Borer"

        var/obj/machinery/atmospherics/unary/vent_pump/vent_found
        var/welded = 0
        for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
                if(!v.welded)
                        vent_found = v
                        break
                else
                        welded = 1
        if(vent_found)
                if(vent_found.network&&vent_found.network.normal_members.len)
                        var/list/vents = list()
                        for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in vent_found.network.normal_members)
                                if(temp_vent.loc == loc)
                                        continue
                                vents.Add(temp_vent)
                        var/list/choices = list()
                        for(var/obj/machinery/atmospherics/unary/vent_pump/vent in vents)
                                if(vent.loc.z != loc.z)
                                        continue
                                var/atom/a = get_turf(vent)
                                choices.Add(a.loc)
                        var/turf/startloc = loc
                        var/obj/selection = input("Select a destination.", "Duct System") in choices
                        var/selection_position = choices.Find(selection)
                        if(loc==startloc)
                                var/obj/target_vent = vents[selection_position]
                                if(target_vent)
                                        loc = target_vent.loc
                        else
                                src << "\blue You need to remain still while entering a vent."
                else
                        src << "\blue This vent is not connected to anything."
        else if(welded)
                src << "\red That vent is welded."
        else
                src << "\blue You must be standing on or beside an air vent to enter it."
        return


/mob/living/simple_animal/borer/verb/hide()
        set name = "Hide"
        set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
        set category = "Borer"

        if (layer != TURF_LAYER+0.2)
                layer = TURF_LAYER+0.2
                src << text("\blue You are now hiding.")
        else
                layer = MOB_LAYER
                src << text("\blue You have stopped hiding.")

//Procs for grabbing players.
mob/living/simple_animal/borer/proc/request_player()
        for(var/mob/dead/observer/O in player_list)
                if(jobban_isbanned(O, "Syndicate"))
                        continue
                if(O.client)
                        if(O.client.prefs.be_special & BE_ALIEN)
                                question(O.client)

mob/living/simple_animal/borer/proc/question(var/client/C)
        spawn(0)
                if(!C)        return
                var/response = alert(C, "A cortex borer needs a player. Are you interested?", "Cortex borer request", "Yes", "No", "Never for this round")
                if(!C || ckey)
                        return
                if(response == "Yes")
                        transfer_personality(C)
                else if (response == "Never for this round")
                        C.prefs.be_special ^= BE_ALIEN

mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

        if(!candidate)
                return

        src.mind = candidate.mob.mind
        src.ckey = candidate.ckey
        if(src.mind)
                src.mind.assigned_role = "Cortex Borer"


//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

        set category = "Borer"
        set name = "Release Control"
        set desc = "Release control of your host's body."

        var/mob/living/simple_animal/borer/B = has_brain_worms()

        if(!B)
                return

        if(B.controlling)
                src << "\red <B>You withdraw your probosci, releasing control of [B.host_brain]</B>"
                B.host_brain << "\red <B>Your vision swims as the alien parasite releases control of your body.</B>"
                B.ckey = ckey
                B.controlling = 0
        if(B.host_brain.ckey)
                ckey = B.host_brain.ckey
                B.host_brain.ckey = null
                B.host_brain.name = "host brain"
                B.host_brain.real_name = "host brain"

        verbs -= /mob/living/carbon/proc/release_control
        verbs -= /mob/living/carbon/proc/punish_host
        verbs -= /mob/living/carbon/proc/spawn_larvae

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
        set category = "Borer"
        set name = "Torment host"
        set desc = "Punish your host with agony."

        var/mob/living/simple_animal/borer/B = has_brain_worms()

        if(!B)
                return

        if(B.host_brain.ckey)
                src << "\red <B>You send a punishing spike of psychic agony lancing into your host's brain.</B>"
                B.host_brain << "\red <B><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></B>"



//Check for brain worms in head.
/mob/proc/has_brain_worms() //Made this a mob proc so I can use it to stop it from OH GOD IT'S BREAKING EVERYTHING - RR

        for(var/I in contents)
                if(istype(I,/mob/living/simple_animal/borer))
                        return I

        return 0

/mob/living/carbon/proc/spawn_larvae()
        set category = "Borer"
        set name = "Reproduce"
        set desc = "Spawn several young."

        var/mob/living/simple_animal/borer/B = has_brain_worms()

        if(!B)
                return

        if(B.chemicals >= 100)
                src << "\red <B>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</B>"
                visible_message("\red <B>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</B>")
                B.chemicals -= 100

                new /obj/effect/decal/cleanable/vomit(get_turf(src))
                playsound(loc, 'sound/effects/splat.ogg', 50, 1)
                new /mob/living/simple_animal/borer(get_turf(src))

        else
                src << "You do not have enough chemicals stored to reproduce."
                return
