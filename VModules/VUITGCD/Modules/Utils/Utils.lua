-- VUITGCD Utils.lua
-- Utility functions for the VUITGCD module

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace
if not ns.utils then ns.utils = {} end

---@param spellId number
---@return string|nil
function ns.utils.getSpellInfo(spellId)
    if not spellId or spellId == 0 then return nil end
    return GetSpellInfo(spellId)
end

-- Safe function to add a frame to the interface options
function ns.utils.interfaceOptions_AddCategory(frame)
    if frame and InterfaceOptions_AddCategory then
        -- Check for existence and safety
        local success, err = pcall(function()
            InterfaceOptions_AddCategory(frame)
        end)
        
        if not success then
            -- If we failed, provide a fallback method for registration
            frame.okay = frame.okay or function() end
            frame.cancel = frame.cancel or function() end
            frame.refresh = frame.refresh or function() end
            frame.default = frame.default or function() end
            
            -- If Settings exists (Dragonflight+), try to use that
            if Settings and Settings.RegisterAddOnCategory then
                local category = {
                    id = frame.name or "VUITGCD",
                    name = frame.name or "VUITGCD",
                    parent = frame.parent,
                    category = frame.parent and "ADDONS" or nil,
                    uiOrder = 100,
                    onCommit = frame.okay,
                    onRefresh = frame.refresh,
                    onDefault = frame.default,
                }
                
                pcall(function() 
                    Settings.RegisterAddOnCategory(category)
                end)
            end
        end
    end
end

-- Size of a table with any keys
function ns.utils.size(tbl)
    local count = 0
    if type(tbl) == "table" then
        for _ in pairs(tbl) do
            count = count + 1
        end
    end
    return count
end

-- Generate a UUID v4 (random)
function ns.utils.uuid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Get default profile name based on player
function ns.utils.defaultProfileName()
    return UnitName("player") and (UnitName("player") .. " - " .. (GetRealmName() or "")) or "Default"
end

---@param spellId number
---@return string|nil
function ns.utils.GetSpellTexture(spellId)
    if not spellId or spellId == 0 then return nil end
    return select(3, GetSpellInfo(spellId))
end

---@param frame Frame
---@param elapsed number
function ns.utils.FadeIn(frame, elapsed)
    if not frame or not frame.fadeInfo then return end
    
    local fadeInfo = frame.fadeInfo
    fadeInfo.timeToFade = fadeInfo.timeToFade - elapsed
    
    if fadeInfo.timeToFade <= 0 then
        frame:SetAlpha(fadeInfo.endAlpha)
        frame.fadeInfo = nil
        if fadeInfo.finishedFunc then
            fadeInfo.finishedFunc(frame)
        end
        return
    end
    
    local currentAlpha = frame:GetAlpha()
    local newAlpha = currentAlpha + (elapsed * (fadeInfo.endAlpha - fadeInfo.startAlpha) / fadeInfo.duration)
    frame:SetAlpha(newAlpha)
end

---@param frame Frame
---@param elapsed number
function ns.utils.FadeOut(frame, elapsed)
    if not frame or not frame.fadeInfo then return end
    
    local fadeInfo = frame.fadeInfo
    fadeInfo.timeToFade = fadeInfo.timeToFade - elapsed
    
    if fadeInfo.timeToFade <= 0 then
        frame:SetAlpha(fadeInfo.endAlpha)
        frame.fadeInfo = nil
        if fadeInfo.finishedFunc then
            fadeInfo.finishedFunc(frame)
        end
        return
    end
    
    local currentAlpha = frame:GetAlpha()
    local newAlpha = currentAlpha - (elapsed * (fadeInfo.startAlpha - fadeInfo.endAlpha) / fadeInfo.duration)
    frame:SetAlpha(newAlpha)
end

---@param frame Frame
---@param startAlpha number
---@param endAlpha number
---@param duration number
---@param finishedFunc function|nil
function ns.utils.StartFadeIn(frame, startAlpha, endAlpha, duration, finishedFunc)
    if not frame then return end
    
    if frame.fadeInfo then
        frame.fadeInfo = nil
    end
    
    frame:SetAlpha(startAlpha)
    frame.fadeInfo = {
        startAlpha = startAlpha,
        endAlpha = endAlpha,
        duration = duration,
        timeToFade = duration,
        finishedFunc = finishedFunc
    }
    frame:SetScript("OnUpdate", ns.utils.FadeIn)
end

---@param frame Frame
---@param startAlpha number
---@param endAlpha number
---@param duration number
---@param finishedFunc function|nil
function ns.utils.StartFadeOut(frame, startAlpha, endAlpha, duration, finishedFunc)
    if not frame then return end
    
    if frame.fadeInfo then
        frame.fadeInfo = nil
    end
    
    frame:SetAlpha(startAlpha)
    frame.fadeInfo = {
        startAlpha = startAlpha,
        endAlpha = endAlpha,
        duration = duration,
        timeToFade = duration,
        finishedFunc = finishedFunc
    }
    frame:SetScript("OnUpdate", ns.utils.FadeOut)
end

---@param color table
---@return string
function ns.utils.RGBToHex(color)
    if not color or not color.r or not color.g or not color.b then
        return "ffffffff"
    end
    
    return string.format("%02x%02x%02x%02x",
        math.floor(color.a or 1 * 255),
        math.floor(color.r * 255),
        math.floor(color.g * 255),
        math.floor(color.b * 255)
    )
end

---@param text string
---@param color table
---@return string
function ns.utils.ColorText(text, color)
    if not text or not color then return text end
    
    local hexColor = ns.utils.RGBToHex(color)
    return "|c" .. hexColor .. text .. "|r"
end

---@param guid string
---@return boolean
function ns.utils.IsPlayer(guid)
    if not guid then return false end
    return string.sub(guid, 1, 6) == "Player"
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.Utils = ns.utils
end