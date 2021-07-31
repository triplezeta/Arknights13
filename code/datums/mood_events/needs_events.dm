//nutrition
/datum/mood_event/fat
	description = "<B>I'm so fat...</B></span>\n" //muh fatshaming
	mood_change = -6

/datum/mood_event/wellfed
	description = "I'm stuffed!</span>\n"
	mood_change = 8

/datum/mood_event/fed
	description = "I have recently had some food.</span>\n"
	mood_change = 5

/datum/mood_event/hungry
	description = "I'm getting a bit hungry.</span>\n"
	mood_change = -6

/datum/mood_event/starving
	description = "I'm starving!</span>\n"
	mood_change = -10

//charge
/datum/mood_event/supercharged
	description = "I can't possibly keep all this power inside, I need to release some quick!</span>\n"
	mood_change = -10

/datum/mood_event/overcharged
	description = "I feel dangerously overcharged, perhaps I should release some power.</span>\n"
	mood_change = -4

/datum/mood_event/charged
	description = "I feel the power in my veins!</span>\n"
	mood_change = 6

/datum/mood_event/lowpower
	description = "My power is running low, I should go charge up somewhere.</span>\n"
	mood_change = -6

/datum/mood_event/decharged
	description = "I'm in desperate need of some electricity!</span>\n"
	mood_change = -10

//Disgust
/datum/mood_event/gross
	description = "I saw something gross.</span>\n"
	mood_change = -4

/datum/mood_event/verygross
	description = "I think I'm going to puke...</span>\n"
	mood_change = -6

/datum/mood_event/disgusted
	description = "Oh god, that's disgusting...</span>\n"
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "I can smell something horribly decayed inside this room.</span>\n"
	mood_change = -6

/datum/mood_event/disgust/nauseating_stench
	description = "The stench of rotting carcasses is unbearable!</span>\n"
	mood_change = -12

//Generic needs events
/datum/mood_event/favorite_food
	description = "I really enjoyed eating that.</span>\n"
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/gross_food
	description = "I really didn't like that food.</span>\n"
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/disgusting_food
	description = "That food was disgusting!</span>\n"
	mood_change = -6
	timeout = 4 MINUTES

/datum/mood_event/breakfast
	description = "Nothing like a hearty breakfast to start the shift.</span>\n"
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/nice_shower
	description = "I have recently had a nice shower.</span>\n"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/fresh_laundry
	description = "There's nothing like the feeling of a freshly laundered jumpsuit.</span>\n"
	mood_change = 2
	timeout = 10 MINUTES
