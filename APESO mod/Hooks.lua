APESOHooks = APESOHooks or {}

function APESOHooks.CreateHooks()
    APESOHooks.RegisterDialogueHook()
    APESOHooks.RegisterLootHook()
    APESOHooks.RegisterQuestCompleteHook()
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
            if APESOHelpers.IsOverGoldCap() then
                d("[Archipelago] Cannot loot gold - capacity reached!")
                return true  -- BLOCK
            end
        end
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