APESO.UI = APESO.UI or {}

APESO.UI.menuTabs = {}

function APESO.UI.CreateMenu()
    local wm = WINDOW_MANAGER
    local menu = wm:CreateTopLevelWindow("APESOMenu")
    menu:SetDimensions(650, 400)
    menu:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200)
    menu:SetMovable(true)
    menu:SetMouseEnabled(true)
    menu:SetHidden(true)

    menu:SetDrawLayer(DL_OVERLAY)
    menu:SetDrawTier(DT_HIGH)
    menu:SetDrawLevel(999999)
    menu:SetClampedToScreen(true)
    menu:SetDimensionConstraints(650,400,GuiRoot:GetWidth(), GuiRoot:GetHeight())
    menu:SetResizeHandleSize(10)

    local bg = wm:CreateControl(nil, menu, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(1, 1, 1, 1)

    local tab = wm:CreateControl(nil, menu, CT_CONTROL)
    tab:SetAnchor(TOPRIGHT,menu,TOPRIGHT,0,0)
    tab:SetAnchor(TOPLEFT, menu, TOPLEFT,0 ,0)
    tab:SetHeight(40)

    local closeContainer = wm:CreateControl(nil, menu, CT_CONTROL)
    closeContainer:SetAnchor(BOTTOMLEFT, menu, BOTTOMLEFT,0,0)
    closeContainer:SetAnchor(BOTTOMRIGHT, menu, BOTTOMRIGHT,0,0)
    closeContainer:SetHeight(40)

    local closeButton = wm:CreateControlFromVirtual(nil, closeContainer, "ZO_DefaultButton")
    closeButton:SetAnchor(TOPRIGHT, closeContainer, TOPRIGHT,0,0)
    closeButton:SetAnchor(BOTTOMRIGHT, closeContainer, BOTTOMRIGHT,10,10)
    closeButton:SetWidth(120)
    closeButton:SetText("Close Menu")
    closeButton:SetHandler("OnClicked", function() menu:SetHidden(true) SetGameCameraUIMode(false) end)

    local optionsTab = wm:CreateControl(nil, tab, CT_LABEL)
    optionsTab:SetDimensions(100,40)
    optionsTab:SetAnchor(TOPLEFT, tab, TOPLEFT,10,5)
    optionsTab:SetText("Options")
    optionsTab:SetMouseEnabled(true)
    optionsTab:SetFont("ZoFontWinH2")
    optionsTab:SetHandler("OnMouseUp",function() APESO.UI.SetMenuTab("Options") end)


    local optionsContent = wm:CreateControl(nil, menu, CT_CONTROL)
    optionsContent:SetAnchor(TOPLEFT, tab,BOTTOMLEFT, 0, 0)
    optionsContent:SetAnchor(BOTTOMRIGHT, closeContainer, TOPRIGHT, 0, 0)
    APESO.UI.menuTabs["Options"] = optionsContent

    APESO.UI.CreateOptionsMenu(optionsContent, wm)
    
    return menu
end

function APESO.UI.SetMenuTab(contents)
    for name, panel in pairs(APESO.UI.menuTabs) do
        panel:SetHidden(true)
    end
    local panel = APESO.UI.menuTabs[contents]
    panel:SetHidden(false)
end

function APESO.UI.CreateOptionsMenu(optionsContent, wm)
    local reloadToggle = wm:CreateControlFromVirtual(nil, optionsContent, "ZO_CheckButton")
    reloadToggle:SetAnchor(TOPLEFT, optionsContent, TOPLEFT, 20, 20)
    if not APESO.savedVariables["Options"] then
        APESOHelpers.CreateSavedVariablesOptions()
    end
    ZO_CheckButton_SetCheckState(reloadToggle, APESO.savedVariables["Options"].reloadOnCheck)
    ZO_CheckButton_SetToggleFunction(reloadToggle, function() APESO.savedVariables["Options"].reloadOnCheck = ZO_CheckButton_IsChecked(reloadToggle) end)

    local reloadLabel = wm:CreateControl(nil, optionsContent, CT_LABEL)
    reloadLabel:SetAnchor(TOPLEFT, reloadToggle, TOPRIGHT, 10, 0)
    reloadLabel:SetAnchor(BOTTOMLEFT, reloadToggle, BOTTOMRIGHT, 10, 0)
    reloadLabel:SetText("Auto run ReloadUI when location is checked (will only run when out of combat)")
    reloadLabel:SetFont("ZoFontGame")

    local debugToggle = wm:CreateControlFromVirtual(nil, optionsContent, "ZO_CheckButton")
    debugToggle:SetAnchor(TOPLEFT, reloadToggle, BOTTOMLEFT, 0, 20)
    ZO_CheckButton_SetCheckState(debugToggle, APESO.savedVariables["Options"].DebugMode)
    ZO_CheckButton_SetToggleFunction(debugToggle, function() APESO.savedVariables["Options"].DebugMode = ZO_CheckButton_IsChecked(debugToggle) end)

    local debugLabel = wm:CreateControl(nil, optionsContent, CT_LABEL)
    debugLabel:SetAnchor(TOPLEFT, debugToggle, TOPRIGHT, 10, 0)
    debugLabel:SetAnchor(BOTTOMLEFT, debugToggle, BOTTOMRIGHT, 10, 0)
    debugLabel:SetText("Enable Debug Mode")
    debugLabel:SetFont("ZoFontGame")
end
