APESO.UI = APESO.UI or {}

APESO.UI.zoneWarningWindow, APESO.UI.blocker = APESO.UI.CreateWarningWindow()

--create all UI
function APESO.UI.StartUI()
    APESO.UI.blocker:SetHidden(true)
    APESO.UI.zoneWarningWindow:SetHidden(true)
end

--show zone warning window
function APESO.UI.ShowZoneWarning()
    --show windows
    APESO.UI.blocker:SetHidden(false)
    APESO.UI.zoneWarningWindow:SetHidden(false)

    --turn on mouse pointer
    zo_callLater(function() SetGameCameraUIMode(true) end, 500)
end

--hide zone warning window
function APESO.UI.HideZoneWarning()
    APESO.UI.blocker:SetHidden(true)
    APESO.UI.zoneWarningWindow:SetHidden(true)
    zo_callLater(function() SetGameCameraUIMode(false) end,500)
end

function APESO.UI.SuppressZoneWarning()
    local suppressTime = 8000
    if APESO.DebugMode then
        suppressTime = 180000
    end
    APESO.UI.HideZoneWarning()
    zo_callLater(function() APESOHelpers.LockZone() end, suppressTime)
end