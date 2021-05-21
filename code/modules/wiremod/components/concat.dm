/**
 * # Arithmetic Component
 *
 * General arithmetic unit with add/sub/mult/divide capabilities
 * This one only works with numbers.
 */
/obj/item/circuit_component/concat
	display_name = "Concatenate"

	/// The amount of input ports to have
	var/input_port_amount = 4

	/// The result from the output
	var/datum/port/output/output

/obj/item/circuit_component/concat/Initialize()
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A")-1 + port_id)
		add_input_port(letter, PORT_TYPE_NUMBER)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/concat/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/concat/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	// If the current_option is equal to COMP_LOGIC_AND, start with result set to TRUE
	// Otherwise, set result to FALSE.
	var/result = ""

	for(var/datum/port/input/input_port as anything in input_ports)
		var/value = input_port.input_value
		if(isnull(value))
			continue

		result += value

	output.set_output(result)
