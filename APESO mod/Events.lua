APESOEvents = APESOEvents or {}
--This file contains all functions related to handling events in the mod

--register event listeners
function APESOEvents.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(APESO.name, EVENT_ZONE_CHANGED, APESOEvents.EventZoneChanged())
end

function APESOEvents.EventZoneChanged()
    zo_callLater(APESOHelpers.LockZone, 3000)
    zo_callLater(function() d("running Zone Changed") end, 8000)
    APESO.UI.ShowZoneWarning()
end
