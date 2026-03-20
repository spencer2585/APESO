APESO = APESO or {}

APESO.Debug = true

local NPCLocks = APESO_NPCLocks or {}
local QuestEquivalences = APESO_QuestEquivalences or {}
local APESO_ACTION_LAYER = "APESO_ZoneLock"

APESO.BlockedActions = {
    MOVE_FORWARD = true,
    MOVE_BACKWARD = true,
    MOVE_LEFT = true,
    MOVE_RIGHT = true,
    JUMP = true,
    SPRINT = true,
    ROLL_DODGE = true,
    TOGGLE_CROUCH = true,
    TOGGLE_MOUNT = true,
    INTERACT = true,
}

APESO.NPCLocks = NPCLocks
APESO.QuestEquivalences = QuestEquivalences

-- Zone warning UI state
APESO.WarningWindow = nil
APESO.SuppressUntil = 0
APESO.SuppressDuration = 5 -- seconds

APESO.lastNpcName = nil
APESO.lastCompassName = nil

local MAIN_QUEST_STEPS = {
    [4831] = 1,
    [4474] = 2,
    [4552] = 3,
    [4607] = 4,
    [4764] = 5,
    [4836] = 6,
    [4837] = 7,
    [4867] = 8,
    [4832] = 9,
    [4780] = 10,
    [4783] = 11,
    [4847] = 12,
}

ZO_CreateStringId("SI_BINDING_NAME_RELOADUI", "Reload UI")

APESO.name = "APESO"

APESO.Default = {
    ZoneDump = {},
    CompletedQuestsByChar = {},
}

APESO.receivedItems = APESO_ReceivedItems or {}

function APESO.Initialize()
    APESO.savedVariables = ZO_SavedVars:NewAccountWide("APESOSavedVars",1,nil,APESO.Default)

    if not APESO.savedVariables.CompletedQuestsByChar then
        APESO.savedVariables.CompletedQuestsByChar = {}
    end

    if not APESO.savedVariables.ZoneAccess then
        APESO.savedVariables.ZoneAccess = {}
    end

    if not APESO.savedVariables.NodeInfo then
        APESO.savedVariables.NodeInfo = {}
    end

    if not APESO.savedVariables.delveClears then
        APESO.savedVariables.delveClears = {}
    end

    if not APESO.savedVariables.BossKills then
        APESO.savedVariables.BossKills = {}
    end


    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_FAST_TRAVEL_NETWORK_UPDATED, APESO.CheckWaystones)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_ZONE_CHANGED, APESO.OnZoneChanged)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_PLAYER_ACTIVATED, APESO.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_QUEST_COMPLETE, APESO.OnQuestComplete)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_QUEST_REMOVED, APESO.OnQuestRemoved)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_RETICLE_TARGET_CHANGED, APESO.OnReticleTargetChanged)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_CHATTER_BEGIN, APESO.OnChatterBegin)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_CLIENT_INTERACT_RESULT, APESO.OnInteract)
    EVENT_MANAGER:RegisterForEvent (APESO.name, EVENT_COMBAT_EVENT , APESO.CombatUpdate)
    --most consistant way to track enemy death
    EVENT_MANAGER:AddFilterForEvent(APESO.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_CHATTER_END, function()

        
        if APESO.DebugOverlay then
            APESO.DebugOverlay:SetHidden(true)
        end
    end)

    local function APESO_OnSceneStateChange(oldState, newState)
        if newState == SCENE_HIDDEN then
            if APESO.ShouldShowZoneWarning() then
                APESO.ShowZoneWarning()
            end
        end
    end

    local scenesToWatch = {
        "inventory",
        "skills",
        "journal",
        "map",
        "collections",
        "mailInbox",
        "mailSend",
        "bank",
        "guildBank",
        "store",
        "interact",
    }

    for _, sceneName in ipairs(scenesToWatch) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", APESO_OnSceneStateChange)
        end
    end

    APESO.receivedItems = APESO_ReceivedItems or {}

    SLASH_COMMANDS["/dumpzones"] = function()
        APESO.DumpZonesToSavedVars()
    end
    SLASH_COMMANDS["/getzoneid"] = function()
        APESO.GetCurrZoneID()
    end

    SLASH_COMMANDS["/npclock"] = function()
        local name = GetUnitName("interact")
        if APESO.Debug then
            d("NPC: " .. tostring(name))
        end
    end

    SLASH_COMMANDS["/resetdata"] = function()
        APESO.ResetData()
        d("Checked Locations data reset")
    end

    SLASH_COMMANDS["/fixquest"] = function(arg)
        local questId = tonumber(arg)
        if not questId then
            d("|cFF0000APESO: Please provide a valid quest ID.|r")
            return
        end

        local name, questType, zoneName = GetCompletedQuestInfo(questId)

        if not name or name == "" then
            d(string.format("|cFF0000APESO: Quest %d is NOT marked completed by ESO.|r", questId))
            return
        end

        local charTable = APESO.GetCharQuestTable()
        charTable[questId] = true

        d(QuestEquivalences[3658])
        if APESO.QuestEquivalences[3658] then
            d("exists")
        else
            d("no exists")
        end

        if APESO.QuestEquivalences and APESO.QuestEquivalences[questId] then
            for _, linkedQuest in ipairs(APESO.QuestEquivalences[questId]) do
                charTable[linkedQuest] = true
            end
        end

        d(string.format("|c00FF00APESO: Quest %d (%s) has been manually marked complete.|r", questId, name))
    end
    SLASH_COMMANDS["/getcoords"] = function()
        APESO.getPlayerCoordinates()
    end

    APESO.Blocker, APESO.WarningWindow = APESO.UI.CreateWarningWindow()
    APESO.DebugOverlay, APESO.DebugOverlayLabel = APESO.UI.CreateDebugOverlay()
end

function APESO.GetCharQuestTable()
    local charId = GetCurrentCharacterId()
    local all = APESO.savedVariables.CompletedQuestsByChar

    if not all[charId] then
        all[charId] = {}
    end

    return all[charId]
end

function APESO.OnAddOnLoaded(event, addonName)
    if addonName == APESO.name then
        APESO.Initialize()
        zo_callLater(function () APESO.CheckWaystones() end, 500)
        zo_callLater(function()
            APESO.RebuildZoneAccess()
        end, 500)
        EVENT_MANAGER:UnregisterForEvent(APESO.name, EVENT_ADD_ON_LOADED)
    end
end

function APESO.ShowZoneWarning()
    if not APESO.WarningWindow then return end
    if GetFrameTimeSeconds() < APESO.SuppressUntil then return end

    APESO.Blocker:SetHidden(false)
    APESO.WarningWindow:SetHidden(false)

    zo_callLater(function() 
            SetGameCameraUIMode(true)
        end,500)
end

function APESO.HideZoneWarning()
    if APESO.WarningWindow then
        APESO.WarningWindow:SetHidden(true)
        zo_callLater(function() 
            SetGameCameraUIMode(false)
        end,500)
    end
    if APESO.Blocker then
        APESO.Blocker:SetHidden(true)
    end

    -- Close menu if it’s open
    if SCENE_MANAGER:IsShowing("mainMenu") then
        SCENE_MANAGER:Hide("mainMenu")
    end
end

function APESO.SuppressWarning()
    APESO.SuppressUntil = GetFrameTimeSeconds() + APESO.SuppressDuration
    APESO.HideZoneWarning()

    zo_callLater(function()
        APESO.CheckZone()
    end, APESO.SuppressDuration * 1000)
end

function APESO.UpdateDebugOverlay(npcName)
    if not APESO.Debug or not APESO.DebugOverlay then return end

    local lockData = APESO.NPCLocks[npcName]
    local requiredQuest = lockData and lockData.requiredQuest
    local charTable = APESO.GetCharQuestTable()
    local completed = requiredQuest and charTable[requiredQuest]


    local text = string.format(
        "NPC Debug Info:\n" ..
        "Dialogue Name: %s\n" ..
        "Compass Name: %s\n" ..
        "Locked: %s\n" ..
        "Permanent: %s\n" ..
        "Required Quest: %s\n" ..
        "Quest Completed: %s\n",
        tostring(npcName),
        tostring(APESO.lastCompassName),
        tostring(lockData ~= nil),
        tostring(lockData and lockData.permanent),
        tostring(requiredQuest),
        tostring(completed)
    )

    APESO.DebugOverlayLabel:SetText(text)
    APESO.DebugOverlay:SetHidden(false)
end

EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_ADD_ON_LOADED, APESO.OnAddOnLoaded)

function APESO.CheckZone()
    APESO.HideZoneWarning()
    local zoneId = APESO.GetCurrentRegionId()
    if not zoneId then
        zo_callLater(APESO.CheckZone,250)
    end
    if zoneId == 601 then
        if APESO.savedVariables.ZoneAccess[19] then
            return
        end
    end
    if zoneId == 600 then
        if APESO.savedVariables.ZoneAccess[57] then
            return
        end
    end

    if not zoneId then return end

    if APESO.savedVariables.ZoneAccess[zoneId] or APESO.IsZoneIgnored(zoneId) then
        return
    end

    local alliance = GetUnitAlliance("player")

    if zoneId == 537 and alliance == ALLIANCE_ALDMERI_DOMINION then
        d("|cFF0000Starting zone should not be locked but is, check to see if the client is connected|r")
        return
    end
    if zoneId == 280 and alliance == ALLIANCE_EBONHEART_PACT then
        d("|cFF0000Starting zone should not be locked but is, check to see if the client is connected|r")
        return
    end
    if zoneId == 534 and alliance == ALLIANCE_DAGGERFALL_COVENANT then
        d("|cFF0000Starting zone should not be locked but is, check to see if the client is connected|r")
        return
    end

    APESO.TeleportToStarterZone()
    APESO.ShowZoneWarning()

end

function APESO.CheckWaystones()
    local numNodes = GetNumFastTravelNodes()
    local nodeInfo = {}

    for i = 1, numNodes do
        nodeInfo[i] = HasCompletedFastTravelNodePOI(i)
    end

    APESO.savedVariables.NodeInfo = nodeInfo
end


function APESO.GetCurrentRegionId()
    local zoneIndex = GetUnitZoneIndex("player")
    if not zoneIndex then return nil end

    return GetZoneId(zoneIndex)
end


function APESO.DumpZonesToSavedVars()
    local zones = {}
    local num = GetNumZones()

    -- Collect all zone IDs
    for i = 1, num do
        local zoneId = GetZoneId(i)
        if zoneId and zoneId > 0 then
            local parent = GetParentZoneId(zoneId)
            local effective = (parent ~= 0 and parent) or zoneId
            local name = GetZoneNameById(effective)
            zones[effective] = name
        end
    end

    -- Sort numerically
    local sorted = {}
    for id, name in pairs(zones) do
        table.insert(sorted, { id = id, name = name })
    end
    table.sort(sorted, function(a, b) return a.id < b.id end)

    -- Save sorted list into SavedVariables
    APESO.savedVariables.ZoneDump = sorted
end

function APESO.RebuildZoneAccess()
    APESO.savedVariables.ZoneAccess = {}  -- wipe and rebuild

    for _, entry in ipairs(APESO_ReceivedItems or {}) do
        if entry.item_id and entry.item_id >= 150000 and entry.item_id < 160000 then
            local zoneId = entry.item_id - 150000
            APESO.savedVariables.ZoneAccess[zoneId] = true
        end
    end
end

function APESO.UnlockZone(zoneId)
    APESO.savedVariables.ZoneAccess[zoneId] = true
end

function APESO.TeleportToStarterZone()
    local alliance = GetUnitAlliance("player")

    if alliance == ALLIANCE_DAGGERFALL_COVENANT then
        FastTravelToNode(137)

    elseif alliance == ALLIANCE_EBONHEART_PACT then
        FastTravelToNode(171)

    elseif alliance == ALLIANCE_ALDMERI_DOMINION then
        FastTravelToNode(140)
    end
end

function APESO.OnZoneChanged(_, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    zo_callLater(APESO.CheckZone,300)
    zo_callLater(APESO.CheckWaystones, 300)
end

function APESO.OnPlayerActivated()
    APESO.RebuildZoneAccess()
    APESO.CheckZone()
    if APESO.savedVariables.CharID ~= GetCurrentCharacterId() then
        APESO.ResetData()
    end
    APESO.savedVariables.CharID = GetCurrentCharacterId()
end

function APESO.GetCurrZoneID()
    d(APESO.GetCurrentRegionId())
end

function APESO.OnQuestComplete(_, questName, level, previousXP, currentXP, rank)
    -- Find the quest in the journal by name
    for journalIndex = 1, MAX_JOURNAL_QUESTS do
        local name = GetJournalQuestName(journalIndex)
        if name == questName then
            local questId = GetJournalQuestId(journalIndex)
            if questId then
                APESO.MarkQuestComplete(questId)
            end
            break
        end
    end
end

function APESO.OnQuestRemoved(_, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questId)
    if isCompleted then
        APESO.MarkQuestComplete(questId)
    end
end

function APESO.MarkQuestComplete(questId)
    local charTable = APESO.GetCharQuestTable()
    charTable[questId] = true

    if APESO.QuestEquivalences and APESO.QuestEquivalences[questId] then
        for _, linkedQuest in ipairs(APESO.QuestEquivalences[questId]) do
            charTable[linkedQuest] = true
        end
    end
end

function APESO.OnChatterBegin(eventCode)
    local npcName = GetUnitName("interact")

    if APESO.Debug then
        d("OnChatterBegin fired for: " .. tostring(npcName))
    end

    APESO.UpdateDebugOverlay(npcName)

    if tostring(npcName) == "Abnur Tharn" then
        local questStep = APESO.GetMainQuestStep()
        local itemCount = APESO.CountProgressiveMainQuest()
        if questStep > itemCount then
            EndInteraction(INTERACTION_CONVERSATION)
            APESO.ShowMainQuestBlockWarning()
        end
    end

    local lockData = APESO.NPCLocks[npcName]
    if not lockData then return end

    -- Permanent lock
    if lockData.permanent then
        APESO.ShowNPCBlockedWarning(npcName)
        SCENE_MANAGER:HideCurrentScene()
        EndInteraction(INTERACTION_CONVERSATION)
        return
    end

    -- Quest-based lock
    local requiredQuest = lockData.requiredQuest
    local charTable = APESO.GetCharQuestTable()

    if requiredQuest and not charTable[requiredQuest] then
        APESO.ShowNPCBlockedWarning(npcName)
        EndInteraction(INTERACTION_CONVERSATION)
        return
    end
end

function APESO.ShowNPCBlockedWarning(npcName)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, npcName .. " is locked until you complete the required quest.")
end


function APESO.OnReticleTargetChanged(eventCode)
    APESO.lastNpcName = name
end

function APESO.OnInteract()
    local actionName, name = GetGameCameraInteractableActionInfo()
    --Main Quest Lock
    if APESO_ZoneDoors[name] then
        if not APESO.savedVariables.ZoneAccess[APESO_ZoneDoors[name]] then
            EndInteraction(INTERACTION_NONE)
        end
    end

    if name == "The Harborage" or name == "Portal to Coldharbour" or name == "Portal to Alliance Capital" or name == "Portal to Stirk" then
        local questStep = APESO.GetMainQuestStep()
        local itemCount = APESO.CountProgressiveMainQuest()
        --Check current stage of Main Quest
        if questStep > itemCount then
            EndInteraction(INTERACTION_NONE)
            APESO.ShowMainQuestBlockWarning()
        end
    end
    
    if APESO.Debug then
        d(name)
    end
end

function APESO.GetMainQuestStep()
    local charTable = APESO.GetCharQuestTable()

    for questId, step in pairs(MAIN_QUEST_STEPS) do
        if charTable[questId] then
            return step
        end
    end

    return 0
end

function APESO.CountProgressiveMainQuest()
    local count = 0
    local items = APESO_ReceivedItems

    if not items then
        return 0
    end

    for _, entry in ipairs(items) do
        if entry.item_id == 149996 then
            count = count + 1
        end
    end

    return count
end

function APESO.IsZoneIgnored(zoneId)
    return APESO_IgnoreZones and APESO_IgnoreZones[zoneId] == true
end

function APESO.ReloadUI()
    ReloadUI()
end

function APESO.ShouldShowZoneWarning()
    if not APESO.WarningWindow then return false end

    if GetFrameTimeSeconds() < APESO.SuppressUntil then
        return false
    end

    local zoneId = APESO.GetCurrentRegionId()
    if not zoneId then return false end

    -- Allowed zones
    if APESO.savedVariables.ZoneAccess[zoneId] then
        return false
    end

    -- Ignored zones
    if APESO.IsZoneIgnored(zoneId) then
        return false
    end

    return true
end

local function APESO_OnUIModeChanged(event, isInUIMode)
    if APESO.WarningWindow and not APESO.WarningWindow:IsHidden() then
        if not isInUIMode then
            SetGameCameraUIMode(true)
        end
    end
end

EVENT_MANAGER:RegisterForEvent("APESO_UIModeLock", EVENT_GAME_CAMERA_UI_MODE_CHANGED, APESO_OnUIModeChanged)

function APESO.ShowMainQuestBlockWarning()
    APESO.UI.CreateMainQuestBlockWindow()
    zo_callLater(function()
            SetGameCameraUIMode(true)
        end,250)
    APESO.MainQuestBlockWindow:SetHidden(false)
end

function APESO.getPlayerCoordinates()
    d( GetUnitRawWorldPosition("player"))
end

function APESO.IsInRange(obX, obY, obZ)
    local x, y, z = GetUnitRawWorldPosition("player")

    local xDiff = obX - x
    local yDiff = obY - y
    local zDiff = obZ - z
    if xDiff < 0 then
        xDiff = xDiff * -1
    end

    if yDiff < 0 then
        yDiff = yDiff * -1
    end

    if zDiff < 0 then
        zDiff = zDiff * -1
    end

    local totalDiff = math.sqrt((xDiff * xDiff) + (zDiff*zDiff))

    if totalDiff > 500 or yDiff > 200 then
        return false
    else
        return true
    end
end


function APESO.CombatUpdate(eventCode, result, isError, abilityName, abilityGraphic, abilitySlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, TargetUnitID, abilityId, overflow)
    -- if action result is xp gained (most consistant way to track enemy death)
    --check if target name is in 
    regionid = APESO.GetCurrentRegionId()
    if APESO_DelveData[regionid] then
        --check if targetName is in bosses
        for _, v in ipairs(APESO_DelveData[regionid].bosses) do
            if v == targetName then
                APESO.savedVariables.BossKills[targetName] = true
                d("|c00FF00Boss Tracked|r")
                break
            end
        end

        --Check if all bosses Dead
        APESO.savedVariables.delveClears[APESO_DelveData[regionid].locationId] = APESO.CheckDelve(regionid)
    end
end

function APESO.CheckDelve(regionid)
    for _, bossname in ipairs(APESO_DelveData[regionid].bosses) do
        if not APESO.savedVariables.BossKills[bossname] then
            return false
        end
    end
    if not APESO.savedVariables.delveClears[APESO_DelveData[regionid].locationId] then
        d("|c00FF00Dungeon Tracked|r")
    end
    return true
end

function APESO.ResetData()
    APESO.savedVariables.BossKills = {}
    APESO.savedVariables.delveClears = {}
end
