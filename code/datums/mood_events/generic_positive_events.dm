/datum/mood_event/hug
	description = "<span class='nicegreen'>Hugs are nice.</span>"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/betterhug
	description = "<span class='nicegreen'>Someone was very nice to me.</span>"
	mood_change = 3
	timeout = 4 MINUTES

/datum/mood_event/betterhug/add_effects(mob/friend)
	description = "<span class='nicegreen'>[friend.name] was very nice to me.</span>"

/datum/mood_event/besthug
	description = "<span class='nicegreen'>Someone is great to be around, they make me feel so happy!</span>"
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/besthug/add_effects(mob/friend)
	description = "<span class='nicegreen'>[friend.name] is great to be around, [friend.p_they()] makes me feel so happy!</span>"

/datum/mood_event/warmhug
	description = "<span class='nicegreen'>Warm cozy hugs are the best!</span>"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/tailpulled
	description = "<span class='nicegreen'>I love getting my tail pulled!</span>"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/arcade
	description = "<span class='nicegreen'>I beat the arcade game!</span>"
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/blessing
	description = "<span class='nicegreen'>I've been blessed.</span>"
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/maintenance_adaptation
	mood_change = 8

/datum/mood_event/maintenance_adaptation/add_effects()
	description = "<span class='nicegreen'>[GLOB.deity] has helped me adapt to the maintenance shafts!</span>"

/datum/mood_event/book_nerd
	description = "<span class='nicegreen'>I have recently read a book.</span>"
	mood_change = 1
	timeout = 5 MINUTES

/datum/mood_event/exercise
	description = "<span class='nicegreen'>Working out releases those endorphins!</span>"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/pet_animal
	description = "<span class='nicegreen'>Animals are adorable! I can't stop petting them!</span>"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/pet_animal/add_effects(mob/animal)
	description = "<span class='nicegreen'>\The [animal.name] is adorable! I can't stop petting [animal.p_them()]!</span>"

/datum/mood_event/honk
	description = "<span class='nicegreen'>I've been honked!</span>"
	mood_change = 2
	timeout = 4 MINUTES
	special_screen_obj = "honked_nose"
	special_screen_replace = FALSE

/datum/mood_event/saved_life
	description = "<span class='nicegreen'>It feels good to save a life.</span>"
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/oblivious
	description = "<span class='nicegreen'>What a lovely day.</span>"
	mood_change = 3

/datum/mood_event/jolly
	description = "<span class='nicegreen'>I feel happy for no particular reason.</span>"
	mood_change = 6
	timeout = 2 MINUTES

/datum/mood_event/focused
	description = "<span class='nicegreen'>I have a goal, and I will reach it, whatever it takes!</span>" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 4
	hidden = TRUE

/datum/mood_event/badass_antag
	description = "<span class='greentext'>I'm a fucking badass and everyone around me knows it. Just look at them; they're all fucking shaking at the mere thought of having me around.</span>"
	mood_change = 7
	hidden = TRUE
	special_screen_obj = "badass_sun"
	special_screen_replace = FALSE

/datum/mood_event/creeping
	description = "<span class='greentext'>The voices have released their hooks on my mind! I feel free again!</span>" //creeps get it when they are around their obsession
	mood_change = 18
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/revolution
	description = "<span class='nicegreen'>VIVA LA REVOLUTION!</span>"
	mood_change = 3
	hidden = TRUE

/datum/mood_event/cult
	description = "<span class='nicegreen'>I have seen the truth, praise the almighty one!</span>"
	mood_change = 10 //maybe being a cultist isn't that bad after all
	hidden = TRUE

/datum/mood_event/heretics
	description = "<span class='nicegreen'>THE HIGHER I RISE, THE MORE I SEE.</span>"
	mood_change = 10 //maybe being a cultist isnt that bad after all
	hidden = TRUE

/datum/mood_event/family_heirloom
	description = "<span class='nicegreen'>My family heirloom is safe with me.</span>"
	mood_change = 1

/datum/mood_event/clown_enjoyer_pin
	description = "<span class='nicegreen'>I love showing off my clown pin!</span>"
	mood_change = 1

/datum/mood_event/mime_fan_pin
	description = "<span class='nicegreen'>I love showing off my mime pin!</span>"
	mood_change = 1

/datum/mood_event/goodmusic
	description = "<span class='nicegreen'>There is something soothing about this music.</span>"
	mood_change = 3
	timeout = 60 SECONDS

/datum/mood_event/chemical_euphoria
	description = "<span class='nicegreen'>Heh...hehehe...hehe...</span>"
	mood_change = 4

/datum/mood_event/chemical_laughter
	description = "<span class='nicegreen'>Laughter really is the best medicine! Or is it?</span>"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/chemical_superlaughter
	description = "<span class='nicegreen'>*WHEEZE*</span>"
	mood_change = 12
	timeout = 3 MINUTES

/datum/mood_event/religiously_comforted
	description = "<span class='nicegreen'>I feel comforted by the presence of a holy person.</span>"
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/clownshoes
	description = "<span class='nicegreen'>The shoes are a clown's legacy, I never want to take them off!</span>"
	mood_change = 5

/datum/mood_event/sacrifice_good
	description = "<span class='nicegreen'>The gods are pleased with this offering!</span>"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/artok
	description = "<span class='nicegreen'>It's nice to see people are making art around here.</span>"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/artgood
	description = "<span class='nicegreen'>What a thought-provoking piece of art. I'll remember that for a while.</span>"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/artgreat
	description = "<span class='nicegreen'>That work of art was so great it made me believe in the goodness of humanity. Says a lot in a place like this.</span>"
	mood_change = 6
	timeout = 5 MINUTES

/datum/mood_event/pet_borg
	description = "<span class='nicegreen'>I just love my robotic friends!</span>"
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/bottle_flip
	description = "<span class='nicegreen'>The bottle landing like that was satisfying.</span>"
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/hope_lavaland
	description = "<span class='nicegreen'>What a peculiar emblem.  It makes me feel hopeful for my future.</span>"
	mood_change = 10

/datum/mood_event/confident_mane
	description = "<span class='nicegreen'>I'm feeling confident with a head full of hair.</span>"
	mood_change = 2

/datum/mood_event/holy_consumption
	description = "<span class='nicegreen'>Truly, that was the food of the Divine!</span>"
	mood_change = 1 // 1 + 5 from it being liked food makes it as good as jolly
	timeout = 3 MINUTES

/datum/mood_event/high_five
	description = "<span class='nicegreen'>I love getting high fives!</span>"
	mood_change = 2
	timeout = 45 SECONDS

/datum/mood_event/high_ten
	description = "<span class='nicegreen'>AMAZING! A HIGH-TEN!</span>"
	mood_change = 3
	timeout = 45 SECONDS

/datum/mood_event/down_low
	description = "<span class='nicegreen'>HA! What a rube, they never stood a chance...</span>"
	mood_change = 4
	timeout = 90 SECONDS

/datum/mood_event/aquarium_positive
	description = "<span class='nicegreen'>Watching fish in an aquarium is calming.</span>"
	mood_change = 3
	timeout = 90 SECONDS

/datum/mood_event/gondola
	description = "<span class='nicegreen'>I feel at peace and feel no need to make any sudden or rash actions.</span>"
	mood_change = 6

/datum/mood_event/kiss
	description = "<span class='nicegreen'>Someone blew a kiss at me, I must be a real catch!</span>"
	mood_change = 1.5
	timeout = 2 MINUTES

/datum/mood_event/kiss/add_effects(mob/beau, direct)
	if(!beau)
		return
	if(direct)
		description = "<span class='nicegreen'>[beau.name] gave me a kiss, ahh!!</span>"
	else
		description = "<span class='nicegreen'>[beau.name] blew a kiss at me, I must be a real catch!</span>"

/datum/mood_event/honorbound
	description = "<span class='nicegreen'>Following my honorbound code is fulfilling!</span>"
	mood_change = 4

/datum/mood_event/et_pieces
	description = "<span class='abductor'>Mmm... I love peanut butter...</span>"
	mood_change = 50
	timeout = 10 MINUTES

/datum/mood_event/memories_of_home
	description = "<span class='nicegreen'>This taste seems oddly nostalgic...</span>"
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/observed_soda_spill
	description = span_nicegreen("Ahaha! It's always funny to see someone get sprayed by a can of soda.")
	mood_change = 2
	timeout = 30 SECONDS

/datum/mood_event/observed_soda_spill/add_effects(mob/spilled_mob, atom/soda_can)
	if(!spilled_mob)
		return

	description = span_nicegreen("Ahaha! [spilled_mob] spilled [spilled_mob.p_their()] [soda_can ? soda_can.name : "soda"] all over [spilled_mob.p_them()]self! Classic.")

/datum/mood_event/gaming
	description = span_nicegreen("I'm enjoying a nice gaming session!")
	mood_change = 2
	timeout = 30 SECONDS

/datum/mood_event/gamer_won
	description = span_nicegreen("I love winning videogames!")
	mood_change = 10
	timeout = 5 MINUTES

