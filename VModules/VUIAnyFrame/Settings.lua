-- VUIAnyFrame - Settings Handler
local AddonName, VUI = ...
local M = _G["VUIAnyFrame"]
local L = M.L

-- Constants for settings
local PREFIX = "VUI"
local keybinds = {}
keybinds[1] = "SHIFT"
keybinds[2] = "CTRL"
keybinds[3] = "ALT"

-- EditMode forced elements (for Retail WoW)
local EMMapForced = {}
function M:AddToEMMapForced(key)
    EMMapForced[key] = true
    EMMapForced[strupper(key)] = true
end

-- Add common frames to forced EditMode map
M:AddToEMMapForced("Minimap")
M:AddToEMMapForced("MinimapCluster")
M:AddToEMMapForced("PlayerFrame")
M:AddToEMMapForced("ObjectiveTrackerFrame")
M:AddToEMMapForced("QuestTracker")
M:AddToEMMapForced("ChatFrame1")
M:AddToEMMapForced("Chat")
M:AddToEMMapForced("GameTooltip")
M:AddToEMMapForced("Castingbar")
M:AddToEMMapForced("MainMenuBar")
M:AddToEMMapForced("MultiBarBottomLeft")
M:AddToEMMapForced("MultiBarBottomRight")
M:AddToEMMapForced("MultiBarRight")
M:AddToEMMapForced("MultiBarLeft")
M:AddToEMMapForced("MultiBar5")
M:AddToEMMapForced("MultiBar6")
M:AddToEMMapForced("MultiBar7")
M:AddToEMMapForced("MainStatusTrackingBarContainer")

for i = 1, 8 do
    M:AddToEMMapForced("ACTIONBAR" .. i)
end

-- EditMode map for Blizzard edit mode
local EMMap = {}
function M:AddToEMMap(key, value)
    EMMap[key] = value
    EMMap[strupper(key)] = value
end

-- Add standard mappings
M:AddToEMMap("MAPetBar", "ShowPetActionBar")
M:AddToEMMap("PetBar", "ShowPetActionBar")
M:AddToEMMap("PetActionBar", "ShowPetActionBar")
M:AddToEMMap("StanceBar", "ShowStanceBar")
M:AddToEMMap("MAGameTooltip", "ShowHudTooltip")
M:AddToEMMap("TalkingHeadFrame", "ShowTalkingHeadFrame")
M:AddToEMMap("TalkingHead", "ShowTalkingHeadFrame")
M:AddToEMMap("Buffs", "ShowBuffsAndDebuffs")
M:AddToEMMap("BuffFrame", "ShowBuffsAndDebuffs")
M:AddToEMMap("MABuffBar", "ShowBuffsAndDebuffs")
M:AddToEMMap("Debuffs", "ShowBuffsAndDebuffs")
M:AddToEMMap("DebuffFrame", "ShowBuffsAndDebuffs")
M:AddToEMMap("MADebuffBar", "ShowBuffsAndDebuffs")
M:AddToEMMap("TargetFrame", "ShowTargetAndFocus")
M:AddToEMMap("FocusFrame", "ShowTargetAndFocus")
M:AddToEMMap("ExtraAbilityFrame", "ShowExtraAbilities")
M:AddToEMMap("ExtraAbilityContainer", "ShowExtraAbilities")
M:AddToEMMap("PossessActionBar", "ShowPossessActionBar")
M:AddToEMMap("PossessBarFrame", "ShowPossessActionBar")
M:AddToEMMap("PossessBar", "ShowPossessActionBar")
M:AddToEMMap("MainMenuBarVehicleLeaveButton", "ShowVehicleLeaveButton")
M:AddToEMMap("LeaveVehicle", "ShowVehicleLeaveButton")
M:AddToEMMap("PlayerCastingBarFrame", "ShowCastBar")
M:AddToEMMap("PetFrame", "ShowPetFrame")
M:AddToEMMap("MAPetFrame", "ShowPetFrame")
M:AddToEMMap("BossTargetFrameContainer", "ShowBossFrames")
M:AddToEMMap("SecondaryStatusTrackingBarContainer", "ShowStatusTrackingBar2")
M:AddToEMMap("VehicleSeatIndicator", "ShowVehicleSeatIndicator")
M:AddToEMMap("MAVehicleSeatIndicator", "ShowVehicleSeatIndicator")
M:AddToEMMap("PartyFrame", "ShowPartyFrames")
M:AddToEMMap("CompactRaidFrameContainer", "ShowRaidFrames")
M:AddToEMMap("CompactArenaFrame", "ShowArenaFrames")

-- Check if Blizzard's Edit Mode is enabled (for Retail WoW)
function M:IsBlizEditModeEnabled()
    if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) or (EditModeManagerFrame and EditModeManagerFrame.numLayouts) then 
        return true 
    end
    return false
end

-- Check if a frame is enabled in Edit Mode
function M:IsInEditModeEnabled(val)
    local editModeEnum = nil
    
    if not M:IsBlizEditModeEnabled() then 
        return false, false 
    end
    
    if EMMapForced[val] then 
        return true, true 
    end
    
    if Enum and Enum.EditModeAccountSetting then
        if EMMap[val] then
            editModeEnum = Enum.EditModeAccountSetting[EMMap[val]]
        else
            editModeEnum = Enum.EditModeAccountSetting[val]
        end
    end

    if EditModeManagerFrame and EditModeManagerFrame.accountSettings == nil then
        EditModeManagerFrame:InitializeAccountSettings()
    end

    if GameMenuButtonEditMode and not GameMenuButtonEditMode:IsEnabled() then
        GameMenuButtonEditMode:SetEnabled(true)
    end

    if editModeEnum and EditModeManagerFrame and 
       tContains(Enum.EditModeAccountSetting, editModeEnum) and 
       EditModeManagerFrame:GetAccountSettingValueBool(editModeEnum) then 
        return true, false 
    end

    return false, false
end

-- Initialize settings
function M:InitSettings()
    -- Check if the settings are already in VUI's DB
    if not self.db then
        -- Fall back to creating a standalone DB
        if LibStub then
            self.db = LibStub("AceDB-3.0"):New("VUIAnyFrameDB", self.defaults)
        else
            -- If AceDB-3.0 isn't available, create a basic placeholder
            self.db = {
                profile = self.defaults.profile
            }
        end
    end

    -- Register profile change callback
    if type(self.db.RegisterCallback) == "function" then
        self.db:RegisterCallback("OnProfileChanged", function()
            self:ProfileChanged()
        end)
        self.db:RegisterCallback("OnProfileCopied", function()
            self:ProfileChanged()
        end)
        self.db:RegisterCallback("OnProfileReset", function()
            self:ProfileChanged()
        end)
    end

    -- Set up LibDBIcon for minimap button if available
    if LibStub and LibStub("LibDBIcon-1.0", true) and not self.minimapIconRegistered then
        local LDBIcon = LibStub("LibDBIcon-1.0", true)
        if LDBIcon then
            self:SetupDataBroker()
        end
    end
    
    -- Create settings UI defaults
    self:InitSettingsUI()
end

-- Initialize settings UI
function M:InitSettingsUI()
    -- Will contain UI elements for managing settings
    self.settingsUI = {}
end

-- Save frame settings
function M:SaveFrameSettings(frameName, settings)
    if not frameName or type(settings) ~= "table" then return end
    
    -- Make sure frames table exists
    if not self.db.profile.frames then
        self.db.profile.frames = {}
    end
    
    -- Save settings
    self.db.profile.frames[frameName] = settings
    
    -- Sync with VUI if integrated
    if self.SyncSettingsToVUI then
        self:SyncSettingsToVUI()
    end
end

-- Save individual frame setting
function M:SaveFrameSetting(frameName, key, value)
    if not frameName or not key then return end
    
    -- Make sure frames table exists
    if not self.db.profile.frames then
        self.db.profile.frames = {}
    end
    
    -- Make sure frame exists in settings
    if not self.db.profile.frames[frameName] then
        self.db.profile.frames[frameName] = {}
    end
    
    -- Save setting
    self.db.profile.frames[frameName][key] = value
    
    -- Sync with VUI if integrated
    if self.SyncSettingsToVUI then
        self:SyncSettingsToVUI()
    end
    
    return value
end

-- Get individual frame setting
function M:GetFrameSetting(frameName, key, default)
    if not frameName or not key or not self.db.profile.frames or not self.db.profile.frames[frameName] then
        return default
    end
    
    local value = self.db.profile.frames[frameName][key]
    if value == nil then
        return default
    end
    
    return value
end

-- Get frame settings
function M:GetFrameSettings(frameName)
    if not frameName or not self.db.profile.frames then return nil end
    return self.db.profile.frames[frameName]
end

-- Reset all frame settings
function M:ResetAllFrameSettings()
    -- Reset the frames table
    self.db.profile.frames = {}
    
    -- Sync with VUI if integrated
    if self.SyncSettingsToVUI then
        self:SyncSettingsToVUI()
    end
    
    -- Apply reset (restore default positions)
    C_Timer.After(0.1, function()
        self:ApplySettings()
    end)
end

-- Reset specific frame settings
function M:ResetFrameSettings(frameName)
    if not frameName or not self.db.profile.frames then return end
    
    -- Remove frame settings
    self.db.profile.frames[frameName] = nil
    
    -- Sync with VUI if integrated
    if self.SyncSettingsToVUI then
        self:SyncSettingsToVUI()
    end
end

-- Toggle a setting value
function M:ToggleSetting(settingName)
    if not settingName then return end
    
    -- Handle different levels of settings
    if settingName:find("%.") then
        -- Nested setting (category.setting)
        local category, setting = strsplit(".", settingName)
        if category and setting and self.db.profile[category] then
            if type(self.db.profile[category][setting]) == "boolean" then
                self.db.profile[category][setting] = not self.db.profile[category][setting]
                return self.db.profile[category][setting]
            end
        end
    else
        -- Top-level setting
        if type(self.db.profile[settingName]) == "boolean" then
            self.db.profile[settingName] = not self.db.profile[settingName]
            return self.db.profile[settingName]
        end
    end
    
    return nil
end

-- Set a setting value
function M:SetSetting(settingName, value)
    if not settingName then return end
    
    -- Handle different levels of settings
    if settingName:find("%.") then
        -- Nested setting (category.setting)
        local category, setting = strsplit(".", settingName)
        if category and setting and self.db.profile[category] then
            self.db.profile[category][setting] = value
            return true
        end
    else
        -- Top-level setting
        self.db.profile[settingName] = value
        return true
    end
    
    return false
end

-- Get a setting value
function M:GetSetting(settingName)
    if not settingName then return nil end
    
    -- Handle different levels of settings
    if settingName:find("%.") then
        -- Nested setting (category.setting)
        local category, setting = strsplit(".", settingName)
        if category and setting and self.db.profile[category] then
            return self.db.profile[category][setting]
        end
    else
        -- Top-level setting
        return self.db.profile[settingName]
    end
    
    return nil
end

-- Set Blizzard frame visibility
function M:SetBlizzardFrameVisibility(frameName, hidden)
    if not frameName then return false end
    
    -- Make sure hideBlizzardFrames table exists
    if not self.db.profile.global.hideBlizzardFrames then
        self.db.profile.global.hideBlizzardFrames = {}
    end
    
    -- Update setting
    self.db.profile.global.hideBlizzardFrames[frameName] = hidden
    
    -- Apply visibility change
    local frame = _G[frameName]
    if frame then
        if hidden then
            M:HideFrame(frame)
        else
            M:ShowFrame(frame)
        end
        return true
    end
    
    return false
end

-- Get Blizzard frame visibility
function M:GetBlizzardFrameVisibility(frameName)
    if not frameName or not self.db.profile.global.hideBlizzardFrames then return false end
    return self.db.profile.global.hideBlizzardFrames[frameName] or false
end

-- Apply all settings
function M:ApplySettings()
    if InCombatLockdown() then
        C_Timer.After(0.5, function() self:ApplySettings() end)
        return
    end
    
    -- Skip if addon is disabled
    if not self.db.profile.enabled then
        self:Print("Module is disabled. Settings not applied.")
        return
    end
    
    -- Apply frame visibility settings
    if self.db.profile.global.hideBlizzardFrames then
        for frameName, hidden in pairs(self.db.profile.global.hideBlizzardFrames) do
            local frame = _G[frameName]
            if frame then
                if hidden then
                    M:HideFrame(frame)
                else
                    M:ShowFrame(frame)
                end
            end
        end
    end
    
    -- Apply saved frame positions and scales
    if self.db.profile.frames then
        for frameName, settings in pairs(self.db.profile.frames) do
            -- Look for the frame in the global environment
            local frame = _G[frameName]
            
            -- If it's not found by name, check in our mover frames
            if not frame then
                for _, df in pairs(M:GetDragFrames()) do
                    if df.mover and df.mover.name == frameName then
                        frame = df.mover.frame
                        break
                    end
                end
            end
            
            -- Apply settings if frame exists
            if frame then
                -- Apply position
                if settings.x and settings.y then
                    M:SetPosition(frame, settings.x, settings.y)
                end
                
                -- Apply scale
                if settings.scale and not InCombatLockdown() then
                    frame:SetScale(settings.scale)
                end
                
                -- Apply visibility
                if settings.hidden then
                    M:HideFrame(frame)
                else
                    M:ShowFrame(frame)
                end
            end
        end
    end
    
    -- Auto-lock if lockFrames is enabled
    if self.db.profile.global.lockFrames then
        self:Lock()
    else
        self:Unlock()
    end
    
    -- Update any movers to match current frame positions
    self:UpdateAllFrames()
end

-- Update all mover frames to match target frames
function M:UpdateAllFrames()
    -- Skip if in combat
    if InCombatLockdown() then
        C_Timer.After(0.5, function() self:UpdateAllFrames() end)
        return
    end
    
    -- Update each mover
    for _, df in pairs(M:GetDragFrames()) do
        if df.mover and df.mover.frame then
            local frame = df.mover.frame
            local moverBG = df.bg
            
            -- Get frame position and scale
            local scale = frame:GetScale()
            local x, y = M:GetPosition(frame)
            
            -- Update mover position and scale
            moverBG:SetScale(scale)
            moverBG:ClearAllPoints()
            moverBG:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
            
            -- Update frame size
            local width, height = frame:GetSize()
            if width < 10 then width = 10 end
            if height < 10 then height = 10 end
            
            moverBG:SetSize(width, height)
            df.mover:SetSize(width, height)
        end
    end
end

-- Profile changed callback
function M:ProfileChanged()
    -- Apply settings from the new profile
    C_Timer.After(0.5, function()
        self:ApplySettings()
    end)
    
    self:Print("Profile changed, reapplying settings")
end

-- Set up DataBroker and minimap button
function M:SetupDataBroker()
    if not LibStub then return end
    
    -- Create LibDataBroker object for minimap button
    local LDB = LibStub:GetLibrary("LibDataBroker-1.1", true)
    if not LDB then return end
    
    self.dataObject = LDB:NewDataObject("VUIAnyFrame", {
        type = "data source",
        text = "VUIAnyFrame",
        icon = "Interface\\AddOns\\VUI\\VModules\\VUIAnyFrame\\Media\\icon",
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:ToggleLock()
            elseif button == "RightButton" then
                self:OpenOptions()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("VUI AnyFrame")
            tooltip:AddLine(" ")
            tooltip:AddLine("Left-click: Lock/Unlock frames")
            tooltip:AddLine("Right-click: Open options")
        end
    })
    
    -- Register with LibDBIcon for minimap button
    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if LDBIcon then
        LDBIcon:Register("VUIAnyFrame", self.dataObject, self.db.profile.minimap)
        self.minimapIconRegistered = true
    end
end

-- Open configuration options
function M:OpenOptions()
    -- Use VUI's built-in config if available
    if VUI and VUI.Config and type(VUI.Config.OpenModule) == "function" then
        VUI.Config:OpenModule("VUIAnyFrame")
    else
        -- Fall back to AceConfigDialog if available
        if LibStub and LibStub("AceConfigDialog-3.0", true) then
            local AceConfigDialog = LibStub("AceConfigDialog-3.0")
            AceConfigDialog:Open("VUIAnyFrame")
        else
            self:Print("Configuration options not available")
        end
    end
end 