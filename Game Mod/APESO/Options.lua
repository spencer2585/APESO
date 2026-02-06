-- APESO Options
-- This file is populated by the client when connecting to the Archipelago server
-- Do not edit manually - values will be overwritten on connection

APESO_Options = {
    -- Skill randomization mode: 0=none, 1=skyshards, 2=items, 3=both
    SkillRandomization = 0,

    -- Enabled skill categories (set by the server based on player's yaml choices)
    -- Format: { ["Category Name"] = true/false }
    EnabledSkillCategories = {
        -- Class Skills (only player's chosen class will be enabled)
        ["Ardent Flame"] = false,
        ["Draconic Power"] = false,
        ["Earthen Heart"] = false,
        ["Dark Magic"] = false,
        ["Daedric Summoning"] = false,
        ["Storm Calling"] = false,
        ["Assassination"] = false,
        ["Shadow"] = false,
        ["Siphoning"] = false,
        ["Aedric Spear"] = false,
        ["Dawn's Wrath"] = false,
        ["Restoring Light"] = false,
        ["Winter's Embrace"] = false,
        ["Green Balance"] = false,
        ["Animal Companions"] = false,
        ["Grave Lord"] = false,
        ["Bone Tyrant"] = false,
        ["Living Death"] = false,
        ["Herald of the Tome"] = false,
        ["Soldier of Apocrypha"] = false,
        ["Curative Runeforms"] = false,

        -- Weapon Skills
        ["Two Handed"] = false,
        ["One Hand and Shield"] = false,
        ["Dual Wield"] = false,
        ["Bow"] = false,
        ["Destruction Staff"] = false,
        ["Restoration Staff"] = false,

        -- Armor Skills
        ["Light Armor"] = false,
        ["Medium Armor"] = false,
        ["Heavy Armor"] = false,

        -- Racial Skills (only player's chosen race will be enabled)
        ["Argonian"] = false,
        ["Breton"] = false,
        ["Dark Elf"] = false,
        ["High Elf"] = false,
        ["Imperial"] = false,
        ["Khajiit"] = false,
        ["Nord"] = false,
        ["Orc"] = false,
        ["Redguard"] = false,
        ["Wood Elf"] = false,

        -- World Skills
        ["Legerdemain"] = false,
        ["Lycanthropy"] = false,
        ["Soul Magic"] = false,
        ["Vampirism"] = false,

        -- Guild Skills
        ["Fighters Guild"] = false,
        ["Mages Guild"] = false,
    },

    -- Player's chosen class name (for display purposes)
    CharacterClass = "",

    -- Player's chosen race name (for display purposes)
    CharacterRace = "",
}

-- Function to update options from server data
function APESO_UpdateOptionsFromServer(slotData)
    if not slotData then return end

    if slotData.SkillRandomization ~= nil then
        APESO_Options.SkillRandomization = slotData.SkillRandomization
    end

    if slotData.CharacterClass then
        APESO_Options.CharacterClass = slotData.CharacterClass
    end

    if slotData.CharacterRace then
        APESO_Options.CharacterRace = slotData.CharacterRace
    end

    if slotData.EnabledSkillCategories then
        for category, enabled in pairs(slotData.EnabledSkillCategories) do
            APESO_Options.EnabledSkillCategories[category] = enabled
        end
    end

    -- Notify that options were updated
    if APESO and APESO.OnOptionsUpdated then
        APESO.OnOptionsUpdated()
    end
end

-- Helper function to check if a skill category is enabled
function APESO_IsSkillCategoryEnabled(categoryName)
    -- If skill randomization is disabled (mode 0), no categories are tracked
    if APESO_Options.SkillRandomization == 0 then
        return false
    end

    -- If skill randomization is skyshards only (mode 1), no item categories
    if APESO_Options.SkillRandomization == 1 then
        return false
    end

    -- For modes 2 (items) and 3 (both), check the enabled categories
    return APESO_Options.EnabledSkillCategories[categoryName] == true
end
