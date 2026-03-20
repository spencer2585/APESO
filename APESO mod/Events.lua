APESOEvents = APESOEvents or {}
--This file contains all functions related to handling events in the mod

--register event listeners
function APESOEvents.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_PLAYER_ACTIVATED, APESOEvents.EventPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_CLIENT_INTERACT_RESULT, APESOEvents.EventClientInteractResult)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_CHATTER_BEGIN, APESOEvents.EventChatterBegin)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_QUEST_COMPLETE, APESOEvents.EventQuestComplete)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_COMBAT_EVENT, APESOEvents.EventCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(APESO.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_START_FAST_TRAVEL_INTERACTION, APESOEvents.EventFastTravelInteraction)
end

function APESOEvents.EventPlayerActivated()
    APESOHelpers.LockZone()
end

function APESOEvents.EventPoisInitialized()
    d("[APESO DEBUG] POIs initialized")
end

function APESOEvents.EventClientInteractResult(_, result, targetName)
    APESOHelpers.CheckInteraction(targetName)
    APESOLocations.CheckInteraction(targetName)
end

function APESOEvents.EventChatterBegin(_, OptionCount)
    APESOHelpers.CheckNPCName()
end

function APESOEvents.EventQuestComplete(_, questName, level, previousXP, currentXP, rank)
    -- Find the quest in the journal by name
    for journalIndex = 1, MAX_JOURNAL_QUESTS do
        local name = GetJournalQuestName(journalIndex)
        if name == questName then
            local questId = GetJournalQuestId(journalIndex)
            if questId then
                APESOLocations.MarkQuestComplete(questId)
            end
            break
        end
    end
end

function APESOEvents.EventCombatEvent(_, result, isError, abilityName, abilityGraphic, abilitySlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, TargetUnitId, abilityId, overflow)
    if result == ACTION_RESULT_DIED_XP then
        APESOLocations.CheckKilledEnemy(targetName)
    end
end

function APESOEvents.EventFastTravelInteraction(_, nodeId)
    APESOLocations.SendWayshrine(nodeId)
end
