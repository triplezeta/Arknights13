/**
 * # Temperature Sensor
 *
 * Returns the temperature of the tile
 */
/obj/item/circuit_component/tempsensor
	display_name = "Temperature Sensor"
	display_desc = "Outputs the current temperature of the tile"

	/// Trigger a measurement
	var/datum/port/input/trigger

	/// The result from the output
	var/datum/port/output/result

/obj/item/circuit_component/tempsensor/Initialize()
	. = ..()
	trigger = add_input_port("Trigger", PORT_TYPE_SIGNAL)
	result = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/circuit_component/tempsensor/Destroy()
	trigger = null
	result = null
	return ..()

/obj/item/circuit_component/tempsensor/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!COMPONENT_TRIGGERED_BY(trigger, port))
		return
	var/turf/location = parent.shell.loc
	if(!location)
		location=parent.loc
	if(!location)
		location=loc
	var/datum/gas_mixture/environment = location.return_air()
	var/total_moles = environment.total_moles()
	if(total_moles)
		//environment.assert_gases(arglist(GLOB.hardcoded_gases))
		result.set_output(round(environment.temperature,1))
