# Archipelago Elder Scrolls Online
Get the latest version of APESO [here](https://github.com/spencer2585/APESO/releases/latest)
This mod requires the Archipelago software to generate and connect to the randomizer, find the latest version and setup instructions for Archipelago [here](https://github.com/ArchipelagoMW/Archipelago)

> [!Warning]
> This mod is currently in very early beta. as such there are bound to be many bugs or issues. If you want to wait until things are more stable then i recommend waiting a few months so that the worst bugs are fixed and new features can be added to improve the experiance. More details on the current state of the mod can be found in the Elder Scrolls Online thread in the Archipelago After Dark Server

## Whats Randomized
Right now there are settings to have completing zone quests, main story quests, and finding wayshrines as items and zone access and progressive main quest access as items. The goal is to complete the main quest and beat Molag bal. The Main Quest Items, Zone Access Items, and Main Quest Locations are not toggleable but you can turn off wayshrines and zone quests.

## Setup
1.) Add eso.apworld to you custom worlds in archipelago, this can be done by opening the file with the archipelago launcher or by adding it to the custom_worlds folder in your Archipelago Install

2.) Set up your yaml, the yaml can be found in the files in the latest release, by using Generate Template Options in the Archipelago launcher, or in the Options Creator also found in the Archipelago launcher. If you have chosen one of the first two options you must then open the yaml file in a text editor. The yaml contains all options for your game, options currently found in the yaml include
    -Name: what you want your slot in the randomizer to be named
    -Alliance: What allience you want you character to be a part of (Note: this does not force your character to be a part of that alliance during character creation, make sure your allience during character creation matches you yaml option or there will be issues)
    -zone_quest_enabled: if you want zone quests to be locations in the randomizer
    -Wayshrine-checks-enabled: if you want descovering wayshrines to be locations in the randomizer

> [!Warning]
> if you turn off both wayshrine and zone quest checks you will have more items than locations and Archipelago will fail to generate a game

3.) Generation: if you are generating the game then add you yaml to the players folder of your Archipelago install and run generate in the launcher, if someone else is generating the game you need to give them both eso.apworld and your yaml.

4.) If you generated the game: upload the zip created by generation to [Archipelago.gg](https://archipelago.gg/)

5.) Find your eso mods folder: If you are on windows this is located in Documents/Elder Scrolls Online/live/AddOns. extract the mod zip into the AddOns folder so that there is a folder called APESO in the AddOns folder, make sure that when you open the APESO folder there is a APESO.lua file along with the other mod files.

6.) Open ESO: you need to generate a APESO.lua file in live/savedVariables. Once the game is open make sure that the mod is enabled, this is done by going to the add-ons menu in the character select screen and ensureing there is a check in the box next to APESO. Next select a character and load into the game. Once this is done you can quit out of the game. If you wish you can check in live\SavedVariables to make sure there is an APESO.lua file inside. This only needs to be done once upon setup.

7.) Connect with the client: The client can be found in the Archipelago Launcher and is included in the APWorld you installed earlier, once the client is open connect with the port, this will eather be given to you by the host or if you are hosting it can be found on the page for the game.

8.)Create you character and play: Once the client is connected you can create a new character in eso and start playing. An Important note about how this randomizer works 
> [!IMPORTANT]
>due to how modding eso works **Items and Locations will not automatically sync**. if you have done a location or recived an item you must trigger a reloadUI event to send locations and recive items. This rarely happens during natural gameplay but can be manually trigger by running /reloadui in chat or by creating a hotkey in controls. If you create a hotkey it must manually be reconfigured for every character.

## FAQ

**I did not send/ recive an item**:
    Make sure you triggered a reload ui event. If your still having issues do it again, in rare cases reloadUI may need to be triggered twice. If this is the case or the issue still persists send a message in the thread in the Archipelago After Dark server and ping @Spencer2585 so that i can help troubleshoot and/or fix the issue for future releases

**I cannot find x quest in Alik'r Desert**:
    Zone quests in Alik'r Desert have a few bugs in base eso. specifically two quests in the zone questline have regular side quest symbols, these quests are _Gone Missing_ and and _Imperial Incursion_ The quest giver for these can be found near where the last quest in the chain ended. I recommend checking UESP for more details on where to go.
    If you cannot find _Risen From the Depths_ the quest giver can be found near the other set of docks from where you arrive in sentinal, once again i reccomend checking UESP for more details.

**I entered an area and now i have a message saying i do not have access to the area**:
    If you entered one of the major zones like Glenumbra or Auridon then make sure you have recived that zones access item from the randomizer. If you have and are still getting the warning then click the reloadUI button on the warning to trigger a reloadUI event and sync your items with the server.
    If that doesnt work or you entered another area then there is a code issue. ping @Spencer2585 in the Elder Scrolls Online thread in the Archipelago After Dark Server and tell me the name of the area you entered.