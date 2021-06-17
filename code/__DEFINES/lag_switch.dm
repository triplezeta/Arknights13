// All of the possible Lag Switch lag mitigation measures
// If you add more do not forget to update MEASURES_AMOUNT accordingly
#define DISABLE_DEAD_KEYLOOP 1 // Stops ghosts flying around freely, they can still jump and orbit, staff exempted
#define DISABLE_GHOST_ZOOM_TRAY 2 // Stops ghosts using zoom/t-ray verbs and resets their view if zoomed out, staff exempted
#define DISABLE_RUNECHAT 3 // Disable runechat and enable the bubbles, speaking mobs with TRAIT_BYPASS_MEASURES exempted
#define DISABLE_USR_ICON2HTML 4 // Disable icon2html procs from verbs like examine, mobs calling with TRAIT_BYPASS_MEASURES exempted
#define DISABLE_SCREENTIPS 5 // Disable /atom/MouseEntered screentips, mobs calling with TRAIT_BYPASS_MEASURES exempted
#define DISABLE_ITEM_TOOLTIPS 6 // Disable /obj/item/MouseEntered tooltips, mobs calling with TRAIT_BYPASS_MEASURES exempted
#define DISABLE_NON_OBSJOBS 7 // Prevents anyone from joining the game as anything but observer

#define MEASURES_AMOUNT 7 // The total number of switches defined above
