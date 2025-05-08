-- VUITGCD Icon.lua
-- Handles icon creation and management for ability display

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Create a class-like structure for Icon
---@class Icon
ns.Icon = {}
ns.Icon.__index = ns.Icon

---@param owner Frame
---@param spellId number
---@param size number
---@return Icon
function ns.Icon:New(owner, spellId, size)
    local self = setmetatable({}, ns.Icon)
    
    self.owner = owner
    self.spellId = spellId
    self.spellName = ns.utils.GetSpellName(spellId)
    self.size = size or ns.constants.defaultIconSize
    self.frame = nil
    self.texture = nil
    self.cooldownFrame = nil
    self.borderFrame = nil
    self.textOverlay = nil
    self.glowType = "none"
    self.startTime = GetTime()
    self.endTime = nil
    self.duration = nil
    self.fadeStartTime = nil
    self.isFading = false
    self.isActive = true
    
    -- Create the visual elements
    self:CreateFrames()
    
    return self
end

-- Create all necessary frames
function ns.Icon:CreateFrames()
    -- Get parent frame
    local parent = self.owner or UIParent
    
    -- Create base frame
    self.frame = CreateFrame("Frame", nil, parent)
    self.frame:SetSize(self.size, self.size)
    self.frame:SetFrameLevel(parent:GetFrameLevel() + 1)
    self.frame.icon = self  -- Reference back to Icon object
    
    -- Create texture
    self.texture = self.frame:CreateTexture(nil, "ARTWORK")
    self.texture:SetAllPoints()
    self.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Remove default icon border
    
    -- Set the texture from spell ID
    local textureFile = ns.utils.GetSpellTexture(self.spellId)
    if textureFile then
        self.texture:SetTexture(textureFile)
    else
        self.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    
    -- Create cooldown frame
    self.cooldownFrame = CreateFrame("Cooldown", nil, self.frame, "CooldownFrameTemplate")
    self.cooldownFrame:SetAllPoints()
    self.cooldownFrame:SetDrawEdge(false)
    self.cooldownFrame:SetDrawSwipe(true)
    self.cooldownFrame:SetSwipeColor(0, 0, 0, 0.8)
    self.cooldownFrame:SetHideCountdownNumbers(true)
    
    -- Create border
    self.borderFrame = self.frame:CreateTexture(nil, "OVERLAY")
    self.borderFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -2, 2)
    self.borderFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 2, -2)
    self.borderFrame:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    self.borderFrame:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    self.borderFrame:Hide()
    
    -- Create text overlay for spell name
    self.textOverlay = self.frame:CreateFontString(nil, "OVERLAY")
    self.textOverlay:SetFont("Fonts\\FRIZQT__.TTF", math.max(self.size / 3, 8), "OUTLINE")
    self.textOverlay:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 0)
    self.textOverlay:SetTextColor(1, 1, 1, 1)
    self.textOverlay:Hide()
    
    -- Setup tooltip functionality
    self.frame:SetScript("OnEnter", function()
        if ns.settings and ns.settings.activeProfile and 
           ns.settings.activeProfile.showTooltips and self.spellId then
            GameTooltip:SetOwner(self.frame, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellId)
            GameTooltip:Show()
        end
    end)
    
    self.frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Add to Masque if available
    if ns.masqueHelper and ns.masqueHelper.IsMasqueAvailable() then
        ns.masqueHelper.AddButton(self.frame)
    end
end

-- Set the icon's position (relative to its owner)
---@param point string
---@param relativePoint string
---@param xOffset number
---@param yOffset number
function ns.Icon:SetPosition(point, relativePoint, xOffset, yOffset)
    if not self.frame or not self.frame:GetParent() then return end
    
    self.frame:ClearAllPoints()
    self.frame:SetPoint(point or "CENTER", self.frame:GetParent(), relativePoint or "CENTER", xOffset or 0, yOffset or 0)
end

-- Start a cooldown animation
---@param duration number
function ns.Icon:StartCooldown(duration)
    if not self.cooldownFrame or not duration or duration <= 0 then return end
    
    self.startTime = GetTime()
    self.duration = duration
    self.endTime = self.startTime + duration
    
    self.cooldownFrame:SetCooldown(self.startTime, self.duration)
end

-- Show spell name text
---@param show boolean
function ns.Icon:ShowSpellName(show)
    if not self.textOverlay then return end
    
    if show and self.spellName then
        self.textOverlay:SetText(self.spellName)
        self.textOverlay:Show()
    else
        self.textOverlay:Hide()
    end
end

-- Apply a glow effect to the icon
---@param glowType string
---@param color table|nil
function ns.Icon:ApplyGlow(glowType, color)
    if not self.frame then return end
    
    self.glowType = glowType or "none"
    
    if self.glowType == "none" then
        ns.frameUtils.RemoveGlow(self.frame)
    else
        ns.frameUtils.ApplyGlow(self.frame, self.glowType, color)
    end
end

-- Start the fade out process
---@param duration number
function ns.Icon:StartFadeOut(duration)
    if not self.frame or self.isFading then return end
    
    self.isFading = true
    self.fadeStartTime = GetTime()
    
    ns.utils.StartFadeOut(self.frame, 1.0, 0.0, duration or ns.constants.defaultFadeDuration, function()
        self:Hide()
    end)
end

-- Show the icon
function ns.Icon:Show()
    if not self.frame then return end
    
    self.frame:Show()
    self.isActive = true
    self.isFading = false
    self.frame:SetAlpha(1.0)
end

-- Hide the icon
function ns.Icon:Hide()
    if not self.frame then return end
    
    self.frame:Hide()
    self.isActive = false
    self.isFading = false
end

-- Update the icon (call this on OnUpdate)
---@param elapsed number
function ns.Icon:Update(elapsed)
    if not self.frame or not self.isActive then return end
    
    -- Check if we should start fading
    if self.endTime and GetTime() > self.endTime and not self.isFading then
        self:StartFadeOut()
    end
end

-- Clean up and destroy the icon
function ns.Icon:Destroy()
    if not self.frame then return end
    
    -- Remove from Masque if needed
    if ns.masqueHelper and ns.masqueHelper.IsMasqueAvailable() then
        ns.masqueHelper.RemoveButton(self.frame)
    end
    
    -- Remove glow effects
    ns.frameUtils.RemoveGlow(self.frame)
    
    -- Clean up frame
    self.frame:SetScript("OnEnter", nil)
    self.frame:SetScript("OnLeave", nil)
    self.frame:Hide()
    self.frame:ClearAllPoints()
    self.frame:SetParent(nil)
    self.frame = nil
    
    -- Clean up references
    self.texture = nil
    self.cooldownFrame = nil
    self.borderFrame = nil
    self.textOverlay = nil
    self.owner = nil
    self.isActive = false
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.Icon = ns.Icon
end