## HippieStation 13 [![Build Status](https://jenkins.hippiestation.com/buildStatus/icon?job=HippieStation)](https://jenkins.hippiestation.com/job/HippieStation/) [![Krihelimeter](http://www.krihelinator.xyz/badge/HippieStation/HippieStation)](http://www.krihelinator.xyz/repositories/HippieStation/HippieStation) [![GitHub forks](https://img.shields.io/github/forks/HippieStation/HippieStation.svg?style=social&label=Fork)](https://github.com/HippieStation/HippieStation#fork-destination-box)

**Website:** http://www.hippiestation.com <BR>
**Code:** https://github.com/hippiestation/hippiestation <BR>
**Wiki** https://wiki.hippiestation.com/index.php?title=Main_Page <BR>
**Discord:** [Request access here.](https://hippiestation.com/threads/discord-invites.6055) <BR>

## ABOUT

This is the Github page for the HippieStation codebase, used on the Space Station 13 server. This codebase is built off the work of many different servers, primarily that of /tg/station 13.
Because of this, the repository inherits /tg/station's licensing, among other things.
For a full guide on how to set up your own Space Station 13 server, please see the [/tg/station README.md](https://github.com/tgstation/tgstation/blob/master/README.md).
If you would like to contribute to this codebase, first take a look at the [CONTRIBUTING.md](.github/CONTRIBUTING.md).

## DOWNLOADING

There are a number of ways to download the source code. Some are described here, an alternative all-inclusive guide is also located at https://wiki.hippiestation.com/index.php?title=Downloading_the_source_code

Option 1:
Follow this: https://wiki.hippiestation.com/index.php?title=Setting_up_git

Option 2: Download the source code as a zip by clicking the ZIP button in the
code tab of https://github.com/hippiestation/hippiestation
(note: this will use a lot of bandwidth if you wish to update and is a lot of
hassle if you want to make any changes at all, so it's not recommended.)

## INSTALLATION

First-time installation should be fairly straightforward.  First, you'll need
BYOND installed.  You can get it from http://www.byond.com/.  Once you've done
that, extract the game files to wherever you want to keep them.  This is a
sourcecode-only release, so the next step is to compile the server files.
Open tgstation.dme by double-clicking it, open the Build menu, and click
compile.  This'll take a little while, and if everything's done right you'll get
a message like this:

```
saving hippiestation.dmb (DEBUG mode)
tgstation.dmb - 0 errors, 0 warnings
```

If you see any errors or warnings, something has gone wrong - possibly a corrupt
download or the files extracted wrong. If problems persist, ask for assistance
in irc://irc.rizon.net/coderbus

Once that's done, open up the config folder.  You'll want to edit config.txt to
set the probabilities for different gamemodes in Secret and to set your server
location so that all your players don't get disconnected at the end of each
round.  It's recommended you don't turn on the gamemodes with probability 0,
except Extended, as they have various issues and aren't currently being tested,
so they may have unknown and bizarre bugs.  Extended is essentially no mode, and
isn't in the Secret rotation by default as it's just not very fun.

You'll also want to edit config/admins.txt to remove the default admins and add
your own.  "Game Master" is the highest level of access, and probably the one
you'll want to use for now.  You can set up your own ranks and find out more in
config/admin_ranks.txt

The format is

```
byondkey = Rank
```

where the admin rank must be properly capitalised.

Finally, to start the server, run Dream Daemon and enter the path to your
compiled tgstation.dmb file.  Make sure to set the port to the one you
specified in the config.txt, and set the Security box to 'Safe'.  Then press GO
and the server should start up and be ready to join. It is also recommended that
you set up the SQL backend (see below).

## UPDATING

To update an existing installation, first back up your /config and /data folders
as these store your server configuration, player preferences and banlist.

Then, extract the new files (preferably into a clean directory, but updating in
place should work fine), copy your /config and /data folders back into the new
install, overwriting when prompted except if we've specified otherwise, and
recompile the game.  Once you start the server up again, you should be running
the new version.

## MAPS
Hippie Station currently comes equipped with six maps.

* [Hippie BoxStation (default)](http://tgstation13.org/wiki/Boxstation)
* [BoxStation (default)](http://tgstation13.org/wiki/Boxstation)
* [MetaStation](https://tgstation13.org/wiki/MetaStation)
* [DeltaStation](https://tgstation13.org/wiki/DeltaStation)
* [OmegaStation](https://tgstation13.org/wiki/OmegaStation)
* [PubbyStation](https://tgstation13.org/wiki/PubbyStation)


All maps have their own code file that is in the base of the _maps directory. Maps are loaded dynamically when the game starts. Follow this guideline when adding your own map, to your fork, for easy compatibility.

The map that will be loaded for the upcoming round is determined by reading data/next_map.json, which is a copy of the json files found in the _maps tree. If this file does not exist, the default map from config/maps.txt will be loaded. Failing that, tgstation2 will be loaded. If you want to set a specific map to load next round you can use the Change Map verb in game before restarting the server or copy a json from _maps to data/next_map.json before starting the server. Also, for debugging purposes, ticking a corresponding map's code file in Dream Maker will force that map to load every round.

If you are hosting a server, and want randomly picked maps to be played each round, you can enable map rotation in [config.txt](config/config.txt) and then set the maps to be picked in the [maps.txt](config/maps.txt) file.

Anytime you want to make changes to a map it's imperative you use the [Map Merging tools](http://tgstation13.org/wiki/Map_Merger)

## AWAY MISSIONS

/tg/station supports loading away missions however they are disabled by default.

Map files for away missions are located in the _maps/RandomZLevels directory. Each away mission includes it's own code definitions located in /code/modules/awaymissions/mission_code. These files must be included and compiled with the server beforehand otherwise the server will crash upon trying to load away missions that lack their code.

To enable an away mission open `config/awaymissionconfig.txt` and uncomment one of the .dmm lines by removing the #. If more than one away mission is uncommented then the away mission loader will randomly select one the enabled ones to load.

## SQL SETUP

The SQL backend requires a MySQL server. SQL is required for the library, stats tracking, admin notes, and job-only bans, among other features, mostly related to server administration. Your server details go in /config/dbconfig.txt, and the SQL schema is in /SQL/tgstation_schema.sql and /SQL/tgstation_schema_prefix.sql depending on if you want table prefixes.  More detailed setup instructions are located here: http://www.tgstation13.org/wiki/Downloading_the_source_code#Setting_up_the_database

## IRC BOT SETUP

Included in the repository is a python3 compatible IRC bot capable of relaying adminhelps to a specified
IRC channel/server, see the /tools/minibot folder for more

## CONTRIBUTING

Please see [CONTRIBUTING.md](.github/CONTRIBUTING.md)

## LICENSE

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](http://www.gnu.org/licenses/agpl-3.0.html).

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE-AGPLv3.txt and LICENSE-GPLv3.txt for more details.

tgui clientside is licensed as a subproject under the MIT license.
Font Awesome font files, used by tgui, are licensed under the SIL Open Font License v1.1
tgui assets are licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

See tgui/LICENSE.md for the MIT license.
See tgui/assets/fonts/SIL-OFL-1.1-LICENSE.md for the SIL Open Font License.

All assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](http://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated..
