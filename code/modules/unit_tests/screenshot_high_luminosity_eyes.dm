#define UPDATE_EYES_LEFT 1
#define UPDATE_EYES_RIGHT 2

/// Tests to make sure no punks have broken high luminosity eyes
/datum/unit_test/screenshot_high_luminosity_eyes

/datum/unit_test/screenshot_high_luminosity_eyes/Run()
	// Create a mob with red and blue eyes. This is to test that high luminosity eyes properly default to the old eye color.
	var/mob/living/carbon/human/test_subject = allocate(/mob/living/carbon/human/consistent)
	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent)
	test_subject.eye_color_left = COLOR_RED
	test_subject.eye_color_right = COLOR_BLUE

	// Create our eyes, and insert them into the mob
	var/obj/item/organ/internal/eyes/robotic/glow/test_eyes = allocate(/obj/item/organ/internal/eyes/robotic/glow)
	test_eyes.Insert(test_subject)

	// This should be 4, but just in case it ever changes in the future
	var/default_light_range = test_eyes.eye.light_range

	// Test the normal light on appearance
	test_eyes.toggle_active()
	test_screenshot("light_on", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE))

	// Make sure the light overlay goes away (but not the emissive overlays) when we go to light range 0 while still turned on
	test_eyes.set_beam_color(COLOR_SCIENCE_PINK, to_update = UPDATE_EYES_LEFT)
	test_eyes.set_beam_color(COLOR_SLIME_GREEN, to_update = UPDATE_EYES_RIGHT)
	test_eyes.set_beam_range(0)
	test_screenshot("light_emissive", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE))

	// turn it on and off again, it should look the same afterwards
	test_eyes.toggle_active()
	test_eyes.toggle_active()
	test_screenshot("light_emissive", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE))

	// Make sure the light comes back on when we go from range 0 to 1
	// Change left/right eye color back to red/blue. It should matche the original screenshot
	test_eyes.set_beam_range(default_light_range)
	test_eyes.set_beam_color(COLOR_RED, to_update = UPDATE_EYES_LEFT)
	test_eyes.set_beam_color(COLOR_BLUE, to_update = UPDATE_EYES_RIGHT)
	test_screenshot("light_on", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE))

#undef UPDATE_EYES_LEFT
#undef UPDATE_EYES_RIGHT
