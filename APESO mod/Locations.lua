APESOLocations = APESOLocations or {}

function APESOLocations.CheckInteraction(targetName)
end

function APESOLocations.SendWayshrine(nodeId)
    if not APESO.savedVariables[APESO.seed].NodeInfo[nodeId] then
        APESO.savedVariables[APESO.seed].NodeInfo[nodeId] = true
        d("|c00FF00Wayshrine complete, reloadUI to send location|r")
    end
end

function APESOLocations.MarkQuestComplete(questId)
    if not APESO.savedVariables[APESO.seed].CompletedQuests[questId] then
        d("|c00FF00Quest complete, reloadUI to send location|r")
    end
    APESO.savedVariables[APESO.seed].CompletedQuests[questId] = true
    if APESO_QuestEquivalances and APESO_QuestEquivalances[questId] then
        for _, linkedQuest in ipairs(APESO_QuestEquivalances[questId]) do
            APESO.savedVariables[APESO.seed].CompletedQuests[linkedQuest] = true
        end
    end
end

function APESOLocations.CheckKilledEnemy(targetName)
    local regionId = APESOHelpers.GetCurrentZoneId()
    local cleanName = targetName:match("(.-)%^") or targetName
    
    if APESO.DebugMode then
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
        d("|c00FF00Delve complete, reloadUI to send location|r")
    end
    return true
end
    
