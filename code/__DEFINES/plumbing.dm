#define FIRST_DUCT_LAYER 1
#define SECOND_DUCT_LAYER 2
#define THIRD_DUCT_LAYER 4
#define FOURTH_DUCT_LAYER 8
#define FIFTH_DUCT_LAYER 16

#define DUCT_LAYER_DEFAULT THIRD_DUCT_LAYER

#define MACHINE_REAGENT_TRANSFER 10 //the default max plumbing machinery transfers

GLOBAL_LIST_INIT(plumbing_layers, list(
	"First Layer" = FIRST_DUCT_LAYER,
	"Second Layer" = SECOND_DUCT_LAYER,
	"Default Layer" = THIRD_DUCT_LAYER,
	"Fourth Layer" = FOURTH_DUCT_LAYER,
	"Fifth Layer" = FIFTH_DUCT_LAYER,
))

GLOBAL_LIST_INIT(plumbing_layer_names, list(
	"[FIRST_DUCT_LAYER]" = "First Layer",
	"[SECOND_DUCT_LAYER]" = "Second Layer",
	"[THIRD_DUCT_LAYER]" = "Default Layer",
	"[FOURTH_DUCT_LAYER]" = "Fourth Layer",
	"[FIFTH_DUCT_LAYER]" = "Fifth Layer",
))

#define DUCT_COLOR_OMNI "omni"

GLOBAL_LIST_EMPTY(plumbing_color_menu_options)
GLOBAL_LIST_EMPTY(plumbing_layer_menu_options)
