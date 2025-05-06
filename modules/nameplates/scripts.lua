local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local Nameplates = VUI.nameplates

-- Custom scripts for VUI Plater
Nameplates.scripts = {}
local Scripts = Nameplates.scripts

-- Initialize scripts
function Scripts:Initialize()
    -- Setup default script templates if needed
    if not Nameplates.settings.customScripts then
        Nameplates.settings.customScripts = {}
    end
    
    -- Setup default templates for each script type
    self:SetupDefaultScripts()
end

-- Setup default scripts
function Scripts:SetupDefaultScripts()
    -- Create plate script (runs when plate is first created)
    if not Nameplates.settings.customScripts.createPlate then
        Nameplates.settings.customScripts.createPlate = [[
-- VUI Plater: Custom Create Plate Script
-- This runs when a nameplate is first created
-- Use this for initial setup and customization

-- Example: Add a custom texture to enemy nameplates
if UnitReaction(unit, "player") <= 4 then
    if not unitFrame.customTexture then
        unitFrame.customTexture = unitFrame:CreateTexture(nil, "OVERLAY")
        unitFrame.customTexture:SetSize(16, 16)
        unitFrame.customTexture:SetPoint("LEFT", unitFrame, "RIGHT", 2, 0)
        unitFrame.customTexture:SetTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8")
        unitFrame.customTexture:SetDesaturated(true)
    end
end
]]
    end
    
    -- Update plate script (runs frequently)
    if not Nameplates.settings.customScripts.updatePlate then
        Nameplates.settings.customScripts.updatePlate = [[
-- VUI Plater: Custom Update Plate Script
-- This runs on each plate update
-- Use this for frequent checks and updates

-- Example: Add special border for important NPCs
local npcID = tonumber(UnitGUID(unit):match("Creature%-0%-%d+%-%d+%-%d+%-(%d+)"))
if npcID then
    local importantNPCs = {
        [142668] = true, -- Irontide Enforcer
        [142669] = true, -- Irontide Crusher
        -- Add your own important NPCs here
    }
    
    if importantNPCs[npcID] then
        unitFrame.healthBar:SetBackdropBorderColor(1, 0, 0, 1)
    else
        unitFrame.healthBar:SetBackdropBorderColor(0, 0, 0, 1)
    end
end
]]
    end
    
    -- Plate added script (runs when plate appears)
    if not Nameplates.settings.customScripts.plateAdded then
        Nameplates.settings.customScripts.plateAdded = [[
-- VUI Plater: Custom Plate Added Script
-- This runs when a nameplate appears
-- Use this for initial setup that requires the unit to be fully loaded

-- Example: Make important NPCs have a bigger nameplate
local npcID = tonumber(UnitGUID(unit):match("Creature%-0%-%d+%-%d+%-%d+%-(%d+)"))
if npcID then
    local importantBosses = {
        [142665] = true, -- Dungeon Boss Example
        [142666] = true, -- Raid Boss Example
        -- Add your own important bosses here
    }
    
    if importantBosses[npcID] then
        unitFrame:SetScale(1.2)
    else
        unitFrame:SetScale(1.0)
    end
end
]]
    end
    
    -- Plate removed script (runs when plate disappears)
    if not Nameplates.settings.customScripts.plateRemoved then
        Nameplates.settings.customScripts.plateRemoved = [[
-- VUI Plater: Custom Plate Removed Script
-- This runs when a nameplate disappears
-- Use this for cleanup or tracking

-- Example: Track when boss nameplates disappear (for encounter tracking)
local npcID = tonumber(UnitGUID(unit):match("Creature%-0%-%d+%-%d+%-%d+%-(%d+)"))
if npcID then
    local bosses = {
        [142665] = true, -- Dungeon Boss Example
        [142666] = true, -- Raid Boss Example
        -- Add your own bosses here
    }
    
    if bosses[npcID] then
        -- You could do something when a boss disappears
        -- Like print a message or track encounter progress
    end
end
]]
    end
    
    -- Add additional Whiiskey special effects scripts
    self:SetupWhiiskeyScripts()
end

-- Whiiskey special effects scripts
function Scripts:SetupWhiiskeyScripts()
    -- Cast Interruption flashing effect
    if not Nameplates.settings.customScripts.castInterrupted then
        Nameplates.settings.customScripts.castInterrupted = [[
-- VUI Plater: Cast Interruption Effect
-- This creates a flash effect when a cast is interrupted

if unitFrame.castBar and unitFrame.castBar:IsShown() then
    -- Create the flash effect if it doesn't exist
    if not unitFrame.castBar.flashInterrupt then
        unitFrame.castBar.flashInterrupt = unitFrame.castBar:CreateTexture(nil, "OVERLAY")
        unitFrame.castBar.flashInterrupt:SetAllPoints(unitFrame.castBar)
        unitFrame.castBar.flashInterrupt:SetColorTexture(1, 0, 0, 0.8)
        unitFrame.castBar.flashInterrupt:SetBlendMode("ADD")
        unitFrame.castBar.flashInterrupt:Hide()
        
        -- Create animation for the flash
        unitFrame.castBar.flashAnim = unitFrame.castBar.flashInterrupt:CreateAnimationGroup()
        local fade = unitFrame.castBar.flashAnim:CreateAnimation("Alpha")
        fade:SetFromAlpha(0.8)
        fade:SetToAlpha(0)
        fade:SetDuration(0.3)
        fade:SetSmoothing("OUT")
        unitFrame.castBar.flashAnim:SetScript("OnFinished", function()
            unitFrame.castBar.flashInterrupt:Hide()
        end)
    end
    
    -- Hook into the cast bar's Stop method
    if not unitFrame.castBar.interruptHooked then
        hooksecurefunc(unitFrame.castBar, "OnHide", function(self)
            if self.notInterruptible == false and not self.finished and self.value < self.maxValue then
                -- If the cast was interrupted, show the flash
                self.flashInterrupt:Show()
                self.flashAnim:Play()
            end
        end)
        unitFrame.castBar.interruptHooked = true
    end
end
]]
    end
    
    -- Health bar animation effect
    if not Nameplates.settings.customScripts.healthAnimation then
        Nameplates.settings.customScripts.healthAnimation = [[
-- VUI Plater: Health Animation Effect
-- This creates a smooth animation when health changes

if unitFrame.healthBar then
    if not unitFrame.healthBar.animatedHealthBar then
        -- Create an animated health overlay
        unitFrame.healthBar.animatedHealthBar = CreateFrame("StatusBar", nil, unitFrame.healthBar)
        unitFrame.healthBar.animatedHealthBar:SetAllPoints(unitFrame.healthBar)
        unitFrame.healthBar.animatedHealthBar:SetStatusBarTexture(unitFrame.healthBar:GetStatusBarTexture():GetTexture())
        unitFrame.healthBar.animatedHealthBar:SetStatusBarColor(1, 0, 0, 0.5)
        unitFrame.healthBar.animatedHealthBar:SetFrameLevel(unitFrame.healthBar:GetFrameLevel() - 1)
        unitFrame.healthBar.animatedHealthBar:Hide()
        
        -- Create animation for smooth transitions
        unitFrame.healthBar.healthAnim = unitFrame.healthBar.animatedHealthBar:CreateAnimationGroup()
        unitFrame.healthBar.healthAnim.width = unitFrame.healthBar.healthAnim:CreateAnimation("Width")
        unitFrame.healthBar.healthAnim.width:SetDuration(0.2)
        unitFrame.healthBar.healthAnim.width:SetSmoothing("OUT")
        unitFrame.healthBar.healthAnim:SetScript("OnFinished", function()
            unitFrame.healthBar.animatedHealthBar:Hide()
        end)
        
        -- Track health changes
        unitFrame.healthBar.oldHealth = UnitHealth(unit)
        unitFrame.healthBar.oldHealthMax = UnitHealthMax(unit)
        
        -- Health change handler
        unitFrame.healthBar.healthChangeCheck = CreateFrame("Frame", nil, unitFrame.healthBar)
        unitFrame.healthBar.healthChangeCheck:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = (self.elapsed or 0) + elapsed
            if self.elapsed < 0.1 then return end
            self.elapsed = 0
            
            local health = UnitHealth(unit)
            local healthMax = UnitHealthMax(unit)
            
            if health < unitFrame.healthBar.oldHealth and health > 0 then
                -- Health loss animation
                local width = unitFrame.healthBar:GetWidth() * (unitFrame.healthBar.oldHealth / unitFrame.healthBar.oldHealthMax)
                local newWidth = unitFrame.healthBar:GetWidth() * (health / healthMax)
                
                unitFrame.healthBar.animatedHealthBar:SetWidth(width)
                unitFrame.healthBar.animatedHealthBar:Show()
                
                unitFrame.healthBar.healthAnim.width:SetFromWidth(width)
                unitFrame.healthBar.healthAnim.width:SetToWidth(newWidth)
                unitFrame.healthBar.healthAnim:Play()
            end
            
            unitFrame.healthBar.oldHealth = health
            unitFrame.healthBar.oldHealthMax = healthMax
        end)
    end
end
]]
    end
    
    -- Target Highlight Pulse Animation
    if not Nameplates.settings.customScripts.targetPulse then
        Nameplates.settings.customScripts.targetPulse = [[
-- VUI Plater: Target Pulse Animation
-- This creates a pulsing effect around your current target

if UnitIsUnit(unit, "target") and UnitExists("target") then
    if not unitFrame.targetPulse then
        -- Create the pulse overlay
        unitFrame.targetPulse = CreateFrame("Frame", nil, unitFrame)
        unitFrame.targetPulse:SetFrameLevel(unitFrame:GetFrameLevel() - 1)
        unitFrame.targetPulse:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", -10, 10)
        unitFrame.targetPulse:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", 10, -10)
        
        -- Create the pulse texture
        unitFrame.targetPulse.texture = unitFrame.targetPulse:CreateTexture(nil, "BACKGROUND")
        unitFrame.targetPulse.texture:SetAllPoints(unitFrame.targetPulse)
        unitFrame.targetPulse.texture:SetTexture("Interface\\AddOns\\VUI\\media\\glow.tga")
        unitFrame.targetPulse.texture:SetBlendMode("ADD")
        unitFrame.targetPulse.texture:SetVertexColor(1, 1, 1, 0.4)
        
        -- Create pulse animation
        unitFrame.targetPulse.anim = unitFrame.targetPulse.texture:CreateAnimationGroup()
        unitFrame.targetPulse.anim:SetLooping("REPEAT")
        
        -- Alpha animation
        local fadeOut = unitFrame.targetPulse.anim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.4)
        fadeOut:SetToAlpha(0.1)
        fadeOut:SetDuration(0.8)
        fadeOut:SetOrder(1)
        
        local fadeIn = unitFrame.targetPulse.anim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0.1)
        fadeIn:SetToAlpha(0.4)
        fadeIn:SetDuration(0.8)
        fadeIn:SetOrder(2)
        
        -- Start the animation
        unitFrame.targetPulse.anim:Play()
    end
    
    unitFrame.targetPulse:Show()
else
    if unitFrame.targetPulse then
        unitFrame.targetPulse:Hide()
    end
end
]]
    end
    
    -- Class/Spec Icon for Player Nameplates
    if not Nameplates.settings.customScripts.classIcon then
        Nameplates.settings.customScripts.classIcon = [[
-- VUI Plater: Class/Spec Icons
-- This adds class and spec icons to player nameplates

if UnitIsPlayer(unit) then
    local _, class = UnitClass(unit)
    if class then
        -- Create class icon if needed
        if not unitFrame.classIcon then
            unitFrame.classIcon = unitFrame:CreateTexture(nil, "OVERLAY")
            unitFrame.classIcon:SetSize(16, 16)
            unitFrame.classIcon:SetPoint("RIGHT", unitFrame.name, "LEFT", -2, 0)
            
            -- Create spec icon
            unitFrame.specIcon = unitFrame:CreateTexture(nil, "OVERLAY")
            unitFrame.specIcon:SetSize(12, 12)
            unitFrame.specIcon:SetPoint("TOPRIGHT", unitFrame.classIcon, "BOTTOMRIGHT", 0, 0)
        end
        
        -- Set class icon
        if CLASS_ICON_TCOORDS[class] then
            unitFrame.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
            local coords = CLASS_ICON_TCOORDS[class]
            unitFrame.classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            unitFrame.classIcon:Show()
            
            -- Try to get specialization
            local guid = UnitGUID(unit)
            if guid then
                local specID = GetInspectSpecialization(unit)
                if specID and specID > 0 then
                    local _, _, _, icon = GetSpecializationInfoByID(specID)
                    if icon then
                        unitFrame.specIcon:SetTexture(icon)
                        unitFrame.specIcon:Show()
                    else
                        unitFrame.specIcon:Hide()
                    end
                else
                    unitFrame.specIcon:Hide()
                    
                    -- Request inspect if it's a player and not yourself
                    if not UnitIsUnit(unit, "player") and CanInspect(unit) then
                        NotifyInspect(unit)
                    end
                end
            end
        else
            unitFrame.classIcon:Hide()
            unitFrame.specIcon:Hide()
        end
    else
        if unitFrame.classIcon then
            unitFrame.classIcon:Hide()
            unitFrame.specIcon:Hide()
        end
    end
else
    if unitFrame.classIcon then
        unitFrame.classIcon:Hide()
        unitFrame.specIcon:Hide()
    end
end
]]
    end
end

-- Load a script based on script name
function Scripts:LoadScript(scriptName)
    if not scriptName or not Nameplates.settings.customScripts[scriptName] then
        return nil, "Script not found: " .. (scriptName or "nil")
    end
    
    local func, errorMsg = loadstring("return " .. Nameplates.settings.customScripts[scriptName])
    if not func then
        return nil, "Error loading script: " .. (errorMsg or "unknown error")
    end
    
    return func()
end

-- Run a script on a unit frame
function Scripts:RunScript(scriptName, unitFrame, unit)
    if not scriptName or not unitFrame or not unit then
        return false, "Missing required parameters"
    end
    
    local script, errorMsg = self:LoadScript(scriptName)
    if not script then
        return false, errorMsg
    end
    
    -- Create environment for the script
    local env = {
        unitFrame = unitFrame,
        unit = unit,
        UnitGUID = UnitGUID,
        UnitName = UnitName,
        UnitClass = UnitClass,
        UnitIsPlayer = UnitIsPlayer,
        UnitHealth = UnitHealth,
        UnitHealthMax = UnitHealthMax,
        UnitPower = UnitPower,
        UnitPowerMax = UnitPowerMax,
        UnitLevel = UnitLevel,
        UnitReaction = UnitReaction,
        UnitIsUnit = UnitIsUnit,
        SetCVar = SetCVar,
        GetCVar = GetCVar,
        print = print,
        pairs = pairs,
        ipairs = ipairs,
        time = time,
        math = math,
        table = table,
        string = string,
        tonumber = tonumber,
        tostring = tostring,
        type = type
    }
    
    -- Set environment
    setfenv(script, env)
    
    -- Execute the script
    local success, result = pcall(script)
    if not success then
        return false, "Error executing script: " .. (result or "unknown error")
    end
    
    return true
end

-- Save a script
function Scripts:SaveScript(scriptName, scriptCode)
    if not scriptName or not scriptCode then
        return false, "Missing required parameters"
    end
    
    -- Validate script
    local func, errorMsg = loadstring("return " .. scriptCode)
    if not func then
        return false, "Invalid script: " .. (errorMsg or "unknown error")
    end
    
    -- Save the script
    Nameplates.settings.customScripts[scriptName] = scriptCode
    return true
end

-- Delete a script
function Scripts:DeleteScript(scriptName)
    if not scriptName then
        return false, "Missing script name"
    end
    
    Nameplates.settings.customScripts[scriptName] = nil
    return true
end