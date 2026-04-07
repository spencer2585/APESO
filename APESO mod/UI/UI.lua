APESO.UI = APESO.UI or {}

APESO.UI.zoneWarningWindow, APESO.UI.blocker = nil
APESO.UI.menu = nil

--create all UI
function APESO.UI.StartUI()
    APESO.UI.menu = APESO.UI.CreateMenu()
    APESO.UI.zoneWarningWindow, APESO.UI.blocker = APESO.UI.CreateWarningWindow()
    APESO.UI.blocker:SetHidden(true)
    APESO.UI.zoneWarningWindow:SetHidden(true)
    APESO.UI.menu:SetHidden(true)
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

function APESO.UI.ShowMenu()
    APESO.UI.menu:SetHidden(false)
    APESOHelpers.CheckAlliance()
    zo_callLater(function() SetGameCameraUIMode(true) end, 500)
end

function APESO.UI.HideMenu()
    APESO.UI.menu:SetHidden(true)
    zo_callLater(function() SetGameCameraUIMode(false) end, 500)
end