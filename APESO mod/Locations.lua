APESOLocations = APESOLocations or {}

function APESOLocations.CheckInteraction(targetName)
end

function APESOLocations.SendWayshrine(nodeId)
    if APESOHelpers.CheckIncludedWayshrines() then
        if not APESO.savedVariables[APESO.seed].NodeInfo[nodeId] then
            APESO.savedVariables[APESO.seed].NodeInfo[nodeId] = true
            APESOHelpers.ReloadOutOfCombat()
        end
    end
end

function APESOLocations.MarkQuestComplete(questId)
    APESO.savedVariables[APESO.seed].CompletedQuests[questId] = true
    if APESO_QuestEquivalances and APESO_QuestEquivalances[questId] then
        for _, linkedQuest in ipairs(APESO_QuestEquivalances[questId]) do
            APESO.savedVariables[APESO.seed].CompletedQuests[linkedQuest] = true
        end
    end
    if APESO_QuestData[questId] then
        local questData = APESO_QuestData[questId]
        local includedZones = APESOHelpers.GetOption("selected_zones")
        if questData.type == "zone" then
            if APESOHelpers.GetOption("zone_quests_enabled")then
                for _, zone in ipairs(includedZones) do
                    if zone == questData.zone then
                        if questData.addZone then
                            for _, addzone in ipairs(includedZones) do
                                if addzone == questData.addZone then
                                    APESOHelpers.ReloadOutOfCombat()
                                    return
                                end
                            end
                        else
                            APESOHelpers.ReloadOutOfCombat()
                            return
                        end
                    end
                end
            end
        elseif questData.type == "main" and APESOHelpers.GetOption("main_quests_enabled") then
            APESOHelpers.ReloadOutOfCombat()
        end
    end
end

function APESOLocations.CheckKilledEnemy(targetName)
    local regionId = APESOHelpers.GetCurrentZoneId()
    local cleanName = targetName:match("(.-)%^") or targetName
    
    if APESO.savedVariables["Options"].DebugMode then
        d("Killed Enemy " .. cleanName)
    end
    if APESO_DelveData[regionId] then
        for _, v in ipairs(APESO_DelveData[regionId].bosses) do
            if v == cleanName then
                APESO.savedVariables[APESO.seed].BossKills[cleanName] = true
                d("|c00FF00Boss Killed|r")
                break
            end
        end
        APESO.savedVariables[APESO.seed].delveClears[regionId] = APESOLocations.CheckDelve(regionId)
    end
end

function APESOLocations.CheckDelve(regionId)
    if not APESO.savedVariables[APESO.seed].delveClears[regionId] then
        for _, bossname in ipairs(APESO_DelveData[regionId].bosses) do
            if not APESO.savedVariables[APESO.seed].BossKills[bossname] then
                return false
            end
        end
        if APESOHelpers.CheckIncludedDelve() then
            APESOHelpers.ReloadOutOfCombat()
        end
    end
    return true
end
    
