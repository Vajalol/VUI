-------------------------------------------------------------------------------
-- Title: VUI Premade Group Finder Role Display
-- Author: VortexQ8
-- Enhanced role requirement display for premade group finder
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local PGF = VUI.modules.premadegroupfinder or {}

-- Skip if premadegroupfinder module is not available
if not PGF then return end

-- Create the role display namespace
PGF.RoleDisplay = {}
local RD = PGF.RoleDisplay

-- Initialize role display
function RD:Initialize()
    self.isEnabled = PGF.settings.advanced.enhancedRoleDisplay
    
    -- Register for events
    if self.isEnabled then
        self:RegisterHooks()
    end
end

-- Register necessary hooks
function RD:RegisterHooks()
    -- Hook into search entry updates
    if _G.LFGListSearchEntry_Update then
        hooksecurefunc("LFGListSearchEntry_Update", function(button)
            if self.isEnabled then
                self:ApplyRoleDisplay(button)
            end
        end)
    end
    
    -- Hook into tooltip function
    if _G.LFGListUtil_SetSearchEntryTooltip then
        hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID)
            if self.isEnabled then
                self:AddRolesToTooltip(tooltip, resultID)
            end
        end)
    end
end

-- Apply enhanced role display to a search entry
function RD:ApplyRoleDisplay(button)
    if not button or not button.resultID then return end
    
    local resultID = button.resultID
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then return end
    
    -- Get role information
    local totalNeeded = 0
    local totalAvailable = 0
    local roleInfo = {}
    
    -- Tank info
    if searchResultInfo.tanks then
        totalNeeded = totalNeeded + searchResultInfo.tanks.needed
        totalAvailable = totalAvailable + searchResultInfo.tanks.available
        roleInfo.tank = {
            needed = searchResultInfo.tanks.needed,
            available = searchResultInfo.tanks.available,
        }
    end
    
    -- Healer info
    if searchResultInfo.healers then
        totalNeeded = totalNeeded + searchResultInfo.healers.needed
        totalAvailable = totalAvailable + searchResultInfo.healers.available
        roleInfo.healer = {
            needed = searchResultInfo.healers.needed,
            available = searchResultInfo.healers.available,
        }
    end
    
    -- DPS info
    if searchResultInfo.dps then
        totalNeeded = totalNeeded + searchResultInfo.dps.needed
        totalAvailable = totalAvailable + searchResultInfo.dps.available
        roleInfo.dps = {
            needed = searchResultInfo.dps.needed,
            available = searchResultInfo.dps.available,
        }
    end
    
    -- Create or update role display
    if not button.VUIRoleDisplay then
        -- Create main container for role display
        button.VUIRoleDisplay = CreateFrame("Frame", nil, button)
        button.VUIRoleDisplay:SetSize(100, 20)
        button.VUIRoleDisplay:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 10, 5)
        
        -- Tank role
        button.VUIRoleDisplay.TankIcon = button.VUIRoleDisplay:CreateTexture(nil, "ARTWORK")
        button.VUIRoleDisplay.TankIcon:SetSize(PGF.settings.roleRequirements.iconSize, PGF.settings.roleRequirements.iconSize)
        button.VUIRoleDisplay.TankIcon:SetPoint("LEFT", button.VUIRoleDisplay, "LEFT", 0, 0)
        
        button.VUIRoleDisplay.TankText = button.VUIRoleDisplay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.VUIRoleDisplay.TankText:SetPoint("LEFT", button.VUIRoleDisplay.TankIcon, "RIGHT", 1, 0)
        
        -- Healer role
        button.VUIRoleDisplay.HealerIcon = button.VUIRoleDisplay:CreateTexture(nil, "ARTWORK")
        button.VUIRoleDisplay.HealerIcon:SetSize(PGF.settings.roleRequirements.iconSize, PGF.settings.roleRequirements.iconSize)
        button.VUIRoleDisplay.HealerIcon:SetPoint("LEFT", button.VUIRoleDisplay.TankText, "RIGHT", 5, 0)
        
        button.VUIRoleDisplay.HealerText = button.VUIRoleDisplay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.VUIRoleDisplay.HealerText:SetPoint("LEFT", button.VUIRoleDisplay.HealerIcon, "RIGHT", 1, 0)
        
        -- DPS role
        button.VUIRoleDisplay.DPSIcon = button.VUIRoleDisplay:CreateTexture(nil, "ARTWORK")
        button.VUIRoleDisplay.DPSIcon:SetSize(PGF.settings.roleRequirements.iconSize, PGF.settings.roleRequirements.iconSize)
        button.VUIRoleDisplay.DPSIcon:SetPoint("LEFT", button.VUIRoleDisplay.HealerText, "RIGHT", 5, 0)
        
        button.VUIRoleDisplay.DPSText = button.VUIRoleDisplay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.VUIRoleDisplay.DPSText:SetPoint("LEFT", button.VUIRoleDisplay.DPSIcon, "RIGHT", 1, 0)
        
        -- Current player role highlight
        button.VUIRoleDisplay.MyRoleHighlight = button.VUIRoleDisplay:CreateTexture(nil, "BACKGROUND")
        button.VUIRoleDisplay.MyRoleHighlight:SetSize(PGF.settings.roleRequirements.iconSize + 4, PGF.settings.roleRequirements.iconSize + 4)
        button.VUIRoleDisplay.MyRoleHighlight:SetColorTexture(1, 1, 0, 0.3)
        button.VUIRoleDisplay.MyRoleHighlight:Hide()
        
        -- Completion status
        button.VUIRoleDisplay.StatusText = button.VUIRoleDisplay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.VUIRoleDisplay.StatusText:SetPoint("RIGHT", button, "RIGHT", -10, 0)
    end
    
    -- Update role icons
    self:UpdateRoleIcons(button, roleInfo)
    
    -- Update role counts
    self:UpdateRoleCounts(button, roleInfo)
    
    -- Show completion status
    self:UpdateCompletionStatus(button, totalNeeded, totalAvailable, searchResultInfo.numMembers)
    
    -- Highlight my role if needed
    if PGF.settings.roleRequirements.emphasisMyRole then
        self:HighlightMyRole(button, roleInfo)
    end
    
    -- Show the role display
    button.VUIRoleDisplay:Show()
end

-- Update role icons with themed versions
function RD:UpdateRoleIcons(button, roleInfo)
    if not button or not button.VUIRoleDisplay then return end
    
    local display = button.VUIRoleDisplay
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local iconStyle = PGF.settings.roleRequirements.iconsStyle
    
    -- Set tank icon
    if roleInfo.tank and roleInfo.tank.needed > 0 then
        if iconStyle == "theme" then
            display.TankIcon:SetTexture(string.format("Interface\\Addons\\VUI\\media\\textures\\%s\\premadegroupfinder\\tank.tga", currentTheme))
        else
            display.TankIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
            display.TankIcon:SetTexCoord(0, 0.25, 0, 1)
        end
        display.TankIcon:SetDesaturated(roleInfo.tank.available == 0)
        display.TankIcon:Show()
    else
        display.TankIcon:Hide()
    end
    
    -- Set healer icon
    if roleInfo.healer and roleInfo.healer.needed > 0 then
        if iconStyle == "theme" then
            display.HealerIcon:SetTexture(string.format("Interface\\Addons\\VUI\\media\\textures\\%s\\premadegroupfinder\\healer.tga", currentTheme))
        else
            display.HealerIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
            display.HealerIcon:SetTexCoord(0.25, 0.5, 0, 1)
        end
        display.HealerIcon:SetDesaturated(roleInfo.healer.available == 0)
        display.HealerIcon:Show()
    else
        display.HealerIcon:Hide()
    end
    
    -- Set dps icon
    if roleInfo.dps and roleInfo.dps.needed > 0 then
        if iconStyle == "theme" then
            display.DPSIcon:SetTexture(string.format("Interface\\Addons\\VUI\\media\\textures\\%s\\premadegroupfinder\\damage.tga", currentTheme))
        else
            display.DPSIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
            display.DPSIcon:SetTexCoord(0.5, 0.75, 0, 1)
        end
        display.DPSIcon:SetDesaturated(roleInfo.dps.available == 0)
        display.DPSIcon:Show()
    else
        display.DPSIcon:Hide()
    end
end

-- Update role counts with current values
function RD:UpdateRoleCounts(button, roleInfo)
    if not button or not button.VUIRoleDisplay then return end
    
    local display = button.VUIRoleDisplay
    
    -- Set tank text
    if roleInfo.tank and roleInfo.tank.needed > 0 then
        local text = string.format("%d/%d", roleInfo.tank.needed - roleInfo.tank.available, roleInfo.tank.needed)
        display.TankText:SetText(text)
        
        -- Colorize based on availability
        if PGF.settings.roleRequirements.colorIndicators then
            if roleInfo.tank.available > 0 then
                display.TankText:SetTextColor(0, 1, 0)
            else
                display.TankText:SetTextColor(1, 0, 0)
            end
        else
            display.TankText:SetTextColor(1, 1, 1)
        end
        
        display.TankText:Show()
    else
        display.TankText:Hide()
    end
    
    -- Set healer text
    if roleInfo.healer and roleInfo.healer.needed > 0 then
        local text = string.format("%d/%d", roleInfo.healer.needed - roleInfo.healer.available, roleInfo.healer.needed)
        display.HealerText:SetText(text)
        
        -- Colorize based on availability
        if PGF.settings.roleRequirements.colorIndicators then
            if roleInfo.healer.available > 0 then
                display.HealerText:SetTextColor(0, 1, 0)
            else
                display.HealerText:SetTextColor(1, 0, 0)
            end
        else
            display.HealerText:SetTextColor(1, 1, 1)
        end
        
        display.HealerText:Show()
    else
        display.HealerText:Hide()
    end
    
    -- Set dps text
    if roleInfo.dps and roleInfo.dps.needed > 0 then
        local text = string.format("%d/%d", roleInfo.dps.needed - roleInfo.dps.available, roleInfo.dps.needed)
        display.DPSText:SetText(text)
        
        -- Colorize based on availability
        if PGF.settings.roleRequirements.colorIndicators then
            if roleInfo.dps.available > 0 then
                display.DPSText:SetTextColor(0, 1, 0)
            else
                display.DPSText:SetTextColor(1, 0, 0)
            end
        else
            display.DPSText:SetTextColor(1, 1, 1)
        end
        
        display.DPSText:Show()
    else
        display.DPSText:Hide()
    end
end

-- Update completion status of the group
function RD:UpdateCompletionStatus(button, totalNeeded, totalAvailable, numMembers)
    if not button or not button.VUIRoleDisplay then return end
    
    local display = button.VUIRoleDisplay
    
    -- Calculate slots filled
    local filledSlots = numMembers or 0
    local totalSlots = filledSlots + totalNeeded
    
    -- Show status text
    if PGF.settings.roleRequirements.showMissingRoles and totalNeeded > 0 then
        local text = string.format("%d/%d", filledSlots, totalSlots)
        display.StatusText:SetText(text)
        
        -- Colorize based on completion
        if filledSlots == totalSlots then
            display.StatusText:SetTextColor(0, 1, 0)
        elseif filledSlots >= totalSlots - 1 then
            display.StatusText:SetTextColor(1, 1, 0)
        else
            display.StatusText:SetTextColor(1, 0.5, 0)
        end
        
        display.StatusText:Show()
    else
        display.StatusText:Hide()
    end
end

-- Highlight the player's current role
function RD:HighlightMyRole(button, roleInfo)
    if not button or not button.VUIRoleDisplay then return end
    
    local display = button.VUIRoleDisplay
    local myRole = self:GetPlayerRole()
    
    -- Position highlight based on role
    if myRole == "TANK" and roleInfo.tank and roleInfo.tank.needed > 0 and roleInfo.tank.available > 0 then
        display.MyRoleHighlight:ClearAllPoints()
        display.MyRoleHighlight:SetPoint("CENTER", display.TankIcon, "CENTER", 0, 0)
        display.MyRoleHighlight:Show()
    elseif myRole == "HEALER" and roleInfo.healer and roleInfo.healer.needed > 0 and roleInfo.healer.available > 0 then
        display.MyRoleHighlight:ClearAllPoints()
        display.MyRoleHighlight:SetPoint("CENTER", display.HealerIcon, "CENTER", 0, 0)
        display.MyRoleHighlight:Show()
    elseif myRole == "DAMAGER" and roleInfo.dps and roleInfo.dps.needed > 0 and roleInfo.dps.available > 0 then
        display.MyRoleHighlight:ClearAllPoints()
        display.MyRoleHighlight:SetPoint("CENTER", display.DPSIcon, "CENTER", 0, 0)
        display.MyRoleHighlight:Show()
    else
        display.MyRoleHighlight:Hide()
    end
end

-- Get player's current role
function RD:GetPlayerRole()
    -- Get specialization info
    local specIndex = GetSpecialization()
    if specIndex then
        local id, name, description, icon, role = GetSpecializationInfo(specIndex)
        if role then
            return role
        end
    end
    
    -- Fallback to class default
    local _, _, classID = UnitClass("player")
    
    -- Default roles by class
    local defaultRoles = {
        [1] = "DAMAGER",  -- Warrior
        [2] = "TANK",     -- Paladin
        [3] = "DAMAGER",  -- Hunter
        [4] = "DAMAGER",  -- Rogue
        [5] = "HEALER",   -- Priest
        [6] = "TANK",     -- Death Knight
        [7] = "HEALER",   -- Shaman
        [8] = "DAMAGER",  -- Mage
        [9] = "DAMAGER",  -- Warlock
        [10] = "HEALER",  -- Monk
        [11] = "DAMAGER", -- Druid
        [12] = "DAMAGER", -- Demon Hunter
        [13] = "DAMAGER", -- Evoker
    }
    
    return defaultRoles[classID] or "DAMAGER"
end

-- Add detailed role information to tooltip
function RD:AddRolesToTooltip(tooltip, resultID)
    if not tooltip or not resultID then return end
    
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo then return end
    
    -- Get role requirements
    local tankNeeded = (searchResultInfo.tanks and searchResultInfo.tanks.needed) or 0
    local tankAvailable = (searchResultInfo.tanks and searchResultInfo.tanks.available) or 0
    local tankFilled = tankNeeded - tankAvailable
    
    local healerNeeded = (searchResultInfo.healers and searchResultInfo.healers.needed) or 0
    local healerAvailable = (searchResultInfo.healers and searchResultInfo.healers.available) or 0
    local healerFilled = healerNeeded - healerAvailable
    
    local dpsNeeded = (searchResultInfo.dps and searchResultInfo.dps.needed) or 0
    local dpsAvailable = (searchResultInfo.dps and searchResultInfo.dps.available) or 0
    local dpsFilled = dpsNeeded - dpsAvailable
    
    -- Add group composition section
    tooltip:AddLine(" ")
    tooltip:AddLine("Group Composition", 1, 1, 1)
    
    -- Add role information with colors
    if tankNeeded > 0 then
        local r, g, b = 1, 1, 1
        if tankAvailable == 0 then
            r, g, b = 0.5, 0.5, 0.5
        elseif tankAvailable < tankNeeded then
            r, g, b = 0, 1, 0
        end
        tooltip:AddDoubleLine("Tanks:", string.format("%d/%d", tankFilled, tankNeeded), 1, 1, 1, r, g, b)
    end
    
    if healerNeeded > 0 then
        local r, g, b = 1, 1, 1
        if healerAvailable == 0 then
            r, g, b = 0.5, 0.5, 0.5
        elseif healerAvailable < healerNeeded then
            r, g, b = 0, 1, 0
        end
        tooltip:AddDoubleLine("Healers:", string.format("%d/%d", healerFilled, healerNeeded), 1, 1, 1, r, g, b)
    end
    
    if dpsNeeded > 0 then
        local r, g, b = 1, 1, 1
        if dpsAvailable == 0 then
            r, g, b = 0.5, 0.5, 0.5
        elseif dpsAvailable < dpsNeeded then
            r, g, b = 0, 1, 0
        end
        tooltip:AddDoubleLine("DPS:", string.format("%d/%d", dpsFilled, dpsNeeded), 1, 1, 1, r, g, b)
    end
    
    -- Add information about player's role
    local myRole = self:GetPlayerRole()
    local canJoin = false
    
    if myRole == "TANK" and tankAvailable > 0 then
        canJoin = true
    elseif myRole == "HEALER" and healerAvailable > 0 then
        canJoin = true
    elseif myRole == "DAMAGER" and dpsAvailable > 0 then
        canJoin = true
    end
    
    tooltip:AddLine(" ")
    if canJoin then
        tooltip:AddLine("Your role is needed in this group", 0, 1, 0)
    else
        tooltip:AddLine("Your role is not needed in this group", 1, 0, 0)
    end
    
    -- Show the tooltip
    tooltip:Show()
end

-- Enable role display
function RD:Enable()
    self.isEnabled = true
    self:RegisterHooks()
end

-- Disable role display
function RD:Disable()
    self.isEnabled = false
end