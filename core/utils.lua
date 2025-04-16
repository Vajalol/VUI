local _, VUI = ...

-- Utility functions for VUI
VUI.utils = {}

-- Table utilities
function VUI.utils.copy(source)
    if type(source) ~= "table" then return source end
    local result = {}
    for k, v in pairs(source) do
        if type(v) == "table" then
            result[k] = VUI.utils.copy(v)
        else
            result[k] = v
        end
    end
    return result
end

function VUI.utils.merge(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then return target end
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            VUI.utils.merge(target[k], v)
        else
            target[k] = v
        end
    end
    return target
end

function VUI.utils.tablefind(tbl, value)
    for i, v in pairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

function VUI.utils.tablecount(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- String utilities
function VUI.utils.split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for match in string.gmatch(str, pattern) do
        table.insert(result, match)
    end
    return result
end

function VUI.utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

function VUI.utils.startswith(str, start)
    return str:sub(1, #start) == start
end

function VUI.utils.endswith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function VUI.utils.capitalize(str)
    return str:gsub("^%l", string.upper)
end

-- Time utilities
function VUI.utils.formatTime(seconds)
    if not seconds or seconds < 0 then
        return "0:00"
    elseif seconds < 60 then
        return string.format("0:%02d", seconds)
    elseif seconds < 3600 then
        return string.format("%d:%02d", seconds / 60, seconds % 60)
    else
        return string.format("%d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    end
end

function VUI.utils.formatShortTime(seconds)
    if not seconds or seconds < 0 then
        return "0s"
    elseif seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        return string.format("%dm", math.floor(seconds / 60))
    elseif seconds < 86400 then
        return string.format("%dh", math.floor(seconds / 3600))
    else
        return string.format("%dd", math.floor(seconds / 86400))
    end
end

-- Color utilities
function VUI.utils.createColor(r, g, b, a)
    return {r = r or 1, g = g or 1, b = b or 1, a = a or 1}
end

function VUI.utils.colorToHex(color)
    return string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end

function VUI.utils.hexToColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return {r = r, g = g, b = b, a = 1}
end

function VUI.utils.colorToString(color)
    if not color then return "|cffffffff" end
    local a = color.a or 1
    return string.format("|c%02x%02x%02x%02x", a * 255, color.r * 255, color.g * 255, color.b * 255)
end

-- UI utilities
function VUI.utils.createFrame(frameType, name, parent, template)
    local frame = CreateFrame(frameType, name, parent, template)
    return frame
end

function VUI.utils.createBackdrop(frame, bgColor, borderColor, borderSize, inset)
    bgColor = bgColor or VUI:GetColor("black")
    borderColor = borderColor or VUI:GetColor("gray")
    borderSize = borderSize or 1
    inset = inset or 0
    
    local backdrop = VUI:CreateBackdrop(bgColor, borderColor, borderSize, inset)
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 1)
    frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1)
end

function VUI.utils.createFontString(frame, font, size, flags, justifyH, justifyV)
    local fontString = frame:CreateFontString(nil, "OVERLAY")
    VUI:ApplyFont(fontString, font or VUI.media.fonts.normal, size or 12, flags or "")
    fontString:SetJustifyH(justifyH or "LEFT")
    fontString:SetJustifyV(justifyV or "MIDDLE")
    return fontString
end

function VUI.utils.createTexture(frame, layer, texture, color)
    local tex = frame:CreateTexture(nil, layer or "BACKGROUND")
    if texture then
        VUI:ApplyTexture(tex, texture)
    end
    if color then
        tex:SetVertexColor(color.r, color.g, color.b, color.a or 1)
    end
    return tex
end

-- Event and timer utilities
local timerFrame = CreateFrame("Frame")
local timers = {}

function VUI.utils.after(delay, callback)
    if type(callback) ~= "function" then
        error("VUI.utils.after: callback must be a function")
    end
    
    local timer = {
        callback = callback,
        expires = GetTime() + delay,
        canceled = false,
    }
    
    table.insert(timers, timer)
    
    if not timerFrame:GetScript("OnUpdate") then
        timerFrame:SetScript("OnUpdate", function(self, elapsed)
            local now = GetTime()
            local i = 1
            while i <= #timers do
                local timer = timers[i]
                if not timer.canceled and now >= timer.expires then
                    -- Remove the timer before running the callback to avoid issues if the callback errors
                    table.remove(timers, i)
                    
                    -- Call the callback
                    local success, err = pcall(timer.callback)
                    if not success then
                        VUI:Print("Timer callback error: " .. (err or "unknown error"))
                    end
                else
                    i = i + 1
                end
            end
            
            -- If no timers left, stop the OnUpdate
            if #timers == 0 then
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
    
    return timer
end

function VUI.utils.cancelTimer(timer)
    if not timer then return end
    timer.canceled = true
end

-- Throttle a function call to prevent it from being called too frequently
function VUI.utils.throttle(func, interval)
    local lastCall = 0
    return function(...)
        local now = GetTime()
        if now - lastCall >= interval then
            lastCall = now
            return func(...)
        end
    end
end

-- Debounce a function call to only execute after a period of inactivity
function VUI.utils.debounce(func, wait)
    local timer
    return function(...)
        local args = {...}
        if timer then
            VUI.utils.cancelTimer(timer)
        end
        timer = VUI.utils.after(wait, function()
            func(unpack(args))
            timer = nil
        end)
    end
end

-- WoW-specific utilities
function VUI.utils.getSpellTexture(spellID)
    if not spellID then return nil end
    local name, _, icon = GetSpellInfo(spellID)
    return icon, name
end

function VUI.utils.getItemTexture(itemID)
    if not itemID then return nil end
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
    return icon, name
end

function VUI.utils.getClassColor(class)
    if not class then
        class = select(2, UnitClass("player"))
    end
    
    local color = RAID_CLASS_COLORS[class]
    if color then
        return {r = color.r, g = color.g, b = color.b, a = 1}
    else
        return {r = 1, g = 1, b = 1, a = 1}
    end
end

function VUI.utils.getUnitColor(unit)
    if not unit or not UnitExists(unit) then return {r = 1, g = 1, b = 1, a = 1} end
    
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        return VUI.utils.getClassColor(class)
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            if reaction >= 5 then
                return {r = 0, g = 1, b = 0, a = 1} -- Friendly
            elseif reaction == 4 then
                return {r = 1, g = 1, b = 0, a = 1} -- Neutral
            else
                return {r = 1, g = 0, b = 0, a = 1} -- Hostile
            end
        else
            return {r = 1, g = 1, b = 1, a = 1} -- Default
        end
    end
end

-- Function to print debug information (only if debugging is enabled)
function VUI.utils.debug(...)
    if VUI.db and VUI.db.profile and VUI.db.profile.general and VUI.db.profile.general.debug then
        VUI:Print("Debug:", ...)
    end
end

-- Function to safely format a string (avoids errors if placeholders don't match)
function VUI.utils.format(format, ...)
    local success, result = pcall(string.format, format, ...)
    if success then
        return result
    else
        local args = {...}
        local msg = format .. " ["
        for i, v in ipairs(args) do
            msg = msg .. tostring(v)
            if i ~= #args then
                msg = msg .. ", "
            end
        end
        return msg .. "]"
    end
end
