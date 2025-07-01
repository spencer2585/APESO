APESO = {}

APESO.name = "APESO"
local libZone = LibZone
local zoneAccess
function APESO.Initialize()
    APESO.savedVariables = ZO_SavedVars:NewAccountWide("APESOSavedVars",1,nil,APESO.Default)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_FAST_TRAVEL_NETWORK_UPDATED, APESO.CheckWaystones)
end


function APESO.OnAddOnLoaded(event, addonName)
    if addonName == APESO.name then
        APESO.Initialize()
        zo_callLater(function () APESO.CheckZone() end, 500)
        zo_callLater(function () APESO.CheckWaystones() end, 500)

        EVENT_MANAGER:UnregisterForEvent(APESO.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_ADD_ON_LOADED, APESO.OnAddOnLoaded)

function APESO.CheckZone()
    zoneAccess = APESO.ZoneAccess
    local id = libZone:GetCurrentZoneIds()
    local charID = GetCurrentCharacterId()
    --Get Player Information so that if zone is not unlocked can sent do correct wayshrine
    local name,gender,level,class,alliance = GetCharacterInfo(0)
    local i = 1
    while (name ~= GetRawUnitName("player"))
    do
        name,gender,level,class,alliance = GetCharacterInfo(i)
        i=i+1
    end
    --check if zone is unlocked
    if zoneAccess[id] then
    else
        d("|cf10d00Error, your current zone has not been unlocked yet. Checks will not send, If it has been unlocked run /reloadui in chat|r")
        --daggerfall covenent
        if alliance == 1 then
            FastTravelToNode(62)
            --ebonheart pact
        elseif alliance == 5 then
            FastTravelToNode(65)
            --aldmeri Dominion
        else
            FastTravelToNode(177)
        end
    end
end

function APESO.CheckWaystones()
    local numNodes = GetNumFastTravelNodes()
    local nodeInfo = {}
    for i=1, numNodes do
        nodeInfo[i]=HasCompletedFastTravelNodePOI(i)
        APESO.savedVariables.NodeInfo = nodeInfo
    end
end