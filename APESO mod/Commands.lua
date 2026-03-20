APESOCommands = APESOCommands or {}
--This file contains all functions related to creating custom commands for the mod

--create commands
function APESOCommands.CreateCommands()
    --toggle debug mode
    SLASH_COMMANDS["/toggledebugmode"] = function() APESOCommands.ToggleDebugMode() end
    SLASH_COMMANDS["/checkzoneaccess"] = function(arg) d(APESOHelpers.CheckZoneAccess(tonumber(arg))) end
    SLASH_COMMANDS["/getcurrzoneid"] = function() d(GetZoneId(GetUnitZoneIndex("player"))) end 
    SLASH_COMMANDS["/getprogressivemainquests"] = function() APESOCommands.GetProgressiveMainQuests() end
    SLASH_COMMANDS["/getcurrentgold"] = function() d(APESOHelpers.GetCurrentGold()) end
    SLASH_COMMANDS["/getgoldcap"] = function() d(APESOHelpers.GetGoldCap()) end
    SLASH_COMMANDS["/isovergoldcap"] = function() d(APESOHelpers.IsOverGoldCap()) end
end

--toggle debug mode
function APESOCommands.ToggleDebugMode()
    --if debug mode is on then turn off
    if APESO.DebugMode == true then
        APESO.DebugMode = false
        d("debug mode disabled")
    --else turn debug mode on
    else
        APESO.DebugMode = true
        d("debug mode enabled")
    end
end

function APESOCommands.GetProgressiveMainQuests()
    d("You have ".. APESO.ProgressiveMainQuest .. " progressive main quests.")
    d("You can complete up to ".. APESO_MainQuests[APESO.ProgressiveMainQuest].name..".")
end