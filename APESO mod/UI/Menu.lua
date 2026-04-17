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
    bg:SetEdgeColor(0.77254909276962, 0.7607843875885, 0.61960786581039, 1)

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
    closeButton:SetAnchor(BOTTOMRIGHT, closeContainer, BOTTOMRIGHT,-10,-10)
    closeButton:SetWidth(120)
    closeButton:SetText("Close Menu")
    closeButton:SetHandler("OnClicked", function() menu:SetHidden(true) SetGameCameraUIMode(false) end)

    local itemsTab = wm:CreateControl(nil, tab, CT_LABEL)
    itemsTab:SetDimensions(70,40)
    itemsTab:SetAnchor(TOPLEFT, tab, TOPLEFT, 10,5)
    itemsTab:SetText("Items")
    itemsTab:SetMouseEnabled(true)
    itemsTab:SetFont("ZoFontWinH2")
    itemsTab:SetColor(0.77254909276962, 0.7607843875885, 0.61960786581039, 1)
    itemsTab:SetHandler("OnMouseUp",function() APESO.UI.SetMenuTab("Items") end)

    local itemsContent = wm:CreateControl(nil, menu, CT_CONTROL)
    itemsContent:SetAnchor(TOPLEFT, tab, BOTTOMLEFT, 0, 0)
    itemsContent:SetAnchor(BOTTOMRIGHT, closeContainer, TOPRIGHT, 0, 0)
    APESO.UI.menuTabs["Items"] = itemsContent
    APESO.UI.CreateItemsMenu(itemsContent, wm)

    local optionsTab = wm:CreateControl(nil, tab, CT_LABEL)
    optionsTab:SetDimensions(100,40)
    optionsTab:SetAnchor(TOPLEFT, itemsTab, TOPRIGHT,0,0)
    optionsTab:SetText("Options")
    optionsTab:SetMouseEnabled(true)
    optionsTab:SetFont("ZoFontWinH2")
    optionsTab:SetColor(0.77254909276962, 0.7607843875885, 0.61960786581039, 1)
    optionsTab:SetHandler("OnMouseUp",function() APESO.UI.SetMenuTab("Options") end)


    local optionsContent = wm:CreateControl(nil, menu, CT_CONTROL)
    optionsContent:SetAnchor(TOPLEFT, tab, BOTTOMLEFT, 0, 0)
    optionsContent:SetAnchor(BOTTOMRIGHT, closeContainer, TOPRIGHT, 0, 0)
    APESO.UI.menuTabs["Options"] = optionsContent
    APESO.UI.CreateOptionsMenu(optionsContent, wm)
    optionsContent:SetHidden(true)
    
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

function APESO.UI.CreateItemsMenu(itemsContent, wm)
    local itemsWindow = wm:CreateControlFromVirtual(nil, itemsContent, "ZO_ScrollContainer")
    itemsWindow:SetAnchorFill()
    local scrollChild = itemsWindow:GetNamedChild("ScrollChild")
    local currLine = 20

    if APESOHelpers.GetOption("main_quests_enabled") == 1 then
        local MQItems = wm:CreateControl(nil, scrollChild, CT_LABEL)
        MQItems:SetHeight(20)
        MQItems:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 20, currLine)
        MQItems:SetText("Progressive Main Quests: "..APESO.ProgressiveMainQuest)
        MQItems:SetFont("ZoFontGame")
        currLine = currLine + 20
    end

    if not (APESOHelpers.GetOption("goldCap") == 0) then
        local goldItems = wm:CreateControl(nil, scrollChild, CT_LABEL)
        goldItems:SetHeight(20)
        goldItems:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 20, currLine)
        goldItems:SetText("Gold Limit: "..APESOHelpers.GetGoldCap())
        goldItems:SetFont("ZoFontGame")
        currLine = currLine + 20
    end

    local zoneItemsDropdown = wm:CreateControl(nil,scrollChild,CT_LABEL)
    zoneItemsDropdown:SetHeight(20)
    zoneItemsDropdown:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 20, currLine)
    zoneItemsDropdown:SetText("Zone Access Items (Click to toggle visibility)")
    zoneItemsDropdown:SetFont("ZoFontGameBold")
    zoneItemsDropdown:SetColor(0.77254909276962, 0.7607843875885, 0.61960786581039, 1)
    zoneItemsDropdown:SetMouseEnabled(true)
    local zoneItemsContainer = wm:CreateControl(nil,scrollChild,CT_CONTROL)
    zoneItemsContainer:SetAnchor(TOPLEFT, zoneItemsDropdown, BOTTOMLEFT, 20,0)
    local zoneHeight = 0

    local delveItemsDropdown = wm:CreateControl(nil,scrollChild,CT_LABEL)
    delveItemsDropdown:SetHeight(20)
    delveItemsDropdown:SetAnchor(TOPLEFT, zoneItemsDropdown, BOTTOMLEFT,0,0)
    delveItemsDropdown:SetText("Delve Access Items (Click to toggle visibility)")
    delveItemsDropdown:SetFont("ZoFontGameBold")
    delveItemsDropdown:SetColor(0.77254909276962, 0.7607843875885, 0.61960786581039, 1)
    delveItemsDropdown:SetMouseEnabled(true)
    local delveItemsContainer = wm:CreateControl(nil,scrollChild,CT_CONTROL)
    delveItemsContainer:SetAnchor(TOPLEFT, delveItemsDropdown, BOTTOMLEFT, 20, 0)
    local delveHeight = 0

    for id, _ in pairs(APESO.ZoneAccess) do
        zoneData = APESO_ZoneData[id]
        local zoneItem = nil
        if zoneData.type == "zone" then
            zoneItem = wm:CreateControl(nil, zoneItemsContainer, CT_LABEL)
            zoneItem:SetAnchor(TOPLEFT, zoneItemsContainer, TOPLEFT, 0, zoneHeight)
            zoneHeight = zoneHeight + 20
        else
            zoneItem = wm:CreateControl(nil, delveItemsContainer, CT_LABEL)
            zoneItem:SetAnchor(TOPLEFT, delveItemsContainer, TOPLEFT, 0, delveHeight)
            delveHeight = delveHeight + 20
        end
        zoneItem:SetHeight(20)
        zoneItem:SetText(zoneData.name.." Access")
        zoneItem:SetFont("ZoFontGame")
        
    end
    zoneItemsContainer:SetHeight(zoneHeight)
    zoneItemsContainer:SetHidden(true)
    zoneItemsDropdown:SetHandler("OnMouseUp",function() APESO.UI.ToggleZoneItemsContainer(zoneItemsContainer, delveItemsDropdown, zoneItemsDropdown) end)

    delveItemsContainer:SetHeight(delveHeight)
    delveItemsContainer:SetHidden(true)
    delveItemsDropdown:SetHandler("OnMouseUp",function() APESO.UI.ToggleDelveItemsContainer(delveItemsContainer) end)
end

function APESO.UI.ToggleZoneItemsContainer(zoneItemsContainer, delveItemsDropdown, zoneItemsDropdown)
    delveItemsDropdown:ClearAnchors()
    if zoneItemsContainer:IsHidden() then
        delveItemsDropdown:SetAnchor(TOPLEFT, zoneItemsContainer, BOTTOMLEFT, -20 , 0)
        zoneItemsContainer:SetHidden(false)
    else
        delveItemsDropdown:SetAnchor(TOPLEFT, zoneItemsDropdown, BOTTOMLEFT,0,0)
        zoneItemsContainer:SetHidden(true)
    end
end

function APESO.UI.ToggleDelveItemsContainer(delveItemsContainer)
    delveItemsContainer:SetHidden(not delveItemsContainer:IsHidden())
end
