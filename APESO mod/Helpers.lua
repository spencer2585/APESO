APESOHelpers = APESOHelpers or {}

--Checks if player has access to a zone
function APESOHelpers.CheckZoneAccess(zoneID)
    if APESO.ZoneAccess[zoneID] then
        return true
    else
        return false
    end
end

--checks if the player has the zone they are currently in
function APESOHelpers.CheckCurrentZone()
    local zoneIndex = GetZoneId(GetUnitZoneIndex("player"))
    return APESOHelpers.CheckZoneAccess(zoneIndex)
end

--return the value of the option in the options table
function APESOHelpers.GetOption(option)
    if APESO_options[option] ~= nil then
        return APESO_options[option]
    --error
    else
        --if debug mode is on then print error
        if APESO.DebugMode then
            d("Option ".. option .. " does not exist")
        end
        return 0
    end
end

function APESOHelpers.GetCurrentZone()
    return GetUnitZoneIndex("player")
end

function APESOHelpers.LockZone()
    APESO.UI.HideZoneWarning()
    local currZone = APESOHelpers.GetCurrentZone()
    local zoneData = APESO_ZoneData[3]
    if zoneData.type == "delve" and APESOHelpers("delvesEnabled") == 1 then
        if not APESO.CheckCurrentZone() then
            APESO.UI.ShowZoneWarning()
        end
    elseif zoneData.type == "zone" and not APESOHelpers.CheckCurrentZone() then
        APESO.UI.ShowZoneWarning()
    end
end