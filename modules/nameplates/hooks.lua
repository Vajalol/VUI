local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local Nameplates = VUI.nameplates

-- Event hooks for VUI Plater
Nameplates.hooks = {}
local Hooks = Nameplates.hooks

-- Initialize hooks
function Hooks:Initialize()
    -- Create frame for event hooks if it doesn't exist
    if not self.frame then
        self.frame = CreateFrame("Frame")
        self.frame:Hide()
    end
    
    -- Clear all existing hooks
    self.frame:UnregisterAllEvents()
    self.frame:SetScript("OnEvent", nil)
    
    -- Only add hooks if the module is enabled and using plater style
    if Nameplates.enabled and Nameplates.settings.styling == "plater" then
        -- Register nameplate events
        self.frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        self.frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        self.frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        self.frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
        self.frame:RegisterEvent("UNIT_HEALTH")
        
        -- Set up event handler
        self.frame:SetScript("OnEvent", function(_, event, ...)
            if Hooks[event] then
                Hooks[event](Hooks, ...)
            end
        end)
        
        -- Add hooking for nameplates that already exist
        self:HookExistingNameplates()
        
        -- Show the frame to enable hooks
        self.frame:Show()
    end
end

-- Hook existing nameplates
function Hooks:HookExistingNameplates()
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.namePlateUnitToken then
            self:NAME_PLATE_UNIT_ADDED(namePlate.UnitFrame.namePlateUnitToken)
        end
    end
end

-- Hook: Nameplate added
function Hooks:NAME_PLATE_UNIT_ADDED(unit)
    if not unit then return end
    
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if not namePlate then return end
    
    -- Store unit on the nameplate for easy reference
    namePlate.UnitFrame.namePlateUnitToken = unit
    
    -- Apply initial plate styling
    self:StylePlate(namePlate)
    
    -- Run user custom script if enabled
    if Nameplates.settings.useAddedHook and Nameplates.settings.customScripts.plateAdded then
        self:RunCustomScript("plateAdded", namePlate, unit)
    end
    
    -- Schedule update for auras
    C_Timer.After(0.1, function()
        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.namePlateUnitToken then
            Nameplates.auras:UpdateAuras(namePlate.UnitFrame)
        end
    end)
end

-- Hook: Nameplate removed
function Hooks:NAME_PLATE_UNIT_REMOVED(unit)
    if not unit then return end
    
    -- Run custom script if enabled
    if Nameplates.settings.useRemovedHook and Nameplates.settings.customScripts.plateRemoved then
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        if namePlate then
            self:RunCustomScript("plateRemoved", namePlate, unit)
        end
    end
end

-- Hook: Player target changed
function Hooks:PLAYER_TARGET_CHANGED()
    -- Update all nameplates to reflect new target
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.namePlateUnitToken then
            self:UpdateTargetHighlight(namePlate)
        end
    end
end

-- Hook: Player focus changed
function Hooks:PLAYER_FOCUS_CHANGED()
    -- Update all nameplates to reflect new focus
    for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        if namePlate and namePlate.UnitFrame and namePlate.UnitFrame.namePlateUnitToken then
            self:UpdateFocusHighlight(namePlate)
        end
    end
end

-- Hook: Threat update
function Hooks:UNIT_THREAT_LIST_UPDATE(unit)
    if not unit then return end
    
    -- Find nameplate for the unit
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if not namePlate or not namePlate.UnitFrame then return end
    
    -- Update threat display
    self:UpdateThreat(namePlate)
    
    -- Refresh health bar color which might be affected by threat
    self:UpdateHealthColor(namePlate)
end

-- Hook: Health update
function Hooks:UNIT_HEALTH(unit)
    if not unit then return end
    
    -- Check if this is a nameplate unit
    if not unit:match("nameplate") then return end
    
    -- Find nameplate for the unit
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if not namePlate or not namePlate.UnitFrame then return end
    
    -- Update health text
    self:UpdateHealthText(namePlate)
    
    -- Check for execute range
    self:UpdateExecuteIndicator(namePlate)
end

-- Style a nameplate
function Hooks:StylePlate(namePlate)
    if not namePlate or not namePlate.UnitFrame then return end
    
    local unitFrame = namePlate.UnitFrame
    local unit = unitFrame.namePlateUnitToken
    if not unit then return end
    
    -- Skip if this plate is already styled
    if unitFrame.VUIPlaterStyled then return end
    
    -- Set up the base frame
    self:SetupBaseFrame(unitFrame)
    
    -- Set up health bar
    self:SetupHealthBar(unitFrame)
    
    -- Set up cast bar
    self:SetupCastBar(unitFrame)
    
    -- Set up texts
    self:SetupTexts(unitFrame)
    
    -- Set up indicators (target, threat, execute, etc.)
    self:SetupIndicators(unitFrame)
    
    -- Apply initial state
    self:UpdateHealthColor(namePlate)
    self:UpdateHealthText(namePlate)
    self:UpdateTargetHighlight(namePlate)
    self:UpdateFocusHighlight(namePlate)
    self:UpdateThreat(namePlate)
    self:UpdateExecuteIndicator(namePlate)
    
    -- Run user custom script if enabled
    if Nameplates.settings.useCreateHook and Nameplates.settings.customScripts.createPlate then
        self:RunCustomScript("createPlate", namePlate, unit)
    end
    
    -- Mark as styled
    unitFrame.VUIPlaterStyled = true
end

-- Set up the base frame
function Hooks:SetupBaseFrame(unitFrame)
    -- Adjust frame size
    unitFrame:SetSize(Nameplates.settings.plateWidth, Nameplates.settings.plateHeight)
    
    -- Create backdrop for the whole plate if it doesn't exist
    if not unitFrame.VUIBackdrop then
        unitFrame.VUIBackdrop = CreateFrame("Frame", nil, unitFrame)
        unitFrame.VUIBackdrop:SetAllPoints(unitFrame)
        unitFrame.VUIBackdrop:SetFrameLevel(unitFrame:GetFrameLevel())
    end
end

-- Set up health bar
function Hooks:SetupHealthBar(unitFrame)
    -- Make health bar fill the full width
    if unitFrame.healthBar then
        unitFrame.healthBar:ClearAllPoints()
        unitFrame.healthBar:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 0, 0)
        unitFrame.healthBar:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", 0, 0)
        
        -- Set texture
        local texture = Nameplates.settings.healthBarTexture or "VUI_Smooth"
        unitFrame.healthBar:SetStatusBarTexture(texture)
        
        -- Apply border based on settings
        self:ApplyBorder(unitFrame.healthBar, Nameplates.settings.healthBarBorderType)
    end
end

-- Set up cast bar
function Hooks:SetupCastBar(unitFrame)
    if not Nameplates.settings.showCastbars then
        if unitFrame.castBar then
            unitFrame.castBar:Hide()
        end
        return
    end
    
    -- Ensure cast bar exists
    if not unitFrame.castBar then return end
    
    -- Position the cast bar
    unitFrame.castBar:ClearAllPoints()
    unitFrame.castBar:SetPoint("TOPLEFT", unitFrame.healthBar, "BOTTOMLEFT", 0, -2)
    unitFrame.castBar:SetPoint("TOPRIGHT", unitFrame.healthBar, "BOTTOMRIGHT", 0, -2)
    unitFrame.castBar:SetHeight(Nameplates.settings.castBarHeight or 10)
    
    -- Set texture
    local texture = Nameplates.settings.castBarTexture or "VUI_Smooth"
    unitFrame.castBar:SetStatusBarTexture(texture)
    
    -- Apply border
    self:ApplyBorder(unitFrame.castBar, Nameplates.settings.healthBarBorderType)
    
    -- Configure cast icon
    if unitFrame.castBar.Icon then
        local iconSize = Nameplates.settings.castBarIconSize or 16
        unitFrame.castBar.Icon:SetSize(iconSize, iconSize)
        unitFrame.castBar.Icon:ClearAllPoints()
        unitFrame.castBar.Icon:SetPoint("RIGHT", unitFrame.castBar, "LEFT", -2, 0)
    end
    
    -- Configure cast text
    if unitFrame.castBar.Text then
        unitFrame.castBar.Text:SetFont(Nameplates.settings.castBarTextFont or "VUI PT Sans Narrow", 
                                       Nameplates.settings.castBarTextSize or 8,
                                       Nameplates.settings.castBarTextOutline or "OUTLINE")
        unitFrame.castBar.Text:ClearAllPoints()
        unitFrame.castBar.Text:SetPoint("TOP", unitFrame.castBar, "CENTER", 0, 0)
    end
    
    -- Configure cast target text
    if Nameplates.settings.showCastTarget and not unitFrame.castBar.TargetText then
        unitFrame.castBar.TargetText = unitFrame.castBar:CreateFontString(nil, "OVERLAY")
        unitFrame.castBar.TargetText:SetFont(Nameplates.settings.castBarTextFont or "VUI PT Sans Narrow", 
                                           Nameplates.settings.castBarTextSize or 8,
                                           Nameplates.settings.castBarTextOutline or "OUTLINE")
    end
    
    if unitFrame.castBar.TargetText then
        -- Position based on settings
        unitFrame.castBar.TargetText:ClearAllPoints()
        if Nameplates.settings.castTargetPosition == "below" then
            unitFrame.castBar.TargetText:SetPoint("BOTTOM", unitFrame.castBar, "CENTER", 0, 0)
        else
            unitFrame.castBar.TargetText:SetPoint("LEFT", unitFrame.castBar.Text, "RIGHT", 2, 0)
        end
        
        -- Hook SetCastInfo to update target text
        if not unitFrame.castBar.VUIHooked then
            hooksecurefunc(unitFrame.castBar, "SetCastInfo", function(self, spellName, text, texture, startTime, endTime, isTradeSkill, notInterruptible)
                -- Display target of cast if enabled
                if Nameplates.settings.showCastTarget and self.TargetText then
                    local unitToken = unitFrame.namePlateUnitToken
                    if unitToken then
                        local targetName = UnitCastingTargetText(unitToken) or ""
                        if targetName ~= "" then
                            local _, targetClass = UnitClass(targetName)
                            if targetClass and Nameplates.settings.showClassColors then
                                local color = RAID_CLASS_COLORS[targetClass]
                                if color then
                                    targetName = "|cff" .. string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255) .. targetName .. "|r"
                                end
                            end
                            self.TargetText:SetText(">> " .. targetName)
                        else
                            self.TargetText:SetText("")
                        end
                    end
                end
                
                -- Apply color based on interruptible status
                if notInterruptible then
                    local color = Nameplates.settings.nonInterruptibleColor
                    self:SetStatusBarColor(color.r, color.g, color.b, color.a)
                else
                    local color = Nameplates.settings.castBarColor
                    self:SetStatusBarColor(color.r, color.g, color.b, color.a)
                end
            end)
            
            unitFrame.castBar.VUIHooked = true
        end
    end
    
    -- Show the cast bar
    unitFrame.castBar:Show()
end

-- Set up texts (name and health)
function Hooks:SetupTexts(unitFrame)
    -- Configure name text
    if unitFrame.name then
        unitFrame.name:SetFont(Nameplates.settings.nameTextFont or "VUI PT Sans Narrow", 
                              Nameplates.settings.nameTextSize or 10,
                              Nameplates.settings.nameTextOutline or "OUTLINE")
        unitFrame.name:ClearAllPoints()
        unitFrame.name:SetPoint("BOTTOM", unitFrame.healthBar, "TOP", 0, 2)
    end
    
    -- Create health text if it doesn't exist
    if Nameplates.settings.showHealthText and not unitFrame.VUIHealthText then
        unitFrame.VUIHealthText = unitFrame:CreateFontString(nil, "OVERLAY")
        unitFrame.VUIHealthText:SetFont(Nameplates.settings.healthTextFont or "VUI PT Sans Narrow", 
                                      Nameplates.settings.healthTextSize or 10,
                                      Nameplates.settings.healthTextOutline or "OUTLINE")
        unitFrame.VUIHealthText:SetPoint("CENTER", unitFrame.healthBar, "CENTER", 0, 0)
    end
end

-- Set up indicators (target, focus, threat, execute)
function Hooks:SetupIndicators(unitFrame)
    -- Target highlight
    if Nameplates.settings.showTargetHighlight and not unitFrame.VUITargetHighlight then
        unitFrame.VUITargetHighlight = unitFrame:CreateTexture(nil, "BACKGROUND")
        unitFrame.VUITargetHighlight:SetAllPoints(unitFrame)
        unitFrame.VUITargetHighlight:SetColorTexture(1, 1, 1, 0.2)
        unitFrame.VUITargetHighlight:SetBlendMode("ADD")
        unitFrame.VUITargetHighlight:Hide()
    end
    
    -- Focus highlight
    if Nameplates.settings.showFocusHighlight and not unitFrame.VUIFocusHighlight then
        unitFrame.VUIFocusHighlight = unitFrame:CreateTexture(nil, "BACKGROUND")
        unitFrame.VUIFocusHighlight:SetAllPoints(unitFrame)
        unitFrame.VUIFocusHighlight:SetColorTexture(0, 1, 0, 0.2)
        unitFrame.VUIFocusHighlight:SetBlendMode("ADD")
        unitFrame.VUIFocusHighlight:Hide()
    end
    
    -- Threat indicator
    if Nameplates.settings.showThreatIndicator and not unitFrame.VUIThreatIndicator then
        if Nameplates.settings.threatWarningMode == "border" then
            unitFrame.VUIThreatIndicator = CreateFrame("Frame", nil, unitFrame)
            unitFrame.VUIThreatIndicator:SetAllPoints(unitFrame)
            unitFrame.VUIThreatIndicator:SetFrameLevel(unitFrame:GetFrameLevel() + 10)
            
            unitFrame.VUIThreatIndicator.texture = unitFrame.VUIThreatIndicator:CreateTexture(nil, "OVERLAY")
            unitFrame.VUIThreatIndicator.texture:SetAllPoints(unitFrame.VUIThreatIndicator)
            unitFrame.VUIThreatIndicator.texture:SetTexture("Interface\\AddOns\\VUI\\media\\nameplates\\border.svg")
            unitFrame.VUIThreatIndicator.texture:SetVertexColor(1, 0, 0, 0)
        elseif Nameplates.settings.threatWarningMode == "icon" then
            unitFrame.VUIThreatIndicator = unitFrame:CreateTexture(nil, "OVERLAY")
            unitFrame.VUIThreatIndicator:SetSize(16, 16)
            unitFrame.VUIThreatIndicator:SetPoint("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", -2, -2)
            unitFrame.VUIThreatIndicator:SetTexture("Interface\\AddOns\\VUI\\media\\threat.tga")
            unitFrame.VUIThreatIndicator:SetVertexColor(1, 0, 0, 0)
        elseif Nameplates.settings.threatWarningMode == "glow" then
            unitFrame.VUIThreatIndicator = unitFrame:CreateTexture(nil, "OVERLAY")
            unitFrame.VUIThreatIndicator:SetAllPoints(unitFrame)
            unitFrame.VUIThreatIndicator:SetTexture("Interface\\AddOns\\VUI\\media\\nameplates\\glow.svg")
            unitFrame.VUIThreatIndicator:SetBlendMode("ADD")
            unitFrame.VUIThreatIndicator:SetVertexColor(1, 0, 0, 0)
        else
            -- For color mode, we just need a placeholder to track state
            unitFrame.VUIThreatIndicator = {
                threatLevel = 0,
                Show = function() end,
                Hide = function() end,
                SetVertexColor = function() end
            }
        end
    end
    
    -- Execute indicator
    if Nameplates.settings.showExecuteIndicator and not unitFrame.VUIExecuteIndicator then
        unitFrame.VUIExecuteIndicator = unitFrame:CreateTexture(nil, "OVERLAY")
        unitFrame.VUIExecuteIndicator:SetAllPoints(unitFrame.healthBar)
        unitFrame.VUIExecuteIndicator:SetTexture("Interface\\AddOns\\VUI\\media\\nameplates\\execute.svg")
        unitFrame.VUIExecuteIndicator:SetBlendMode("ADD")
        unitFrame.VUIExecuteIndicator:SetVertexColor(1, 0, 0, 0.3)
        unitFrame.VUIExecuteIndicator:Hide()
    end
    
    -- Elite/Rare indicator
    if Nameplates.settings.showEliteIcon and not unitFrame.VUIEliteIndicator then
        unitFrame.VUIEliteIndicator = unitFrame:CreateTexture(nil, "OVERLAY")
        unitFrame.VUIEliteIndicator:SetSize(16, 16)
        unitFrame.VUIEliteIndicator:SetPoint("RIGHT", unitFrame.name, "LEFT", -2, 0)
        unitFrame.VUIEliteIndicator:Hide()
    end
    
    -- Raid marker
    if Nameplates.settings.showRaidMarks and not unitFrame.VUIRaidMarker then
        unitFrame.VUIRaidMarker = unitFrame:CreateTexture(nil, "OVERLAY")
        unitFrame.VUIRaidMarker:SetSize(16, 16)
        unitFrame.VUIRaidMarker:SetPoint("RIGHT", unitFrame, "LEFT", -2, 0)
        unitFrame.VUIRaidMarker:Hide()
    end
end

-- Update the health color of a nameplate
function Hooks:UpdateHealthColor(namePlate)
    if not namePlate or not namePlate.UnitFrame or not namePlate.UnitFrame.healthBar then return end
    
    local unitFrame = namePlate.UnitFrame
    local unit = unitFrame.namePlateUnitToken
    if not unit then return end
    
    -- Get the appropriate color based on class, reaction, threat, etc.
    local color = Nameplates.utils:GetHealthColor(unit, unitFrame)
    if color then
        unitFrame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
    end
end

-- Update the health text of a nameplate
function Hooks:UpdateHealthText(namePlate)
    if not namePlate or not namePlate.UnitFrame then return end
    
    local unitFrame = namePlate.UnitFrame
    local unit = unitFrame.namePlateUnitToken
    if not unit or not unitFrame.VUIHealthText then return end
    
    if Nameplates.settings.showHealthText then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        local format = Nameplates.settings.healthFormat or "percent"
        
        if health and maxHealth then
            local text = ""
            if format == "percent" then
                text = math.floor((health / maxHealth) * 100) .. "%"
            elseif format == "value" then
                text = Nameplates.utils:FormatNumber(health)
            elseif format == "both" then
                text = Nameplates.utils:FormatNumber(health) .. " - " .. math.floor((health / maxHealth) * 100) .. "%"
            end
            
            unitFrame.VUIHealthText:SetText(text)
            unitFrame.VUIHealthText:Show()
        else
            unitFrame.VUIHealthText:Hide()
        end
    else
        unitFrame.VUIHealthText:Hide()
    end
end

-- Update the target highlight of a nameplate
function Hooks:UpdateTargetHighlight(namePlate)
    if not namePlate or not namePlate.UnitFrame then return end
    
    local unitFrame = namePlate.UnitFrame
    local unit = unitFrame.namePlateUnitToken
    if not unit or not unitFrame.VUITargetHighlight then return end
    
    if Nameplates.settings.showTargetHighlight and UnitIsUnit(unit, "target") then
        local color = Nameplates.settings.targetHighlightColor
        unitFrame.VUITargetHighlight:SetColorTexture(color.r, color.g, color.b, color.a)
        unitFrame.VUITargetHighlight:Show()
    else
        unitFrame.VUITargetHighlight:Hide()
    end
end

-- Update the focus highlight of a nameplate
function Hooks:UpdateFocusHighlight(namePlate)
    if not namePlate or not namePlate.UnitFrame then return end
    
    local unitFrame = namePlate.UnitFrame
    local unit = unitFrame.namePlateUnitToken
    if not unit or not unitFrame.VUIFocusHighlight then return end
    
    if Nameplates.settings.showFocusHighlight and UnitIsUnit(unit, "focus") then
        local color = Nameplates.settings.focusHighlightColor
        unitFrame.VUIFocusHighlight:SetColorTexture(color.r, color.g, color.b, color.a)
        unitFrame.VUIFocusHighlight:Show()
    else
        unitFrame.VUIFocusHighlight:Hide()
    end
end

-- Update the threat indicator of a nameplate
function Hooks:UpdateThreat(namePlate)
    if not namePlate or not namePlate.UnitFrame then return end
    
    local unitFrame = namePlate.UnitFrame
    local unit = unitFrame.namePlateUnitToken
    if not unit or not unitFrame.VUIThreatIndicator then return end
    
    if not Nameplates.settings.showThreatIndicator then
        unitFrame.VUIThreatIndicator:Hide()
        return
    end
    
    -- Only show for enemies
    if UnitReaction(unit, "player") > 4 then
        unitFrame.VUIThreatIndicator:Hide()
        return
    end
    
    -- Get threat status
    local isTanking, status, threatPct = UnitDetailedThreatSituation("player", unit)
    local alpha = 0
    local r, g, b = 0, 0, 0
    
    -- Determine coloring based on role
    local role = GetSpecializationRole(GetSpecialization())
    if role == "TANK" and Nameplates.settings.tankMode then
        if status == 3 then -- Solid aggro
            r, g, b = 0, 0.8, 0
            alpha = 1
        elseif status == 2 then -- Insecure aggro
            r, g, b = 0.8, 0.8, 0
            alpha = 1
        elseif status then -- No aggro but on threat table
            r, g, b = 0.8, 0, 0
            alpha = threatPct and (threatPct / 100) or 0.5
        end
    else
        if status == 3 then -- Solid aggro
            r, g, b = 0.8, 0, 0
            alpha = 1
        elseif status == 2 then -- Insecure aggro
            r, g, b = 0.8, 0.8, 0
            alpha = 0.8
        elseif status == 1 then -- Higher threat
            r, g, b = 1.0, 0.5, 0
            alpha = 0.5
        elseif status then -- Low threat
            r, g, b = 0, 0.8, 0
            alpha = 0.3
        end
    end
    
    -- Update the indicator based on threat
    if Nameplates.settings.threatWarningMode == "color" then
        -- For color mode, update the health bar color
        if alpha > 0 then
            unitFrame.healthBar:SetStatusBarColor(r, g, b)
            unitFrame.VUIThreatIndicator.threatLevel = status or 0
        else
            -- Reset to default color if no threat
            self:UpdateHealthColor(namePlate)
            unitFrame.VUIThreatIndicator.threatLevel = 0
        end
    else
        if alpha > 0 then
            unitFrame.VUIThreatIndicator:SetVertexColor(r, g, b, alpha)
            unitFrame.VUIThreatIndicator:Show()
        else
            unitFrame.VUIThreatIndicator:Hide()
        end
    end
end

-- Update the execute indicator of a nameplate
function Hooks:UpdateExecuteIndicator(namePlate)
    if not namePlate or not namePlate.UnitFrame then return end
    
    local unitFrame = namePlate.UnitFrame
    local unit = unitFrame.namePlateUnitToken
    if not unit or not unitFrame.VUIExecuteIndicator then return end
    
    -- Check if unit is in execute range
    if Nameplates.utils:IsInExecuteRange(unit) then
        unitFrame.VUIExecuteIndicator:Show()
    else
        unitFrame.VUIExecuteIndicator:Hide()
    end
end

-- Apply border to an element
function Hooks:ApplyBorder(element, borderType)
    if not element then return end
    
    -- Remove existing border
    if element.VUIBorder then
        element.VUIBorder:Hide()
        element.VUIBorder = nil
    end
    
    -- Exit if no border desired
    if not borderType or borderType == "none" then
        return
    end
    
    -- Create new border based on type
    element.VUIBorder = CreateFrame("Frame", nil, element)
    element.VUIBorder:SetFrameLevel(element:GetFrameLevel() + 1)
    
    if borderType == "thin" then
        element.VUIBorder:SetPoint("TOPLEFT", element, "TOPLEFT", -1, 1)
        element.VUIBorder:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 1, -1)
        element.VUIBorder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        element.VUIBorder:SetBackdropBorderColor(0, 0, 0, 1)
    elseif borderType == "thick" then
        element.VUIBorder:SetPoint("TOPLEFT", element, "TOPLEFT", -2, 2)
        element.VUIBorder:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 2, -2)
        element.VUIBorder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 2,
        })
        element.VUIBorder:SetBackdropBorderColor(0, 0, 0, 1)
    elseif borderType == "gloss" then
        element.VUIBorder:SetAllPoints(element)
        
        local texture = element.VUIBorder:CreateTexture(nil, "OVERLAY")
        texture:SetAllPoints(element.VUIBorder)
        texture:SetTexture("Interface\\AddOns\\VUI\\media\\gloss.tga")
        texture:SetVertexColor(1, 1, 1, 0.3)
        texture:SetBlendMode("ADD")
        
        element.VUIBorder.texture = texture
    end
end

-- Run a custom script
function Hooks:RunCustomScript(scriptName, namePlate, unit)
    if not scriptName or not Nameplates.settings.customScripts[scriptName] then
        return
    end
    
    -- Prepare environment for the script
    local env = {
        plate = namePlate,
        unitFrame = namePlate.UnitFrame,
        unit = unit,
        health = UnitHealth(unit),
        maxHealth = UnitHealthMax(unit),
        power = UnitPower(unit),
        maxPower = UnitPowerMax(unit),
        level = UnitLevel(unit),
        name = UnitName(unit),
        settings = Nameplates.settings,
        utils = Nameplates.utils,
    }
    
    -- Set metatable to access globals
    setmetatable(env, {__index = _G})
    
    -- Create the function from the script
    local func, errorMsg = loadstring("return function(plate, unitFrame, unit) " .. Nameplates.settings.customScripts[scriptName] .. " end")
    if not func then
        print("VUI Plater: Error in " .. scriptName .. " script: " .. (errorMsg or "unknown error"))
        return
    end
    
    -- Set environment and execute
    setfenv(func, env)
    
    local success, result = pcall(func(), namePlate, namePlate.UnitFrame, unit)
    if not success then
        print("VUI Plater: Error running " .. scriptName .. " script: " .. (result or "unknown error"))
    end
end