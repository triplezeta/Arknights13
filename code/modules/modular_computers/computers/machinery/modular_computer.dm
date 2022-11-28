// Modular Computer - device that runs various programs and operates with hardware
// DO NOT SPAWN THIS TYPE. Use /laptop/ or /console/ instead.
/obj/machinery/modular_computer
	name = "modular computer"
	desc = "You shouldn't see this. If you do, report it." //they should be examining the processor instead

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.
	icon = 'icons/obj/modular_console.dmi'
	icon_state = null

	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	///The power cell, null by default as we use the APC we're in
	var/internal_cell = null
	///A flag that describes this device type
	var/hardware_flag = NONE
	///Power usage during last tick
	var/last_power_usage = 0
	/// Amount of programs that can be ran at once
	var/max_idle_programs = 4


	///Icon state when the computer is turned off.
	var/icon_state_unpowered = null
	///Icon state when the computer is turned on.
	var/icon_state_powered = null
	///Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/screen_icon_state_menu = "menu"
	///Icon state overlay when the computer is powered, but not 'switched on'.
	var/screen_icon_screensaver = "standby"
	///Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/steel_sheet_cost = 10
	///Light luminosity when turned on
	var/light_strength = 0
	///Power usage when the computer is open (screen is active) and can be interacted with.
	var/base_active_power_usage = 100
	///Power usage when the computer is idle and screen is off (currently only applies to laptops)
	var/base_idle_power_usage = 10
	/// Allow people with chunky fingers to use?
	var/allow_chunky = FALSE

	///CPU that handles most logic while this type only handles power and other specific things.
	var/datum/modular_computer_host/console/cpu

/obj/machinery/modular_computer/Initialize(mapload)
	. = ..()
	cpu = new(src)

/obj/machinery/modular_computer/Destroy()
	QDEL_NULL(cpu)
	return ..()

/obj/machinery/modular_computer/update_appearance(updates)
	. = ..()
	set_light(cpu?.powered_on ? light_strength : 0)

/obj/machinery/modular_computer/update_icon_state()
	if(!cpu || !cpu.powered_on || !cpu.use_power() || (machine_stat & NOPOWER))
		icon_state = icon_state_unpowered
	else
		icon_state = icon_state_powered
	return ..()

/obj/machinery/modular_computer/update_overlays()
	. = ..()
	if(!cpu)
		return .

	if(cpu.powered_on && cpu.use_power())
		. += cpu.active_program?.program_icon_state || screen_icon_state_menu
	else if(!(machine_stat & NOPOWER))
		. += screen_icon_screensaver

	if(get_integrity() <= integrity_failure * max_integrity)
		. += "bsod"
		. += "broken"
	return .

/// Eats the "source" arg because update_icon actually expects args now.
/obj/machinery/modular_computer/proc/relay_icon_update(datum/source, updates, updated)
	SIGNAL_HANDLER
	return update_icon(updates)

// Modular computers can have battery in them, we handle power in previous proc, so prevent this from messing it up for us.
/obj/machinery/modular_computer/power_change()
	if(cpu?.use_power()) // If it still has a power source, PC wouldn't go offline.
		set_machine_stat(machine_stat & ~NOPOWER)
		update_appearance()
		return
	return ..()

/obj/machinery/modular_computer/screwdriver_act(mob/user, obj/item/tool)
	if(cpu)
		return cpu.screwdriver_act(user, tool)
	return ..()

/obj/machinery/modular_computer/wrench_act(mob/user, obj/item/tool)
	if(cpu)
		return cpu.wrench_act(user, tool)
	return ..()

/obj/machinery/modular_computer/welder_act(mob/user, obj/item/tool)
	if(cpu)
		return cpu.welder_act(user, tool)
	return ..()

/obj/machinery/modular_computer/attackby(obj/item/W as obj, mob/living/user)
	if (cpu && !user.combat_mode && !(flags_1 & NODECONSTRUCT_1))
		return cpu.attackby(W, user)
	return ..()

// Stronger explosions cause serious damage to internal components
// Minor explosions are mostly mitigitated by casing.
/obj/machinery/modular_computer/ex_act(severity)
	if(!cpu)
		return ..()

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += cpu
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += cpu
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += cpu
	return ..()

// "Stun" weapons can cause minor damage to components (short-circuits?)
// "Burn" damage is equally strong against internal components and exterior casing
// "Brute" damage mostly damages the casing.
/obj/machinery/modular_computer/bullet_act(obj/projectile/Proj)
	if(cpu)
		return cpu.bullet_act(Proj)
	return ..()
