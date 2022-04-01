/// Opens up a USB port that can be connected to by circuits, creating registerable circuit components
/datum/component/usb_port
	/// The component types to create when something plugs in
	var/list/circuit_component_types

	/// The currently connected circuit
	var/obj/item/integrated_circuit/attached_circuit

	/// The currently connected USB cable
	var/datum/weakref/usb_cable_ref

	/// The components inside the parent
	var/list/obj/item/circuit_component/circuit_components

	/// The beam connecting the USB cable to the machine
	var/datum/beam/usb_cable_beam

	/// The current physical object that the beam is connected to and listens to.
	var/atom/movable/physical_object

/datum/component/usb_port/Initialize(list/circuit_component_types)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	circuit_components = list()

	set_circuit_components(circuit_component_types)

/datum/component/usb_port/proc/set_circuit_components(list/components)
	var/should_register = FALSE
	if(length(circuit_components))
		unregister_from_parent()
		should_register = TRUE
		QDEL_LIST(circuit_components)

	for(var/circuit_component in components)
		var/obj/item/circuit_component/component = circuit_component
		if(ispath(circuit_component))
			component = new circuit_component(null)
		register_signal(component, COMSIG_CIRCUIT_COMPONENT_SAVE, .proc/save_component)
		circuit_components += component

	if(should_register)
		register_with_parent()

/datum/component/usb_port/register_with_parent()
	register_signal(parent, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, .proc/on_atom_usb_cable_try_attach)
	register_signal(parent, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	register_signal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	register_signal(parent, COMSIG_MOVABLE_CIRCUIT_LOADED, .proc/on_load)

	for(var/obj/item/circuit_component/component as anything in circuit_components)
		component.register_usb_parent(parent)

/datum/component/usb_port/unregister_from_parent()
	unregister_signal(parent, list(
		COMSIG_ATOM_USB_CABLE_TRY_ATTACH,
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_EXAMINE,
		COMSIG_MOVABLE_CIRCUIT_LOADED,
	))

	for(var/obj/item/circuit_component/component as anything in circuit_components)
		component.unregister_usb_parent(parent)

	unregister_circuit_signals()
	unregister_physical_signals()
	attached_circuit = null

/datum/component/usb_port/proc/save_component(datum/source, list/objects)
	SIGNAL_HANDLER
	objects += parent

/datum/component/usb_port/proc/on_load(datum/source, obj/item/integrated_circuit/circuit, list/components)
	SIGNAL_HANDLER
	var/list/components_in_list = list()
	for(var/obj/item/circuit_component/component as anything in components)
		components_in_list += component.type

	for(var/obj/item/circuit_component/component as anything in circuit_components)
		if(component.type in components_in_list)
			continue
		components += component.type
	set_circuit_components(components)
	var/obj/item/usb_cable/cable = new(circuit.drop_location())
	cable.attached_circuit = circuit

	on_atom_usb_cable_try_attach(src, cable, null)

/datum/component/usb_port/Destroy()
	QDEL_LIST(circuit_components)
	QDEL_NULL(usb_cable_beam)

	attached_circuit = null
	usb_cable_ref = null

	return ..()

/datum/component/usb_port/proc/unregister_circuit_signals()
	if (isnull(attached_circuit))
		return

	unregister_signal(attached_circuit, list(
		COMSIG_CIRCUIT_SHELL_REMOVED,
		COMSIG_PARENT_QDELETING,
		COMSIG_CIRCUIT_SET_SHELL,
	))

/datum/component/usb_port/proc/unregister_physical_signals()
	if (isnull(physical_object))
		return

	unregister_signal(physical_object, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_EXAMINE,
	))

/datum/component/usb_port/proc/attach_circuit_components(obj/item/integrated_circuit/circuitboard)
	for(var/obj/item/circuit_component/component as anything in circuit_components)
		circuitboard.add_circuit_component(component)
		register_signal(component, COMSIG_CIRCUIT_COMPONENT_REMOVED, .proc/on_circuit_component_removed)

/datum/component/usb_port/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if (isnull(attached_circuit))
		examine_text += span_notice("There is a USB port on the front.")
	else
		examine_text += span_notice("[attached_circuit.shell || attached_circuit] is connected to [parent.p_them()] by a USB port.")

/datum/component/usb_port/proc/on_examine_shell(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("[source.p_they(TRUE)] [source.p_are()] attached to [parent] with a USB cable.")

/datum/component/usb_port/proc/on_atom_usb_cable_try_attach(datum/source, obj/item/usb_cable/connecting_cable, mob/user)
	SIGNAL_HANDLER

	var/atom/atom_parent = parent

	if (!isnull(attached_circuit))
		if(user)
			atom_parent.balloon_alert(user, "usb already connected")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (isnull(connecting_cable.attached_circuit))
		if(user)
			connecting_cable.balloon_alert(user, "connect to a shell first")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (!IN_GIVEN_RANGE(connecting_cable.attached_circuit, parent, USB_CABLE_MAX_RANGE))
		if(user)
			connecting_cable.balloon_alert(user, "too far away")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (connecting_cable.attached_circuit.locked)
		connecting_cable.balloon_alert(user, "shell is locked!")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	usb_cable_ref = WEAKREF(connecting_cable)
	attached_circuit = connecting_cable.attached_circuit

	connecting_cable.forceMove(attached_circuit)
	attach_circuit_components(attached_circuit)
	if(user)
		attached_circuit.interact(user)

	var/new_physical_object = attached_circuit.shell
	if(!new_physical_object)
		new_physical_object = attached_circuit

	register_signal(attached_circuit, COMSIG_CIRCUIT_SHELL_REMOVED, .proc/on_circuit_shell_removed)
	register_signal(attached_circuit, COMSIG_PARENT_QDELETING, .proc/on_circuit_deleting)
	register_signal(attached_circuit, COMSIG_CIRCUIT_SET_SHELL, .proc/on_set_shell)
	set_physical_object(new_physical_object)

	return COMSIG_USB_CABLE_ATTACHED

/datum/component/usb_port/proc/set_physical_object(atom/movable/new_physical_object)
	if(physical_object)
		unregister_physical_signals()
	if(usb_cable_beam)
		QDEL_NULL(usb_cable_beam)

	var/atom/atom_parent = parent
	usb_cable_beam = atom_parent.Beam(new_physical_object, "usb_cable_beam", 'icons/obj/wiremod.dmi')

	register_signal(new_physical_object, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	register_signal(new_physical_object, COMSIG_PARENT_EXAMINE, .proc/on_examine_shell)
	physical_object = new_physical_object

// Adds support for loading circuits without shells but with usb cables, or loading circuits with shells because the shells might not load first.
/datum/component/usb_port/proc/on_set_shell(datum/source, atom/movable/new_shell)
	SIGNAL_HANDLER
	set_physical_object(new_shell)

/datum/component/usb_port/proc/on_moved()
	SIGNAL_HANDLER

	if (isnull(attached_circuit))
		return

	if (IN_GIVEN_RANGE(attached_circuit, parent, USB_CABLE_MAX_RANGE))
		return

	detach()

/datum/component/usb_port/proc/on_circuit_deleting()
	SIGNAL_HANDLER
	detach()
	qdel(usb_cable_ref)

/datum/component/usb_port/proc/on_circuit_component_removed(datum/source)
	SIGNAL_HANDLER
	detach()

/datum/component/usb_port/proc/on_circuit_shell_removed()
	SIGNAL_HANDLER
	detach()

/datum/component/usb_port/proc/detach()
	var/obj/item/usb_cable/usb_cable = usb_cable_ref?.resolve()
	if (isnull(usb_cable))
		return

	for(var/obj/item/circuit_component/component as anything in circuit_components)
		unregister_signal(component, COMSIG_CIRCUIT_COMPONENT_REMOVED)
		attached_circuit.remove_component(component)
		component.moveToNullspace()

	unregister_circuit_signals()
	unregister_physical_signals()

	var/atom/atom_parent = parent
	usb_cable.forceMove(atom_parent.drop_location())
	usb_cable.balloon_alert_to_viewers("snap")

	physical_object = null
	attached_circuit = null
	usb_cable_ref = null

	QDEL_NULL(usb_cable_beam)
