APESO.UI = APESO.UI or {}

function APESO.UI.CreateMainQuestBlockWindow()
    if APESO.MainQuestBlockWindow then return end

    local wm = WINDOW_MANAGER
    local ui = wm:CreateTopLevelWindow("APESO_MainQuestBlockWindow")
    APESO.MainQuestBlockWindow = ui

    ui:SetDimensions(500, 250)
    ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    ui:SetMovable(false)
    ui:SetMouseEnabled(true)
    ui:SetHidden(true)
    ui:SetDrawLayer(DL_OVERLAY)
    ui:SetDrawTier(DT_HIGH)
    ui:SetDrawLevel(999999)

    -- Backdrop
    local bg = wm:CreateControl(nil, ui, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.85)
    bg:SetEdgeColor(1, 1, 1, 0.4)
    bg:SetEdgeTexture("", 1, 1, 1)

    -- Label
    local label = wm:CreateControl(nil, ui, CT_LABEL)
    label:SetAnchor(TOP, ui, TOP, 0, 30)
    label:SetFont("ZoFontWinH1")
    label:SetText("You cannot progress here yet.")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Reload Button
    local reloadBtn = wm:CreateControlFromVirtual(nil, ui, "ZO_DefaultButton")
    reloadBtn:SetAnchor(BOTTOMLEFT, ui, BOTTOMLEFT, 40, -40)
    reloadBtn:SetText("Reload UI")
    reloadBtn:SetHandler("OnClicked", function()
        ReloadUI()
    end)

    -- Close Button
    local closeBtn = wm:CreateControlFromVirtual(nil, ui, "ZO_DefaultButton")
    closeBtn:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, -40, -40)
    closeBtn:SetText("Close")
    closeBtn:SetHandler("OnClicked", function()
        ui:SetHidden(true)
    end)
end
