/**
 * # Species Component
 *
 * Return the species of a mob
 */
/obj/item/circuit_component/species
	display_name = "Species"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

/obj/item/circuit_component/species/Initialize()
	. = ..()
	input_port = add_input_port("Organism", PORT_TYPE_ATOM)

	output = add_output_port("Species", PORT_TYPE_STRING)

/obj/item/circuit_component/species/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/circuit_component/species/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/H = input_port.input_value
	if(!istype(H) || !H.has_dna())
		output.set_output(null)
		return

	output.set_output(H.dna.species.name)
