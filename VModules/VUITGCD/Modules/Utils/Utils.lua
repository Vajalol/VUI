-- VUITGCD Utils.lua
-- Utility functions for the VUITGCD module

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace
if not ns.utils then ns.utils = {} end

---@param spellId number
---@return string|nil
function ns.utils.GetSpellName(spellId)
    if not spellId or spellId == 0 then return nil end
    return GetSpellInfo(spellId)
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