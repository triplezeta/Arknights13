import { Species } from "./base";

const Vampire: Species = {
  description: "A classy Vampire! They descend upon Space Station Thirteen \
    Every year to spook the crew! \"Bleeg!!\"",
  features: {
    good: [{
      icon: "bed",
      name: "Coffin Brooding",
      description: "Vampires can delay The Thirst and heal by resting in a \
        coffin. So THAT'S why they do that!",
    }, {
      icon: "skull",
      name: "Minor Undead",
      description: "Minor undead enjoy some of the perks of being dead, like \
        not needing to breathe or eat, but do not get many of the \
        environmental immunities involved with being fully undead.",
    }, {
      icon: "recycle",
      name: "Bat Form",
      description: "Vampires can become bats. Bats are very weak, but \
        are great for escaping bad situations. They can also travel through \
        vents, giving Vampires a lot of access. Just remember that access \
        doesn't equal permission, and people may be unhappy with you showing \
        up uninvited!",
    }],
    neutral: [],
    bad: [{
      icon: "tint",
      name: "The Thirst",
      description: "In place of eating, vampires suffer from The Thirst. \
      Thirst of what? Blood! Their tongue allows them to grab people and drink \
      their blood, and they will die if they run out. As a note, it doesn't \
      matter whose blood you drink, it will all be converted into your blood \
      type when consumed.",
    }],
  },
  lore: [
    "\"I'm not doing the bat trick. It's self deprecating. Okay, fine, but I'm not doing it again!\" - Count Baz, before venting into security for the third time this week.",
  ],
};

export default Vampire;
