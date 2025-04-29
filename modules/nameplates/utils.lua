local _, VUI = ...
local Nameplates = VUI.nameplates

-- Utility functions for VUI Plater
Nameplates.utils = {}
local Utils = Nameplates.utils

-- Format a number with commas
function Utils:FormatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return number
    end
end

-- Get the proper color for a unit's health based on class, reaction, and settings
function Utils:GetHealthColor(unit, unitFrame)
    -- If unit is a player and class colors are enabled
    if UnitIsPlayer(unit) and Nameplates.settings.showClassColors then
        local _, class = UnitClass(unit)
        if class and RAID_CLASS_COLORS[class] then
            return RAID_CLASS_COLORS[class]
        end
    end
    
    -- If unit is hostile
    if UnitReaction(unit, "player") <= 4 then
        -- Check if we should apply threat coloring
        if Nameplates.settings.showThreatIndicator then
            local isTanking, status, threatPct = UnitDetailedThreatSituation("player", unit)
            
            -- Adjust threat coloring based on role (tank vs non-tank)
            local role = GetSpecializationRole(GetSpecialization()) 
            if role == "TANK" and Nameplates.settings.tankMode then
                if status == 3 then
                    return {r = 0.0, g = 0.8, b = 0.0} -- Solid aggro - green
                elseif status == 2 then
                    return {r = 0.8, g = 0.8, b = 0.0} -- Insecure aggro - yellow
                else
                    return {r = 0.8, g = 0.0, b = 0.0} -- No aggro - red
                end
            else
                if status == 3 then
                    return {r = 0.8, g = 0.0, b = 0.0} -- Solid aggro - red
                elseif status == 2 then
                    return {r = 0.8, g = 0.8, b = 0.0} -- Insecure aggro - yellow
                elseif status == 1 then
                    return {r = 1.0, g = 0.5, b = 0.0} -- Higher threat - orange
                else
                    return {r = 0.0, g = 0.8, b = 0.0} -- Low threat - green
                end
            end
        else
            -- Standard hostile color if threat indicators disabled
            return {r = 0.8, g = 0.1, b = 0.1} -- Red for enemies
        end
    end
    
    -- For friendly NPCs
    if not UnitIsPlayer(unit) and UnitReaction(unit, "player") > 4 then
        return {r = 0.0, g = 0.8, b = 0.1} -- Green for friendly NPCs
    end
    
    -- Default color (for neutrals, etc)
    return {r = 0.8, g = 0.8, b = 0.0} -- Yellow for neutral
end

-- Check if a unit is in execute range
function Utils:IsInExecuteRange(unit)
    if not Nameplates.settings.showExecuteIndicator then
        return false
    end
    
    local healthPct = UnitHealth(unit) / UnitHealthMax(unit) * 100
    if healthPct <= Nameplates.settings.executeThreshold then
        return true
    end
    
    return false
end

-- Get cast bar color based on interruptible status
function Utils:GetCastBarColor(unit, interruptible)
    if not interruptible then
        return Nameplates.settings.nonInterruptibleColor
    end
    return Nameplates.settings.castBarColor
end

-- Apply current VUI theme colors to nameplate elements
function Utils:ApplyThemeColors(element, elementType)
    if not Nameplates.settings.useThemeColors then
        return -- Only proceed if theme colors are enabled
    end
    
    local theme = VUI.db.profile.core.theme or "thunderstorm"
    local themeColors = {
        phoenixflame = {
            healthBar = {r = 0.9, g = 0.3, b = 0.0},
            castBar = {r = 0.9, g = 0.5, b = 0.2},
            border = {r = 0.9, g = 0.3, b = 0.0},
            background = {r = 0.1, g = 0.03, b = 0.01, a = 0.8},
            glow = {r = 1.0, g = 0.6, b = 0.0},
            highlight = {r = 1.0, g = 0.8, b = 0.4, a = 0.2},
        },
        thunderstorm = {
            healthBar = {r = 0.0, g = 0.6, b = 0.9},
            castBar = {r = 0.2, g = 0.4, b = 0.8},
            border = {r = 0.0, g = 0.6, b = 0.9},
            background = {r = 0.03, g = 0.05, g = 0.1, a = 0.8},
            glow = {r = 0.4, g = 0.8, b = 1.0},
            highlight = {r = 0.5, g = 0.7, b = 1.0, a = 0.2},
        },
        arcanemystic = {
            healthBar = {r = 0.6, g = 0.2, b = 0.8},
            castBar = {r = 0.7, g = 0.3, b = 0.9},
            border = {r = 0.6, g = 0.2, b = 0.8},
            background = {r = 0.1, g = 0.03, b = 0.1, a = 0.8},
            glow = {r = 0.8, g = 0.4, b = 1.0},
            highlight = {r = 0.7, g = 0.5, b = 1.0, a = 0.2},
        },
        felenergy = {
            healthBar = {r = 0.1, g = 0.8, b = 0.1},
            castBar = {r = 0.3, g = 0.9, b = 0.3},
            border = {r = 0.1, g = 0.8, b = 0.1},
            background = {r = 0.03, g = 0.1, b = 0.03, a = 0.8},
            glow = {r = 0.4, g = 1.0, b = 0.4},
            highlight = {r = 0.5, g = 1.0, b = 0.5, a = 0.2},
        }
    }
    
    -- Apply theme color based on element type
    if themeColors[theme] and themeColors[theme][elementType] then
        local color = themeColors[theme][elementType]
        if type(element.SetColorTexture) == "function" then
            element:SetColorTexture(color.r, color.g, color.b, color.a or 1.0)
        elseif type(element.SetStatusBarColor) == "function" then
            element:SetStatusBarColor(color.r, color.g, color.b, color.a or 1.0)
        elseif type(element.SetVertexColor) == "function" then
            element:SetVertexColor(color.r, color.g, color.b, color.a or 1.0)
        end
        
        return color
    end
    
    return nil
end

-- Check if a unit is a special type (boss, elite, rare, etc)
function Utils:GetUnitType(unit)
    if UnitClassification(unit) == "worldboss" or UnitLevel(unit) == -1 then
        return "boss"
    elseif UnitClassification(unit) == "elite" then
        return "elite"
    elseif UnitClassification(unit) == "rare" then
        return "rare"
    elseif UnitClassification(unit) == "rareelite" then
        return "rareelite"
    else
        return "normal"
    end
end

-- Get a table of important auras for the unit
function Utils:GetImportantAuras(unit)
    -- Implement aura filtering logic here
    -- This would be filled out with specific aura detection code
    -- based on the unit and current content type
    return {}
end