
// This is literally the worst possible cheap tablet
/obj/item/modular_computer/tablet/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."

/obj/item/modular_computer/tablet/preset/cheap/New()
	. = ..()
	install_component(new /obj/item/weapon/computer_hardware/processor_unit/small)
	install_component(new /obj/item/weapon/computer_hardware/battery(src, /obj/item/weapon/stock_parts/cell/computer/micro))
	install_component(new /obj/item/weapon/computer_hardware/hard_drive/small)
	install_component(new /obj/item/weapon/computer_hardware/network_card)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/preset/advanced/New()
	. = ..()
	install_component(new /obj/item/weapon/computer_hardware/processor_unit/small)
	install_component(new /obj/item/weapon/computer_hardware/battery(src, /obj/item/weapon/stock_parts/cell/computer))
	install_component(new /obj/item/weapon/computer_hardware/hard_drive/small)
	install_component(new /obj/item/weapon/computer_hardware/network_card)
	install_component(new /obj/item/weapon/computer_hardware/card_slot)
	install_component(new /obj/item/weapon/computer_hardware/printer/mini)
