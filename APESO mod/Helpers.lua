APESOHelpers = APESOHelpers or {}

--Checks if player has access to a zone
function APESOHelpers.CheckZoneAccess(zoneID)
    if APESO.ZoneAccess[zoneID] then
        return true
    else
        return false
    end
end

--checks if the player has the zone they are currently in
function APESOHelpers.CheckCurrentZone()
    local zoneIndex = GetZoneId(GetUnitZoneIndex("player"))
    return APESOHelpers.CheckZoneAccess(zoneIndex)
end

function APESOHelpers.GetCurrentZoneId()
    return GetZoneId(GetUnitZoneIndex("player"))
end

--return the value of the option in the options table
function APESOHelpers.GetOption(option)
    if APESO_options[option] ~= nil then
        return APESO_options[option]
    --error
    else
        --if debug mode is on then print error
        if APESO.DebugMode then
            d("Option ".. option .. " does not exist")
        end
        return 0
    end
end

function APESOHelpers.GetCurrentZone()
    return GetUnitZoneIndex("player")
end

function APESOHelpers.LockZone()
    APESO.UI.HideZoneWarning()
    local currZone = APESOHelpers.GetCurrentZone()
    local zoneData = APESO_ZoneData[3]
    if zoneData.type == "delve" and APESOHelpers("delvesEnabled") == 1 then
        if not APESO.CheckCurrentZone() then
            APESO.UI.ShowZoneWarning()
        end
    elseif zoneData.type == "zone" and not APESOHelpers.CheckCurrentZone() then
        APESO.UI.ShowZoneWarning()
    end
end

function APESOHelpers.CheckInteraction(targetName)
    if targetName == "The Harborage" or targetName == "Portal to Coldharbour" or targetName == "Portal to Alliance Capital" or targetName == "Portal to Stirk" then
        local questStep = APESOHelpers.GetMainQuestStep()
        if questStep > APESO.ProgressiveMainQuest then
            EndInteraction(INTERACTION_NONE)
            return
        end
    end
    --check if the targetName matches any of the zone names in the zone data
    for id in pairs(APESO_ZoneData) do
        --if the targetName matches the zone name then check if the player has access to that zone
        if targetName == APESO_ZoneData[id].name then
            --if the zone is a delve and delves are enabled then check if the player has access to that delve
            if APESO_ZoneData[id].type == "delve" and APESOHelpers.GetOption("delves_per_region") > 0 then
                if not APESOHelpers.CheckZoneAccess(id) then
                    EndInteraction(INTERACTION_NONE)
                    return
                end
            else
                if not APESOHelpers.CheckZoneAccess(id) then
                    EndInteraction(INTERACTION_NONE)
                    return
                end
            end
        end
    end
    if APESO_ExtraInteractBlocks[targetName] ~= nil then
        if APESO_ExtraInteractBlocks[targetName].itemType == "zone" then
            if not APESOHelpers.CheckZoneAccess(APESO_ExtraInteractBlocks[targetName].requiredItem) then
                EndInteraction(INTERACTION_NONE)
                return
            end
        end
    end
end

function APESOHelpers.GetMainQuestStep()
    for id in pairs(APESO_MainQuests) do
        local name = GetCompletedQuestInfo(APESO_MainQuests[id].Id)
        if name == "" then
            return id-1
        end
    end
end

function APESOHelpers.CheckNPCName()
    local npcName = GetUnitName("interact")
    
    if APESO.DebugMode then
        d("Interacting with NPC: " .. npcName)
    end 

    if tostring(npcName) == "Abnur Tharn" then
        local questStep = APESOHelpers.GetMainQuestStep()
        if questStep > APESO.ProgressiveMainQuest then
            EndInteraction(INTERACTION_NONE)
            return
        end
    end
end

function APESOHelpers.IsOverGoldCap()
    local baseGoldCap = APESOHelpers.GetOption("goldCap")
    if baseGoldCap == 0 then
        return false
    end

    local totalCapacity = baseGoldCap + (APESO.GoldIncrease * 1000)

    local CurrentGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    return CurrentGold >= totalCapacity
end

function APESOHelpers.GetGoldCap()
    local baseGoldCap = APESOHelpers.GetOption("goldCap")
    if baseGoldCap == 0 then
        return "No Cap"
    end

    local totalCapacity = baseGoldCap + (APESO.GoldIncrease * 1000)
    return totalCapacity
end

function APESOHelpers.GetCurrentGold()
    local CurrentGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    return CurrentGold
end

function APESOHelpers.ReloadUI()
    ReloadUI()
end