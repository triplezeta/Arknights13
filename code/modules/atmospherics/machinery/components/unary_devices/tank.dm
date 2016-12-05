#define AIR_CONTENTS	(25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
/obj/machinery/atmospherics/components/unary/tank
	icon = 'icons/obj/atmospherics/pipes/pressure_tank.dmi'
	icon_state = "generic"
	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."
	obj_integrity = 800
	max_integrity = 800
	var/volume = 10000 //in liters, 1 meters by 1 meters by 2 meters
	density = 1
	var/gas_type = GAS_INVALID

/obj/machinery/atmospherics/components/unary/tank/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = volume
	air_contents.temperature = T20C
	if(gas_type)
		air_contents.assert_gas(gas_type)
		air_contents.gases[gas_type][MOLES] = AIR_CONTENTS
		name = "[name] ([air_contents.gases[gas_type][GAS_META][META_GAS_NAME]])"

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	gas_type = "co2"

/obj/machinery/atmospherics/components/unary/tank/toxins
	icon_state = "orange"
	gas_type = "plasma"

/obj/machinery/atmospherics/components/unary/tank/oxygen_agent_b
	icon_state = "orange_2"
	gas_type = "agent_b"

/obj/machinery/atmospherics/components/unary/tank/oxygen
	icon_state = "blue"
	gas_type = GAS_O2

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	icon_state = "red"
	gas_type = GAS_N2

/obj/machinery/atmospherics/components/unary/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/unary/tank/air/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.assert_gases(GAS_O2, GAS_N2)
	air_contents.gases[GAS_O2][MOLES] = AIR_CONTENTS * 0.2
	air_contents.gases[GAS_N2][MOLES] = AIR_CONTENTS * 0.8
