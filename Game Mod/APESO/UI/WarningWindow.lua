APESO.UI = APESO.UI or {}

function APESO.UI.CreateWarningWindow()
    local wm = WINDOW_MANAGER

    -- Fullscreen input blocker
    local blocker = wm:CreateTopLevelWindow("APESOBlocker")
    blocker:SetAnchorFill(GuiRoot)
    blocker:SetMouseEnabled(true)
    blocker:SetMovable(false)
    blocker:SetHidden(true)
    blocker:SetDrawLayer(DL_OVERLAY)
    blocker:SetDrawTier(DT_HIGH)
    blocker:SetDrawLevel(999998)

    -- Add a solid black backdrop to fully obscure the screen
    local blackout = wm:CreateControl(nil, blocker, CT_BACKDROP)
    blackout:SetAnchorFill()
    blackout:SetCenterColor(0, 0, 0, 1)      -- solid black
    blackout:SetEdgeColor(0, 0, 0, 0)        -- no border


    -- Popup window
    local win = wm:CreateTopLevelWindow("APESOZoneWarning")
    win:SetDimensions(450, 200)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200)
    win:SetMovable(false)
    win:SetMouseEnabled(true)
    win:SetHidden(true)

    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLevel(999999)
    win:SetClampedToScreen(true)

    local bg = wm:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(1, 1, 1, 1)

    local label = wm:CreateControl(nil, win, CT_LABEL)
    label:SetAnchor(TOP, win, TOP, 0, 20)
    label:SetFont("ZoFontWinH2")
    label:SetText("You do not have access to this zone.")

    local reloadBtn = wm:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    reloadBtn:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 20, -20)
    reloadBtn:SetText("Reload UI")
    reloadBtn:SetHandler("OnClicked", function()
        ReloadUI()
    end)

    local suppressBtn = wm:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    suppressBtn:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -20)
    suppressBtn:SetText("Suppress")
    suppressBtn:SetHandler("OnClicked", function()
        APESO.SuppressWarning()
    end)

    return blocker, win
end
