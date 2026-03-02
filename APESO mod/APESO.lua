APESO = APESO or {}
--This File handles the initalization of the mod

--Initilize the mod
function APESO.Initialize()
    --create savedVariables to store location data for client to read
    APESO.savedVariables = ZO_SavedVars:NewAccountWide("APESOCheckedLocations",1,nil,APESO.Default)
    
    --register all events (found in Events.lua)
    APESOEvents.RegisterEvents()
    
    --Register all commands (found in Commands.lua)
    APESOCommands.CreateCommands()

    --process items
    APESO.ProcessItems()

    --Create UI Menus
    APESO.UI.StartUI()
end

--called when the addon is loaded
function APESO.OnAddOnLoaded(event, name)
    --initilize the mod
    APESO.Initialize()

    --unregister the event as the mod has now been created
    EVENT_MANAGER:UnregisterForEvent(APESO.name, EVENT_ADD_ON_LOADED)
end

--register event listener for when the addon is loaded
EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_ADD_ON_LOADED, APESO.OnAddOnLoaded, true)

--processes items in items.lua
function APESO.ProcessItems()
    -- loop through all items in items.lua
    for _, item in ipairs(APESO_ReceivedItems) do 

        --if gold increase item add to gold increase variable
        if item.item_id == APESO.GoldIncreaseID then
            APESO.GoldIncrease = APESO.GoldIncrease + 1

        --if within zone Access bounds then add to zone access table
        elseif item.item_id > APESO.RegionUnlockBaseID then
            local id = item.item_id - APESO.RegionUnlockBaseID
            APESO.ZoneAccess[id] = true

        --if progressive main quest then add to variable
        elseif item.item_id == APESO.MainQuestID then
            APESO.ProgressiveMainQuest = APESO.ProgressiveMainQuest + 1
        end
    end
end

            