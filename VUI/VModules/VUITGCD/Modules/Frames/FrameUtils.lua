-- VUITGCD FrameUtils.lua
-- Utility functions for frame creation and management

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace
if not ns.frameUtils then ns.frameUtils = {} end

---@param parent Frame
---@param name string
---@param width number
---@param height number
---@param template string|nil
---@return Frame
function ns.frameUtils.CreateBaseFrame(parent, name, width, height, template)
    local frame = CreateFrame("Frame", name, parent, template)
    frame:SetSize(width or 30, height or 30)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Create backdrop for visibility
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.5)
    frame.bg:Hide() -- Hidden by default, can be shown for debugging
    
    return frame
end

---@param parent Frame
---@param name string
---@param size number
---@return Frame, Texture
function ns.frameUtils.CreateIconFrame(parent, name, size)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetSize(size or 30, size or 30)
    
    -- Create icon texture
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Remove default icon border
    frame.icon = icon
    
    -- Create cooldown overlay
    local cooldown = CreateFrame("Cooldown", name .. "Cooldown", frame, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawSwipe(true)
    cooldown:SetSwipeColor(0, 0, 0, 0.8)
    cooldown:SetHideCountdownNumbers(true)
    frame.cooldown = cooldown
    
    -- Create border
    local border = frame:CreateTexture(nil, "OVERLAY")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
    border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    border:Hide()
    frame.border = border
    
    return frame, icon
end

---@param parent Frame
---@param text string
---@param size number
---@param font string|nil
---@return FontString
function ns.frameUtils.CreateFontString(parent, text, size, font)
    local fontString = parent:CreateFontString(nil, "OVERLAY")
    fontString:SetFont(font or "Fonts\\FRIZQT__.TTF", size or 12, "OUTLINE")
    fontString:SetText(text or "")
    fontString:SetJustifyH("CENTER")
    fontString:SetJustifyV("MIDDLE")
    
    return fontString
end

---@param parent Frame
---@param text string
---@param width number
---@param height number
---@param onClick function
---@return Button
function ns.frameUtils.CreateButton(parent, text, width, height, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 80, height or 22)
    button:SetText(text or "Button")
    
    if onClick then
        button:SetScript("OnClick", onClick)
    end
    
    return button
end

---@param parent Frame
---@param name string
---@param label string
---@param minVal number
---@param maxVal number
---@param step number
---@param width number
---@param height number
---@param OnValueChanged function
---@return Slider
function ns.frameUtils.CreateSlider(parent, name, label, minVal, maxVal, step, width, height, OnValueChanged)
    local slider = CreateFrame("Slider", name, parent, "VUITGCD_OptionsSliderTemplate")
    slider:SetSize(width or 144, height or 17)
    slider:SetMinMaxValues(minVal or 0, maxVal or 100)
    slider:SetValueStep(step or 1)
    slider:SetObeyStepOnDrag(true)
    slider.Text:SetText(label or "Slider")
    slider.Low:SetText(minVal or 0)
    slider.High:SetText(maxVal or 100)
    
    if OnValueChanged then
        slider:SetScript("OnValueChanged", OnValueChanged)
    end
    
    return slider
end

-- Apply glow effect to a frame
---@param frame Frame
---@param type string
---@param color table|nil
function ns.frameUtils.ApplyGlow(frame, type, color)
    if not frame then return end
    
    -- Remove any existing glow first
    ns.frameUtils.RemoveGlow(frame)
    
    -- Get defaults
    color = color or {r = 1, g = 1, b = 1, a = 1}
    type = type or "blizz"
    
    if type == "blizz" then
        -- Blizzard proc glow
        if LibStub and LibStub("LibCustomGlow-1.0", true) then
            local LCG = LibStub("LibCustomGlow-1.0")
            LCG.ButtonGlow_Start(frame, color)
            frame.hasBlizzGlow = true
        end
    elseif type == "pixel" then
        -- Pixel glow
        if LibStub and LibStub("LibCustomGlow-1.0", true) then
            local LCG = LibStub("LibCustomGlow-1.0")
            LCG.PixelGlow_Start(frame, color, 8, 0.5, 8, 2, 1, 0, false)
            frame.hasPixelGlow = true
        end
    elseif type == "shine" then
        -- Shine effect
        if LibStub and LibStub("LibCustomGlow-1.0", true) then
            local LCG = LibStub("LibCustomGlow-1.0")
            LCG.AutoCastGlow_Start(frame, color, 8, 0.5, 0.5, 2)
            frame.hasShineGlow = true
        end
    end
end

-- Remove glow effect from a frame
---@param frame Frame
function ns.frameUtils.RemoveGlow(frame)
    if not frame then return end
    
    if LibStub and LibStub("LibCustomGlow-1.0", true) then
        local LCG = LibStub("LibCustomGlow-1.0")
        
        if frame.hasBlizzGlow then
            LCG.ButtonGlow_Stop(frame)
            frame.hasBlizzGlow = nil
        end
        
        if frame.hasPixelGlow then
            LCG.PixelGlow_Stop(frame)
            frame.hasPixelGlow = nil
        end
        
        if frame.hasShineGlow then
            LCG.AutoCastGlow_Stop(frame)
            frame.hasShineGlow = nil
        end
    end
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.FrameUtils = ns.frameUtils
end