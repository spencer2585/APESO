APESOHooks = APESOHooks or {}

function APESOHooks.CreateHooks()
    APESOHooks.RegisterDialogueHook()
    APESOHooks.RegisterLootHook()
    APESOHooks.RegisterQuestCompleteHook()
    APESOHooks.RegisterFastTravelHook()
end


function APESOHooks.RegisterDialogueHook()
    ZO_PreHook("SelectChatterOption", function(optionIndex)
        local npcName = GetUnitName("interact")
        local dialogueText = GetChatterOption(optionIndex)

        if APESO.savedVariables["Options"].DebugMode then
            d("Interacting with NPC: " .. npcName)
            d("Selected dialogue option: " .. dialogueText)
        end
        
        if not APESO_TravelNPCs then return end

        local npcData = APESO_TravelNPCs[npcName]
        if not npcData then return end

        

        
        -- Match by checking if dialogue starts with any key
        local optionData = nil
        for partialKey, data in pairs(npcData) do
            if string.find(dialogueText, "^" .. partialKey) then  -- Starts with
                optionData = data
                break
            end
        end
        
        if not optionData then return end
        
        if optionData.itemType == "zone" then
            if not APESOHelpers.CheckZoneAccess(optionData.zoneId) then
                d("[Archipelago] You don't have access to that destination!")
                return true
            end
        end
    end)
end

function APESOHooks.RegisterLootHook()
    ZO_PreHook("LootCurrency", function(currencyType)
        if currencyType == CURT_MONEY then
            if not APESO.HasUnlimitedWallet then
                if APESOHelpers.IsOverGoldCap() then
                    d("[Archipelago] Cannot loot gold - capacity reached!")
                    return true  -- BLOCK
                end
            end
        end
        return false
    end)
end

function APESOHooks.RegisterQuestCompleteHook()
    ZO_PreHook("CompleteQuest", function()
        if APESOHelpers.IsOverGoldCap() then
            d("[Archipelago] Cannot complete quest - gold capacity reached!")
            return true  -- BLOCK
        end
    end)
end

function APESOHooks.RegisterFastTravelHook()
    ZO_PreHook("FastTravelToNode", function(nodeId)
        _, wayshrineName = GetFastTravelNodeInfo(nodeId)
        if not APESO_Wayshrines[wayshrineName] then
            d("[APESO] Data Error - Blocking Teleport, Please report in the discord: Error on nodeId: "..nodeId)
        end
        zone = APESO_Wayshrines[wayshrineName].zone
        zoneid = APESOHelpers.GetZoneIdFromName(zone)
        if zoneid == 0 then
            d("[APESO] Wayshrine not in the randomizer - blocking teleport")
            return true
        end
        if APESOHelpers.CheckZoneAccess(zoneid) then
            -- Zone is Unlocked check for item
            wayshrineLocking = APESOHelpers.getOption("wayshrine_locking")
            if wayshrineLocking == 2 then
                if APESO.WayshrineAccess[nodeId] then
                    return false
                else
                    return true
                end
            elseif wayshrineLocking == 1 then
                if APESO.WayshrineAccess[zoneid] then
                    return false
                else
                    return true
                end
            else
                return false
            end
        else
            return true
        end
        return true
    end)
end