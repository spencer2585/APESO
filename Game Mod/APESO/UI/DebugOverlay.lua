APESO.UI = APESO.UI or {}

function APESO.UI.CreateDebugOverlay()
    local wm = WINDOW_MANAGER

    local overlay = wm:CreateTopLevelWindow("APESODebugOverlay")
    overlay:SetDimensions(400, 120)
    overlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 20)
    overlay:SetMovable(true)
    overlay:SetMouseEnabled(true)
    overlay:SetHidden(true)
    overlay:SetDrawLayer(DL_OVERLAY)
    overlay:SetDrawTier(DT_HIGH)
    overlay:SetDrawLevel(999999)

    local bg = wm:CreateControl(nil, overlay, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.6)
    bg:SetEdgeColor(1, 1, 1, 0.8)

    local label = wm:CreateControl(nil, overlay, CT_LABEL)
    label:SetAnchor(TOPLEFT, overlay, TOPLEFT, 10, 10)
    label:SetFont("ZoFontGame")
    label:SetText("Debug Overlay")
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)

    return overlay, label
end