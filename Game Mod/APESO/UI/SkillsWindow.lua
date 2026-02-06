APESO.UI = APESO.UI or {}

-- Constants
local SKILL_UNLOCK_BASE_ID = 152100
local SKYSHARD_ITEM_ID = 149994
local SKYSHARDS_PER_POINT = 3

-- Skill categories and their ID ranges (matching Items.py)
local SKILL_CATEGORIES = {
    -- Class Skills - Dragonknight
    { name = "Ardent Flame", startOffset = 0, endOffset = 18 },
    { name = "Draconic Power", startOffset = 19, endOffset = 40 },
    { name = "Earthen Heart", startOffset = 41, endOffset = 62 },
    -- Class Skills - Sorcerer
    { name = "Dark Magic", startOffset = 63, endOffset = 84 },
    { name = "Daedric Summoning", startOffset = 85, endOffset = 106 },
    { name = "Storm Calling", startOffset = 107, endOffset = 128 },
    -- Class Skills - Nightblade
    { name = "Assassination", startOffset = 129, endOffset = 150 },
    { name = "Shadow", startOffset = 151, endOffset = 172 },
    { name = "Siphoning", startOffset = 173, endOffset = 194 },
    -- Class Skills - Templar
    { name = "Aedric Spear", startOffset = 195, endOffset = 216 },
    { name = "Dawn's Wrath", startOffset = 217, endOffset = 238 },
    { name = "Restoring Light", startOffset = 239, endOffset = 259 },
    -- Class Skills - Warden
    { name = "Winter's Embrace", startOffset = 260, endOffset = 281 },
    { name = "Green Balance", startOffset = 282, endOffset = 303 },
    { name = "Animal Companions", startOffset = 304, endOffset = 325 },
    -- Class Skills - Necromancer
    { name = "Grave Lord", startOffset = 326, endOffset = 347 },
    { name = "Bone Tyrant", startOffset = 348, endOffset = 369 },
    { name = "Living Death", startOffset = 370, endOffset = 391 },
    -- Class Skills - Arcanist
    { name = "Herald of the Tome", startOffset = 392, endOffset = 413 },
    { name = "Soldier of Apocrypha", startOffset = 414, endOffset = 435 },
    { name = "Curative Runeforms", startOffset = 436, endOffset = 457 },
    -- Weapon Skills
    { name = "Two Handed", startOffset = 458, endOffset = 480 },
    { name = "One Hand and Shield", startOffset = 481, endOffset = 503 },
    { name = "Dual Wield", startOffset = 504, endOffset = 526 },
    { name = "Bow", startOffset = 527, endOffset = 549 },
    { name = "Destruction Staff", startOffset = 550, endOffset = 572 },
    { name = "Restoration Staff", startOffset = 573, endOffset = 595 },
    -- Armor Skills
    { name = "Light Armor", startOffset = 596, endOffset = 603 },
    { name = "Medium Armor", startOffset = 604, endOffset = 611 },
    { name = "Heavy Armor", startOffset = 612, endOffset = 619 },
    -- Racial Skills
    { name = "Argonian", startOffset = 620, endOffset = 623 },
    { name = "Breton", startOffset = 624, endOffset = 627 },
    { name = "Dark Elf", startOffset = 628, endOffset = 631 },
    { name = "High Elf", startOffset = 632, endOffset = 635 },
    { name = "Imperial", startOffset = 636, endOffset = 639 },
    { name = "Khajiit", startOffset = 640, endOffset = 643 },
    { name = "Nord", startOffset = 644, endOffset = 647 },
    { name = "Orc", startOffset = 648, endOffset = 651 },
    { name = "Redguard", startOffset = 652, endOffset = 655 },
    { name = "Wood Elf", startOffset = 656, endOffset = 659 },
    -- World Skills
    { name = "Legerdemain", startOffset = 660, endOffset = 664 },
    { name = "Lycanthropy", startOffset = 665, endOffset = 688 },
    { name = "Soul Magic", startOffset = 689, endOffset = 697 },
    { name = "Vampirism", startOffset = 698, endOffset = 721 },
    -- Guild Skills
    { name = "Fighters Guild", startOffset = 720, endOffset = 739 },
    { name = "Mages Guild", startOffset = 740, endOffset = 759 },
}

-- ============================================================
-- AP Skill Point System
-- ============================================================

-- Count total Skyshards received from AP
function APESO.CountReceivedSkyshards()
    local count = 0
    for _, entry in ipairs(APESO_ReceivedItems or {}) do
        if entry.item_id == SKYSHARD_ITEM_ID then
            count = count + 1
        end
    end
    return count
end

-- Count skills the player has already unlocked (spent points on)
function APESO.CountSpentSkillPoints()
    local unlocked = APESO.savedVariables and APESO.savedVariables.UnlockedSkills or {}
    local count = 0
    for _ in pairs(unlocked) do
        count = count + 1
    end
    return count
end

-- Get available AP Skill Points
function APESO.GetAvailableAPSkillPoints()
    local totalShards = APESO.CountReceivedSkyshards()
    local totalPoints = math.floor(totalShards / SKYSHARDS_PER_POINT)
    local spent = APESO.CountSpentSkillPoints()
    return totalPoints - spent, totalPoints, spent, totalShards
end

-- Check if a specific skill offset has been unlocked by the player
function APESO.IsSkillUnlocked(offset)
    if not APESO.savedVariables or not APESO.savedVariables.UnlockedSkills then
        return false
    end
    return APESO.savedVariables.UnlockedSkills[offset] == true
end

-- Check if the AP item for this skill has been received
function APESO.HasSkillItem(offset)
    local itemId = SKILL_UNLOCK_BASE_ID + offset
    for _, entry in ipairs(APESO_ReceivedItems or {}) do
        if entry.item_id == itemId then
            return true
        end
    end
    return false
end

-- Get the parent (base skill) offset for a morph skill
-- Returns nil if the skill is not a morph
function APESO.GetMorphParentOffset(categoryName, offset)
    local skills = APESO_SkillData and APESO_SkillData.Categories and APESO_SkillData.Categories[categoryName]
    if not skills then return nil end

    -- Find this skill in the list
    for i, skill in ipairs(skills) do
        if skill.offset == offset and skill.morph then
            -- Walk backwards to find the base skill (first non-morph before this)
            for j = i - 1, 1, -1 do
                if not skills[j].morph then
                    return skills[j].offset
                end
            end
        end
    end
    return nil
end

-- Check why a skill can't be unlocked
-- Returns: canUnlock (bool), reason (string)
function APESO.CanUnlockSkill(categoryName, offset)
    -- Already unlocked
    if APESO.IsSkillUnlocked(offset) then
        return false, "Already unlocked"
    end

    -- Check if AP item received
    if not APESO.HasSkillItem(offset) then
        return false, "Item not received from AP"
    end

    -- Check AP skill points
    local available = APESO.GetAvailableAPSkillPoints()
    if available <= 0 then
        return false, "No AP Skill Points (need more Skyshards)"
    end

    -- Check morph prerequisite
    local parentOffset = APESO.GetMorphParentOffset(categoryName, offset)
    if parentOffset and not APESO.IsSkillUnlocked(parentOffset) then
        -- Find parent name for display
        local skills = APESO_SkillData.Categories[categoryName]
        local parentName = "base skill"
        for _, s in ipairs(skills) do
            if s.offset == parentOffset then
                parentName = s.name
                break
            end
        end
        return false, "Unlock \"" .. parentName .. "\" first"
    end

    return true, nil
end

-- Unlock a skill (spend an AP skill point)
function APESO.UnlockSkill(categoryName, offset)
    local canUnlock, reason = APESO.CanUnlockSkill(categoryName, offset)
    if not canUnlock then
        d("|cFF4444APESO: Cannot unlock - " .. reason .. "|r")
        return false
    end

    if not APESO.savedVariables.UnlockedSkills then
        APESO.savedVariables.UnlockedSkills = {}
    end

    APESO.savedVariables.UnlockedSkills[offset] = true

    -- Find skill name for confirmation
    local skillName = "Skill"
    local skills = APESO_SkillData and APESO_SkillData.Categories and APESO_SkillData.Categories[categoryName]
    if skills then
        for _, s in ipairs(skills) do
            if s.offset == offset then
                skillName = s.name
                break
            end
        end
    end

    local available = APESO.GetAvailableAPSkillPoints()
    d("|c44FF44APESO: Unlocked " .. skillName .. "! (" .. available .. " AP Skill Points remaining)|r")
    return true
end

-- ============================================================
-- Get all received skill unlock item IDs (set lookup)
-- ============================================================
function APESO.GetReceivedSkillUnlocks()
    local unlocks = {}
    for _, entry in ipairs(APESO_ReceivedItems or {}) do
        local itemId = entry.item_id
        if itemId and itemId >= SKILL_UNLOCK_BASE_ID and itemId < SKILL_UNLOCK_BASE_ID + 1000 then
            unlocks[itemId] = true
        end
    end
    return unlocks
end

-- Count unlocks per category (AP items received, not player-unlocked)
function APESO.CountSkillUnlocksPerCategory()
    local unlocks = APESO.GetReceivedSkillUnlocks()
    local counts = {}
    for _, category in ipairs(SKILL_CATEGORIES) do
        local received = 0
        local playerUnlocked = 0
        local total = 0
        local skills = APESO_SkillData and APESO_SkillData.Categories and APESO_SkillData.Categories[category.name]
        if skills then
            total = #skills
            for _, skill in ipairs(skills) do
                local itemId = SKILL_UNLOCK_BASE_ID + skill.offset
                if unlocks[itemId] then
                    received = received + 1
                end
                if APESO.IsSkillUnlocked(skill.offset) then
                    playerUnlocked = playerUnlocked + 1
                end
            end
        else
            total = category.endOffset - category.startOffset + 1
            for offset = category.startOffset, category.endOffset do
                local itemId = SKILL_UNLOCK_BASE_ID + offset
                if unlocks[itemId] then
                    received = received + 1
                end
            end
        end
        counts[category.name] = { received = received, unlocked = playerUnlocked, total = total }
    end
    return counts
end

-- ============================================================
-- Window State
-- ============================================================
APESO.SkillsWindow = nil
APESO.SkillsWindowScrollChild = nil
APESO.SkillsWindowScrollContainer = nil
APESO.SkillEntries = APESO.SkillEntries or {}
APESO.SkillDetailEntries = APESO.SkillDetailEntries or {}
APESO.CurrentSkillView = "categories" -- "categories" or "detail"
APESO.CurrentDetailCategory = nil

-- ============================================================
-- Window Creation
-- ============================================================
function APESO.UI.CreateSkillsWindow()
    if APESO.SkillsWindow then
        return APESO.SkillsWindow
    end

    local wm = WINDOW_MANAGER

    -- Main window
    local win = wm:CreateTopLevelWindow("APESOSkillsWindow")
    win:SetDimensions(520, 640)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetHidden(true)
    win:SetClampedToScreen(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)

    -- Background
    local bg = wm:CreateControl("$(parent)BG", win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.9)
    bg:SetEdgeColor(0.9, 0.9, 0.65, 1)
    bg:SetEdgeTexture("", 1, 1, 1)

    -- Title bar background
    local titleBg = wm:CreateControl("$(parent)TitleBG", win, CT_BACKDROP)
    titleBg:SetDimensions(520, 40)
    titleBg:SetAnchor(TOP, win, TOP, 0, 0)
    titleBg:SetCenterColor(0.05, 0.05, 0.1, 1)
    titleBg:SetEdgeColor(0.9, 0.9, 0.65, 1)

    -- Title label
    local title = wm:CreateControl("$(parent)Title", win, CT_LABEL)
    title:SetAnchor(TOP, win, TOP, 0, 8)
    title:SetFont("ZoFontWinH1")
    title:SetColor(0.9, 0.9, 0.65, 1)
    title:SetText("Archipelago Skills")
    APESO.SkillsWindowTitle = title

    -- Close button
    local closeBtn = wm:CreateControlFromVirtual("$(parent)CloseBtn", win, "ZO_CloseButton")
    closeBtn:SetAnchor(TOPRIGHT, win, TOPRIGHT, -5, 5)
    closeBtn:SetHandler("OnClicked", function()
        APESO.HideSkillsWindow()
    end)

    -- Back button (hidden by default, shown in detail view)
    local backBtn = wm:CreateControlFromVirtual("$(parent)BackBtn", win, "ZO_DefaultButton")
    backBtn:SetDimensions(80, 30)
    backBtn:SetAnchor(TOPLEFT, win, TOPLEFT, 8, 6)
    backBtn:SetText("< Back")
    backBtn:SetHidden(true)
    backBtn:SetHandler("OnClicked", function()
        APESO.ShowCategoryList()
    end)
    APESO.SkillsBackBtn = backBtn

    -- AP Skill Points header bar
    local pointsBar = wm:CreateControl("$(parent)PointsBar", win, CT_BACKDROP)
    pointsBar:SetDimensions(500, 28)
    pointsBar:SetAnchor(TOP, win, TOP, 0, 42)
    pointsBar:SetCenterColor(0.1, 0.1, 0.15, 1)
    pointsBar:SetEdgeColor(0.5, 0.5, 0.4, 1)
    pointsBar:SetEdgeTexture("", 1, 1, 1)

    local pointsLabel = wm:CreateControl("$(parent)PointsLabel", pointsBar, CT_LABEL)
    pointsLabel:SetAnchor(CENTER, pointsBar, CENTER, 0, 0)
    pointsLabel:SetFont("ZoFontGameBold")
    pointsLabel:SetColor(0.9, 0.9, 0.65, 1)
    APESO.SkillPointsLabel = pointsLabel

    -- Scroll container
    local scrollContainer = wm:CreateControlFromVirtual("$(parent)Scroll", win, "ZO_ScrollContainer")
    scrollContainer:SetAnchor(TOPLEFT, win, TOPLEFT, 10, 74)
    scrollContainer:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -10, -10)

    local scrollChild = scrollContainer:GetNamedChild("ScrollChild")
    scrollChild:SetWidth(480)

    APESO.SkillsWindow = win
    APESO.SkillsWindowScrollChild = scrollChild
    APESO.SkillsWindowScrollContainer = scrollContainer

    return win
end

-- ============================================================
-- Update the skill points display
-- ============================================================
function APESO.UpdateSkillPointsDisplay()
    if not APESO.SkillPointsLabel then return end
    local available, total, spent, shards = APESO.GetAvailableAPSkillPoints()
    local nextShard = SKYSHARDS_PER_POINT - (shards % SKYSHARDS_PER_POINT)
    if nextShard == SKYSHARDS_PER_POINT and shards > 0 then nextShard = 0 end

    local text = string.format("AP Skill Points: |c44FF44%d|r  |c888888(Skyshards: %d  |  Next point in: %d)|r", available, shards, nextShard)
    APESO.SkillPointsLabel:SetText(text)
end

-- ============================================================
-- Hide all entries in a given table
-- ============================================================
local function HideEntries(entries)
    for _, entry in pairs(entries) do
        if entry and entry.SetHidden then
            entry:SetHidden(true)
        end
    end
end

-- ============================================================
-- CATEGORY LIST VIEW
-- ============================================================
function APESO.ShowCategoryList()
    APESO.CurrentSkillView = "categories"
    APESO.CurrentDetailCategory = nil

    -- Update title
    if APESO.SkillsWindowTitle then
        APESO.SkillsWindowTitle:SetText("Archipelago Skills")
    end

    -- Hide back button
    if APESO.SkillsBackBtn then
        APESO.SkillsBackBtn:SetHidden(true)
    end

    -- Hide detail entries
    HideEntries(APESO.SkillDetailEntries)

    -- Refresh category list
    APESO.RefreshCategoryList()
end

function APESO.RefreshCategoryList()
    if not APESO.SkillsWindowScrollChild then return end

    local wm = WINDOW_MANAGER
    local scrollChild = APESO.SkillsWindowScrollChild

    -- Hide existing category entries
    HideEntries(APESO.SkillEntries)

    -- Update points display
    APESO.UpdateSkillPointsDisplay()

    -- Check skill mode
    local skillMode = APESO_Options and APESO_Options.SkillRandomization or 0
    local showSkills = (skillMode == 2 or skillMode == 3)

    local yOffset = 5
    local entryHeight = 32

    -- Class/Race header
    if showSkills then
        local headerName = "APESOCat_Header"
        local header = wm:GetControlByName(headerName) or wm:CreateControl(headerName, scrollChild, CT_LABEL)
        header:ClearAnchors()
        header:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10, yOffset)
        header:SetFont("ZoFontGameBold")
        local className = APESO_Options.CharacterClass or "Unknown"
        local raceName = APESO_Options.CharacterRace or "Unknown"
        header:SetText(string.format("Class: |cFFCC44%s|r  |c888888|||r  Race: |cFFCC44%s|r", className, raceName))
        header:SetColor(0.8, 0.8, 0.8, 1)
        header:SetHidden(false)
        APESO.SkillEntries[headerName] = header
        yOffset = yOffset + 30
    end

    -- Disabled message
    if not showSkills then
        local msgName = "APESOCat_Disabled"
        local msg = wm:GetControlByName(msgName) or wm:CreateControl(msgName, scrollChild, CT_LABEL)
        msg:ClearAnchors()
        msg:SetAnchor(TOP, scrollChild, TOP, 0, 50)
        msg:SetFont("ZoFontWinH2")
        msg:SetText("Skill randomization is not enabled\nfor this session.")
        msg:SetColor(0.7, 0.7, 0.7, 1)
        msg:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        msg:SetHidden(false)
        APESO.SkillEntries[msgName] = msg
        scrollChild:SetHeight(150)
        return
    end

    -- Get counts
    local counts = APESO.CountSkillUnlocksPerCategory()

    for _, category in ipairs(SKILL_CATEGORIES) do
        local isEnabled = APESO_Options and APESO_Options.EnabledSkillCategories
            and APESO_Options.EnabledSkillCategories[category.name]

        local countData = counts[category.name]
        if countData and isEnabled then
            local safeName = string.gsub(category.name, "[%s']", "_")
            local entryName = "APESOCat_" .. safeName

            -- Row container (clickable)
            local entry = wm:GetControlByName(entryName) or wm:CreateControl(entryName, scrollChild, CT_CONTROL)
            entry:SetDimensions(480, entryHeight)
            entry:ClearAnchors()
            entry:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
            entry:SetMouseEnabled(true)
            entry:SetHidden(false)
            APESO.SkillEntries[entryName] = entry

            -- Hover highlight backdrop
            local hoverBg = wm:GetControlByName(entryName .. "_HBG") or wm:CreateControl(entryName .. "_HBG", entry, CT_BACKDROP)
            hoverBg:SetAnchorFill()
            hoverBg:SetCenterColor(0.3, 0.3, 0.2, 0)
            hoverBg:SetEdgeColor(0, 0, 0, 0)
            hoverBg:SetHidden(false)

            -- Click handler
            local catName = category.name
            entry:SetHandler("OnMouseUp", function(control, button)
                if button == MOUSE_BUTTON_INDEX_LEFT then
                    APESO.ShowSkillDetail(catName)
                end
            end)
            entry:SetHandler("OnMouseEnter", function()
                hoverBg:SetCenterColor(0.3, 0.3, 0.2, 0.3)
            end)
            entry:SetHandler("OnMouseExit", function()
                hoverBg:SetCenterColor(0.3, 0.3, 0.2, 0)
            end)

            -- Category name label
            local nameLabel = wm:GetControlByName(entryName .. "_Name") or wm:CreateControl(entryName .. "_Name", entry, CT_LABEL)
            nameLabel:ClearAnchors()
            nameLabel:SetAnchor(LEFT, entry, LEFT, 12, 0)
            nameLabel:SetFont("ZoFontGame")
            nameLabel:SetText(category.name)
            nameLabel:SetColor(0.9, 0.85, 0.7, 1)
            nameLabel:SetMouseEnabled(false)
            nameLabel:SetHidden(false)

            -- Arrow indicator
            local arrow = wm:GetControlByName(entryName .. "_Arrow") or wm:CreateControl(entryName .. "_Arrow", entry, CT_LABEL)
            arrow:ClearAnchors()
            arrow:SetAnchor(RIGHT, entry, RIGHT, -8, 0)
            arrow:SetFont("ZoFontGame")
            arrow:SetText(">")
            arrow:SetColor(0.6, 0.6, 0.5, 1)
            arrow:SetMouseEnabled(false)
            arrow:SetHidden(false)

            -- Progress text: "unlocked/received/total"
            local progressLabel = wm:GetControlByName(entryName .. "_Prog") or wm:CreateControl(entryName .. "_Prog", entry, CT_LABEL)
            progressLabel:ClearAnchors()
            progressLabel:SetAnchor(RIGHT, arrow, LEFT, -12, 0)
            progressLabel:SetFont("ZoFontGame")
            progressLabel:SetMouseEnabled(false)
            progressLabel:SetHidden(false)

            local progText = string.format("%d / %d / %d", countData.unlocked, countData.received, countData.total)
            if countData.unlocked == countData.total then
                progressLabel:SetColor(0.2, 1, 0.2, 1)
            elseif countData.unlocked > 0 then
                progressLabel:SetColor(1, 0.8, 0.2, 1)
            elseif countData.received > 0 then
                progressLabel:SetColor(0.5, 0.7, 1, 1)
            else
                progressLabel:SetColor(0.5, 0.5, 0.5, 1)
            end
            progressLabel:SetText(progText)

            -- Progress bar
            local barBg = wm:GetControlByName(entryName .. "_BarBG") or wm:CreateControl(entryName .. "_BarBG", entry, CT_BACKDROP)
            barBg:SetDimensions(120, 6)
            barBg:ClearAnchors()
            barBg:SetAnchor(RIGHT, progressLabel, LEFT, -10, 0)
            barBg:SetCenterColor(0.15, 0.15, 0.15, 1)
            barBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
            barBg:SetMouseEnabled(false)
            barBg:SetHidden(false)

            -- Bar fill (based on player-unlocked / total)
            local barFill = wm:GetControlByName(entryName .. "_BarFill") or wm:CreateControl(entryName .. "_BarFill", barBg, CT_BACKDROP)
            local fillWidth = countData.total > 0 and math.max(1, math.floor(118 * countData.unlocked / countData.total)) or 1
            barFill:SetDimensions(fillWidth, 4)
            barFill:ClearAnchors()
            barFill:SetAnchor(LEFT, barBg, LEFT, 1, 0)
            barFill:SetEdgeColor(0, 0, 0, 0)
            barFill:SetMouseEnabled(false)
            barFill:SetHidden(false)

            if countData.unlocked == countData.total then
                barFill:SetCenterColor(0.2, 0.8, 0.2, 1)
            elseif countData.unlocked > 0 then
                barFill:SetCenterColor(0.8, 0.6, 0.1, 1)
            else
                barFill:SetCenterColor(0.3, 0.3, 0.3, 1)
            end

            yOffset = yOffset + entryHeight
        end
    end

    -- Legend at bottom
    local legendName = "APESOCat_Legend"
    local legend = wm:GetControlByName(legendName) or wm:CreateControl(legendName, scrollChild, CT_LABEL)
    legend:ClearAnchors()
    legend:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 12, yOffset + 8)
    legend:SetFont("ZoFontGameSmall")
    legend:SetText("|c888888Progress: Unlocked / Items Received / Total|r")
    legend:SetHidden(false)
    APESO.SkillEntries[legendName] = legend

    scrollChild:SetHeight(yOffset + 35)
end

-- ============================================================
-- SKILL DETAIL VIEW
-- ============================================================
function APESO.ShowSkillDetail(categoryName)
    APESO.CurrentSkillView = "detail"
    APESO.CurrentDetailCategory = categoryName

    -- Update title
    if APESO.SkillsWindowTitle then
        APESO.SkillsWindowTitle:SetText(categoryName)
    end

    -- Show back button
    if APESO.SkillsBackBtn then
        APESO.SkillsBackBtn:SetHidden(false)
    end

    -- Hide category entries
    HideEntries(APESO.SkillEntries)

    -- Refresh detail
    APESO.RefreshSkillDetail(categoryName)
end

function APESO.RefreshSkillDetail(categoryName)
    if not APESO.SkillsWindowScrollChild then return end
    if not APESO_SkillData or not APESO_SkillData.Categories then return end

    local skills = APESO_SkillData.Categories[categoryName]
    if not skills then return end

    local wm = WINDOW_MANAGER
    local scrollChild = APESO.SkillsWindowScrollChild

    -- Hide existing detail entries
    HideEntries(APESO.SkillDetailEntries)

    -- Update points display
    APESO.UpdateSkillPointsDisplay()

    local yOffset = 5
    local ROW_HEIGHT = 36

    for i, skill in ipairs(skills) do
        local safeName = string.gsub(categoryName .. "_" .. skill.name, "[%s'\":]", "_")
        local entryName = "APESODetail_" .. safeName

        local hasItem = APESO.HasSkillItem(skill.offset)
        local isUnlocked = APESO.IsSkillUnlocked(skill.offset)
        local canUnlock, reason = APESO.CanUnlockSkill(categoryName, skill.offset)

        -- Row container
        local row = wm:GetControlByName(entryName) or wm:CreateControl(entryName, scrollChild, CT_CONTROL)
        row:SetDimensions(480, ROW_HEIGHT)
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
        row:SetMouseEnabled(true)
        row:SetHidden(false)
        APESO.SkillDetailEntries[entryName] = row

        -- Row background (subtle alternating)
        local rowBg = wm:GetControlByName(entryName .. "_BG") or wm:CreateControl(entryName .. "_BG", row, CT_BACKDROP)
        rowBg:SetAnchorFill()
        rowBg:SetEdgeColor(0, 0, 0, 0)
        rowBg:SetMouseEnabled(false)
        rowBg:SetHidden(false)
        if i % 2 == 0 then
            rowBg:SetCenterColor(0.12, 0.12, 0.12, 0.5)
        else
            rowBg:SetCenterColor(0, 0, 0, 0)
        end

        -- Indent morphs
        local indent = 0
        if skill.morph then
            indent = 20
        end

        -- Type tag
        local tagName = entryName .. "_Tag"
        local tag = wm:GetControlByName(tagName) or wm:CreateControl(tagName, row, CT_LABEL)
        tag:ClearAnchors()
        tag:SetAnchor(LEFT, row, LEFT, 6 + indent, 0)
        tag:SetFont("ZoFontGameSmall")
        tag:SetMouseEnabled(false)
        tag:SetHidden(false)

        if skill.ultimate then
            tag:SetText("[ULT]")
            tag:SetColor(0.9, 0.5, 0.1, 1)
        elseif skill.morph then
            tag:SetText("[M]")
            tag:SetColor(0.6, 0.6, 0.9, 1)
        elseif skill.passive then
            tag:SetText("[P]")
            tag:SetColor(0.5, 0.8, 0.5, 1)
        else
            tag:SetText("[A]")
            tag:SetColor(0.8, 0.8, 0.5, 1)
        end

        -- Skill name label
        local nameLbl = wm:GetControlByName(entryName .. "_Name") or wm:CreateControl(entryName .. "_Name", row, CT_LABEL)
        nameLbl:ClearAnchors()
        nameLbl:SetAnchor(LEFT, tag, RIGHT, 6, 0)
        nameLbl:SetFont("ZoFontGame")
        nameLbl:SetMouseEnabled(false)
        nameLbl:SetHidden(false)
        nameLbl:SetText(skill.name)

        if isUnlocked then
            nameLbl:SetColor(0.3, 1, 0.3, 1)
        elseif hasItem then
            nameLbl:SetColor(0.9, 0.85, 0.7, 1)
        else
            nameLbl:SetColor(0.45, 0.45, 0.45, 1)
        end

        -- Status / action area (right side)
        local statusName = entryName .. "_Status"
        local statusLbl = wm:GetControlByName(statusName) or wm:CreateControl(statusName, row, CT_LABEL)
        statusLbl:ClearAnchors()
        statusLbl:SetFont("ZoFontGameSmall")
        statusLbl:SetMouseEnabled(false)
        statusLbl:SetHidden(false)

        -- Unlock button
        local btnName = entryName .. "_Btn"
        local btn = wm:GetControlByName(btnName)
        if not btn then
            btn = wm:CreateControl(btnName, row, CT_CONTROL)
            btn:SetDimensions(70, 24)
            btn:SetMouseEnabled(true)

            local btnBg = wm:CreateControl(btnName .. "_BG", btn, CT_BACKDROP)
            btnBg:SetAnchorFill()
            btnBg:SetEdgeColor(0.6, 0.6, 0.4, 1)
            btnBg:SetEdgeTexture("", 1, 1, 1)

            local btnLbl = wm:CreateControl(btnName .. "_Lbl", btn, CT_LABEL)
            btnLbl:SetAnchor(CENTER, btn, CENTER, 0, 0)
            btnLbl:SetFont("ZoFontGameSmall")
            btnLbl:SetText("Unlock")
            btnLbl:SetColor(0.9, 0.9, 0.65, 1)
            btnLbl:SetMouseEnabled(false)
        end

        local btnBg = wm:GetControlByName(btnName .. "_BG")
        btn:ClearAnchors()
        btn:SetAnchor(RIGHT, row, RIGHT, -8, 0)
        btn:SetHidden(true)
        APESO.SkillDetailEntries[btnName] = btn

        statusLbl:SetAnchor(RIGHT, row, RIGHT, -8, 0)

        if isUnlocked then
            -- Already unlocked
            statusLbl:SetText("Unlocked")
            statusLbl:SetColor(0.3, 1, 0.3, 1)
            btn:SetHidden(true)
        elseif canUnlock then
            -- Can unlock - show button
            statusLbl:SetHidden(true)
            btn:SetHidden(false)
            if btnBg then
                btnBg:SetCenterColor(0.15, 0.3, 0.15, 1)
            end

            -- Wire up click
            local skillOffset = skill.offset
            local catName = categoryName
            btn:SetHandler("OnMouseUp", function(control, button)
                if button == MOUSE_BUTTON_INDEX_LEFT then
                    if APESO.UnlockSkill(catName, skillOffset) then
                        APESO.RefreshSkillDetail(catName)
                    end
                end
            end)
            btn:SetHandler("OnMouseEnter", function()
                if btnBg then btnBg:SetCenterColor(0.2, 0.4, 0.2, 1) end
            end)
            btn:SetHandler("OnMouseExit", function()
                if btnBg then btnBg:SetCenterColor(0.15, 0.3, 0.15, 1) end
            end)

            statusLbl:SetAnchor(RIGHT, btn, LEFT, -6, 0)
            statusLbl:SetText("")
            statusLbl:SetHidden(true)
        else
            -- Cannot unlock - show reason
            btn:SetHidden(true)
            statusLbl:SetHidden(false)
            if not hasItem then
                statusLbl:SetText("No AP Item")
                statusLbl:SetColor(0.5, 0.5, 0.5, 1)
            else
                -- Has item but can't unlock (no points, or need parent)
                statusLbl:SetText(reason or "Locked")
                statusLbl:SetColor(0.9, 0.5, 0.2, 1)
            end
        end

        yOffset = yOffset + ROW_HEIGHT
    end

    -- Legend
    local legendName = "APESODetail_Legend"
    local legend = wm:GetControlByName(legendName) or wm:CreateControl(legendName, scrollChild, CT_LABEL)
    legend:ClearAnchors()
    legend:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 6, yOffset + 8)
    legend:SetFont("ZoFontGameSmall")
    legend:SetText("|c888888[ULT] Ultimate  [A] Active  [M] Morph  [P] Passive|r")
    legend:SetHidden(false)
    APESO.SkillDetailEntries[legendName] = legend

    scrollChild:SetHeight(yOffset + 35)
end

-- ============================================================
-- Refresh the current view (whichever is active)
-- ============================================================
function APESO.RefreshSkillsWindow()
    if APESO.CurrentSkillView == "detail" and APESO.CurrentDetailCategory then
        APESO.RefreshSkillDetail(APESO.CurrentDetailCategory)
    else
        APESO.RefreshCategoryList()
    end
end

-- ============================================================
-- Show / Hide / Toggle
-- ============================================================
function APESO.ShowSkillsWindow()
    if not APESO.SkillsWindow then
        APESO.UI.CreateSkillsWindow()
    end

    APESO.CurrentSkillView = "categories"
    APESO.CurrentDetailCategory = nil
    if APESO.SkillsBackBtn then
        APESO.SkillsBackBtn:SetHidden(true)
    end
    if APESO.SkillsWindowTitle then
        APESO.SkillsWindowTitle:SetText("Archipelago Skills")
    end

    HideEntries(APESO.SkillDetailEntries)
    APESO.RefreshCategoryList()
    APESO.SkillsWindow:SetHidden(false)
    SetGameCameraUIMode(true)
end

function APESO.HideSkillsWindow()
    if APESO.SkillsWindow then
        APESO.SkillsWindow:SetHidden(true)
    end
end

function APESO.ToggleSkillsWindow()
    if APESO.SkillsWindow and not APESO.SkillsWindow:IsHidden() then
        APESO.HideSkillsWindow()
    else
        APESO.ShowSkillsWindow()
    end
end
