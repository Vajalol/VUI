local LibDBIcon = LibStub("LibDBIcon-1.0")
local Module = VUI:NewModule("Maps.Minimap");

function Module:OnInitialize()
    -- Create reference to the border glow frame
    self.borderGlow = nil
end

function Module:OnEnable()
    local db = {
        maps = VUI.db.profile.maps,
        queueicon = VUI.db.profile.edit.queueicon
    }

    if db then
        if not (C_AddOns.IsAddOnLoaded("SexyMap")) then
            if db.maps.buttons then
                local EventFrame = CreateFrame("Frame")
                EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
                EventFrame:SetScript("OnEvent", function()
                    local buttons = LibDBIcon:GetButtonList()
                    for i = 1, #buttons do
                        LibDBIcon:ShowOnEnter(buttons[i], true)
                    end
                end)
            end
        end

        local function QueueStatusButton_Reposition()
            if C_AddOns.IsAddOnLoaded("EditModeExpanded") then return end
            QueueStatusButton:SetParent(UIParent)
            QueueStatusButton:SetFrameLevel(1)
            QueueStatusButton:SetScale(0.8, 0.8)
            QueueStatusButton:ClearAllPoints()
            QueueStatusButton:SetPoint(db.queueicon.point, UIParent, db.queueicon.point, db.queueicon.x, db.queueicon.y)
        end
        
        hooksecurefunc(QueueStatusButton, "UpdatePosition", function()
            QueueStatusButton_Reposition()
        end)
        
        -- Initialize minimap border glow
        self:UpdateMinimapBorderGlow()
        
        -- Register for theme color changes to update the border glow
        VUI:RegisterCallback("THEME_COLOR_UPDATED", function()
            self:UpdateMinimapBorderGlow()
        end)
    end
end

-- Create or update the pulsing border glow around the minimap
function Module:UpdateMinimapBorderGlow()
    local db = VUI.db.profile.maps
    
    -- If the border glow exists but should be disabled, remove it
    if not db.pulsingBorder and self.borderGlow then
        self.borderGlow:Hide()
        VUI.Animations:StopAnimations(self.borderGlow)
        return
    end
    
    -- If border glow is disabled, don't proceed
    if not db.pulsingBorder then
        return
    end
    
    -- Create the border glow if it doesn't exist
    if not self.borderGlow then
        self:CreateMinimapBorderGlow()
    end
    
    -- Update properties and show it
    self:UpdateBorderGlowAppearance()
    
    -- Start the pulsing animation
    self:AnimateBorderGlow()
end

-- Create the border glow frame
function Module:CreateMinimapBorderGlow()
    -- Stop if already created
    if self.borderGlow then return end
    
    -- Create a frame that surrounds the minimap
    local glow = CreateFrame("Frame", "VUI_MinimapBorderGlow", Minimap)
    glow:SetFrameStrata("MEDIUM")
    glow:SetFrameLevel(Minimap:GetFrameLevel() - 1) -- Below the minimap but above the background
    
    -- Position it centered on the minimap, slightly larger
    glow:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
    glow:SetSize(Minimap:GetWidth() + 12, Minimap:GetHeight() + 12)
    
    -- Create a texture for the glow using a built-in WoW texture
    local texture = glow:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
    texture:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    texture:SetBlendMode("ADD")
    texture:SetAllPoints(glow)
    glow.texture = texture
    
    self.borderGlow = glow
end

-- Update the appearance of the border glow
function Module:UpdateBorderGlowAppearance()
    if not self.borderGlow then return end
    
    -- Get theme color
    local r, g, b = unpack(VUI:Color())
    
    -- Set the color of the glow texture
    self.borderGlow.texture:SetVertexColor(r, g, b, 0.7)
    
    -- Make sure it's the right size (in case minimap size changed)
    self.borderGlow:SetSize(Minimap:GetWidth() + 12, Minimap:GetHeight() + 12)
    
    -- Show the glow
    self.borderGlow:Show()
end

-- Animate the border glow with a pulsing effect
function Module:AnimateBorderGlow()
    if not self.borderGlow then return end
    
    -- Get the pulse speed setting
    local pulseSpeed = VUI.db.profile.maps.pulseSpeed or 1.5
    local duration = 2.0 / pulseSpeed -- Slower speed means longer duration
    
    -- Use the VUI animation system to create a pulsing effect
    VUI.Animations:StopAnimations(self.borderGlow)
    
    -- Create custom pulse options
    local pulseOptions = {
        pulseAmount = 0.15,    -- How much to scale during the pulse
        repeat_count = 0,      -- Repeat indefinitely (0 means infinite)
        fade = true           -- Allow alpha to pulse as well
    }
    
    -- Start the pulse animation
    VUI.Animations:Pulse(self.borderGlow, duration, nil, pulseOptions)
end
