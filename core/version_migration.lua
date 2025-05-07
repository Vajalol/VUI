--[[
    VUI - Version Migration System
    Version: 1.0.0
    Author: VortexQ8
    
    This file handles version detection and settings migration between different
    versions of the addon to ensure smooth upgrades.
]]

local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the Migration module if it doesn't exist
if not VUI.Migration then VUI.Migration = {} end

local Migration = VUI.Migration

-- Store version mapping information for settings migrations
Migration.versionMap = {
    ["0.1.0"] = 1,
    ["0.2.0"] = 2,
    ["0.3.0"] = 3,
    ["1.0.0"] = 4
}

-- Store migration steps between versions
Migration.migrationSteps = {
    -- 0.1.0 to 0.2.0 migrations
    [1] = {
        targetVersion = "0.2.0",
        description = "Adds performance optimization settings and theme compatibility",
        changes = {
            "Added performance optimization settings",
            "Updated theme system for compatibility",
            "Fixed resource usage during combat"
        },
        steps = {
            function(db) 
                -- Initialize performance settings if they don't exist
                if not db.profile.performance then
                    db.profile.performance = {
                        enabled = true,
                        frameThrottling = true,
                        combatOptimization = true,
                        textureOptimization = true,
                        memoryManagement = true
                    }
                end
                return true, "Added performance settings"
            end,
            function(db)
                -- Add missing theme keys for compatibility
                if db.profile.theme then
                    local basicThemes = {"thunderstorm", "phoenixflame", "arcanemystic", "felenergy", "classcolor"}
                    for _, theme in ipairs(basicThemes) do
                        if not db.profile.themes[theme] then
                            db.profile.themes[theme] = true
                        end
                    end
                end
                return true, "Updated theme compatibility"
            end
        }
    },
    
    -- 0.2.0 to 0.3.0 migrations
    [2] = {
        targetVersion = "0.3.0",
        description = "Adds module dependency tracking and profile templates",
        changes = {
            "Added module dependency system",
            "Added role-based profile templates",
            "Enhanced configuration documentation",
            "Improved first-time user experience"
        },
        steps = {
            function(db)
                -- Add module dependency tracking
                if not db.profile.dependencies then
                    db.profile.dependencies = {
                        enabled = true,
                        showWarnings = true,
                        enforceRequired = true
                    }
                end
                return true, "Added module dependency tracking"
            end,
            function(db)
                -- Update profile templates
                if not db.profile.profileTemplates then
                    db.profile.profileTemplates = {
                        dps = true,
                        tank = true,
                        healer = true,
                        pvp = true
                    }
                end
                return true, "Added role-based profile templates"
            end
        }
    },
    
    -- 0.3.0 to 1.0.0 migrations
    [3] = {
        targetVersion = "1.0.0",
        description = "Adds lite mode, enhanced help system, and standardized module settings",
        changes = {
            "Added 'Lite Mode' for improved performance",
            "Enhanced help system with contextual tooltips",
            "Standardized module settings format",
            "Improved version migration system",
            "Added performance optimization presets"
        },
        steps = {
            function(db)
                -- Add lite mode settings
                if not db.profile.liteMode then
                    db.profile.liteMode = {
                        enabled = false,
                        disableNonEssential = true,
                        currentProfile = "balanced",
                        profiles = {
                            raid = true,
                            solo = true,
                            battleground = true,
                            balanced = true
                        }
                    }
                end
                return true, "Added lite mode settings"
            end,
            function(db)
                -- Update help system settings
                if not db.profile.help then
                    db.profile.help = {
                        enabled = true,
                        showTooltips = true,
                        enhancedTooltips = true,
                        contextualHelp = true
                    }
                elseif db.profile.help then
                    -- Add new keys for existing help settings
                    if db.profile.help.showTooltips == nil then db.profile.help.showTooltips = true end
                    if db.profile.help.enhancedTooltips == nil then db.profile.help.enhancedTooltips = true end
                    if db.profile.help.contextualHelp == nil then db.profile.help.contextualHelp = true end
                end
                return true, "Enhanced help system settings"
            end,
            function(db)
                -- Update module settings format for all modules
                if db.profile.modules then
                    for moduleName, moduleSettings in pairs(db.profile.modules) do
                        -- Make sure all modules have a standardized "enabled" key
                        if moduleSettings.enabled == nil then
                            moduleSettings.enabled = true
                        end
                    end
                end
                return true, "Standardized module settings format"
            end
        }
    }
}

-- Initialize the version tracking system
function Migration:Initialize()
    -- Default configuration
    self.defaults = {
        profile = {
            -- Previous versions
            versionHistory = {},
            -- Current addon version
            currentVersion = VUI.version,
            -- Last migration version successfully applied
            lastMigrationVersion = nil
        }
    }
    
    -- Register module with core
    VUI:RegisterModule("migration", self)
    
    -- Register callbacks
    self:RegisterCallbacks()
    
    -- Register for database initialization event
    VUI:RegisterCallback("OnDatabaseInitialized", function(db)
        self:CheckVersion(db)
    end)
    
    VUI:Print("Version Migration system initialized")
end

-- Register necessary callbacks
function Migration:RegisterCallbacks()
    -- Register for profile change
    VUI:RegisterCallback("OnProfileChanged", function(db, profileName)
        self:CheckVersion(db)
    end)
    
    -- Register for module enable/disable
    VUI:RegisterCallback("OnModuleStatusChanged", function(moduleName, enabled)
        -- If specific migrations are needed when modules are enabled/disabled
        if enabled then
            self:OnModuleEnabled(moduleName)
        else
            self:OnModuleDisabled(moduleName)
        end
    end)
end

-- Check version and perform migrations if needed
function Migration:CheckVersion(db)
    -- Skip if no database
    if not db then return end
    
    -- Get stored version information
    local currentStoredVersion = db.profile.currentVersion
    
    -- If we have a stored version and it's different from our current version
    if currentStoredVersion and currentStoredVersion ~= VUI.version then
        VUI:Print("Version change detected: " .. currentStoredVersion .. " -> " .. VUI.version)
        
        -- Store the previous version
        if not db.profile.versionHistory then
            db.profile.versionHistory = {}
        end
        
        -- Add current version to history (avoid duplicates)
        local found = false
        for _, version in ipairs(db.profile.versionHistory) do
            if version == currentStoredVersion then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(db.profile.versionHistory, currentStoredVersion)
        end
        
        -- Determine migration path
        self:PerformMigration(db, currentStoredVersion, VUI.version)
        
        -- Update current version
        db.profile.currentVersion = VUI.version
        
        -- Fire version changed callback for other modules
        VUI:TriggerCallback("VersionChanged", currentStoredVersion, VUI.version)
    elseif not currentStoredVersion then
        -- First time setup - no previous version
        db.profile.currentVersion = VUI.version
        db.profile.versionHistory = {}
        
        -- Fire first time setup callback
        VUI:TriggerCallback("FirstTimeSetup")
    end
end

-- Perform migration between versions
function Migration:PerformMigration(db, fromVersion, toVersion)
    -- Skip if versions are the same
    if fromVersion == toVersion then return end
    
    -- Get version indices
    local fromIndex = self.versionMap[fromVersion] or 0
    local toIndex = self.versionMap[toVersion] or 0
    
    -- Skip if we can't determine version indices
    if fromIndex == 0 or toIndex == 0 then
        VUI:Print("Cannot determine migration path from " .. fromVersion .. " to " .. toVersion)
        return
    end
    
    -- Skip if trying to migrate to an older version
    if fromIndex > toIndex then
        VUI:Print("Cannot migrate from newer version " .. fromVersion .. " to older version " .. toVersion)
        return
    end
    
    -- Collect migration info for notification panel
    local migrationInfo = {
        fromVersion = fromVersion,
        toVersion = toVersion,
        steps = {},
        success = true,
        migrationsApplied = 0
    }
    
    -- Perform migrations in sequence
    for i = fromIndex, toIndex - 1 do
        local migrationSet = self.migrationSteps[i]
        if migrationSet then
            VUI:Print("Applying migration: " .. fromVersion .. " -> " .. migrationSet.targetVersion)
            
            local stepInfo = {
                fromVersion = i > 0 and self:GetVersionByIndex(i) or fromVersion,
                toVersion = migrationSet.targetVersion,
                success = true,
                steps = {}
            }
            
            local success = true
            for j, stepFunc in ipairs(migrationSet.steps) do
                local stepSuccess, message = self:SafeCallMigrationStep(stepFunc, db)
                
                -- Record step result
                table.insert(stepInfo.steps, {
                    index = j,
                    success = stepSuccess,
                    message = message or (stepSuccess and "Success" or "Failed")
                })
                
                if not stepSuccess then
                    success = false
                    stepInfo.success = false
                    migrationInfo.success = false
                    break
                end
            end
            
            -- Add step info to overall migration info
            table.insert(migrationInfo.steps, stepInfo)
            
            if success then
                migrationInfo.migrationsApplied = migrationInfo.migrationsApplied + 1
                db.profile.lastMigrationVersion = migrationSet.targetVersion
            else
                VUI:Print("Migration failed from " .. fromVersion .. " to " .. migrationSet.targetVersion)
                break
            end
        end
    end
    
    -- Show migration notification panel
    self:ShowMigrationNotification(migrationInfo)
    
    VUI:Print("Applied " .. migrationInfo.migrationsApplied .. " migration sets successfully")
end

-- Get version string by index
function Migration:GetVersionByIndex(index)
    for version, versionIndex in pairs(self.versionMap) do
        if versionIndex == index then
            return version
        end
    end
    return "Unknown"
end

-- Show migration notification panel
function Migration:ShowMigrationNotification(migrationInfo)
    -- Create notification frame if it doesn't exist
    if not self.notificationFrame then
        local frame = CreateFrame("Frame", "VUIMigrationNotification", UIParent, "BackdropTemplate")
        frame:SetSize(500, 350)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("DIALOG")
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        
        -- Apply theme
        local theme = VUI.db.profile.theme or "thunderstorm"
        local colors = VUI.media.themes[theme] or {}
        
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        if colors.background then
            frame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.9)
        else
            frame:SetBackdropColor(0.1, 0.1, 0.2, 0.9)
        end
        
        if colors.border then
            frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
        else
            frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
        end
        
        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", frame, "TOP", 0, -15)
        title:SetText("VUI Upgrade Migration")
        frame.title = title
        
        -- Version info
        local versionInfo = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        versionInfo:SetPoint("TOP", title, "BOTTOM", 0, -10)
        frame.versionInfo = versionInfo
        
        -- Status message
        local statusMessage = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statusMessage:SetPoint("TOP", versionInfo, "BOTTOM", 0, -15)
        statusMessage:SetWidth(460)
        frame.statusMessage = statusMessage
        
        -- Create scrolling area for migration steps
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -110)
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 50)
        
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(scrollFrame:GetWidth(), 500) -- Larger height for scrolling
        scrollFrame:SetScrollChild(scrollChild)
        frame.scrollChild = scrollChild
        
        -- Features list title
        local featuresTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        featuresTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -90)
        featuresTitle:SetText("Changes Applied:")
        
        -- Close button
        local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        closeButton:SetScript("OnClick", function() frame:Hide() end)
        
        -- OK button at bottom
        local okButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        okButton:SetSize(100, 24)
        okButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
        okButton:SetText("OK")
        okButton:SetScript("OnClick", function() frame:Hide() end)
        
        self.notificationFrame = frame
    end
    
    -- Update frame with migration info
    local frame = self.notificationFrame
    
    -- Update version text
    frame.versionInfo:SetText("Upgrading from " .. migrationInfo.fromVersion .. " to " .. migrationInfo.toVersion)
    
    -- Update status message
    if migrationInfo.success then
        frame.statusMessage:SetText("Your settings have been successfully migrated to the new version. The following changes were applied:")
        frame.statusMessage:SetTextColor(0, 1, 0)
    else
        frame.statusMessage:SetText("There were some issues migrating your settings. Some changes may not have been applied correctly. It's recommended to reset your settings if you experience any problems.")
        frame.statusMessage:SetTextColor(1, 0.3, 0.3)
    end
    
    -- Clear previous migration steps
    frame.scrollChild:SetHeight(500) -- Reset height
    if frame.scrollChild.migrationTexts then
        for _, fontString in ipairs(frame.scrollChild.migrationTexts) do
            fontString:Hide()
            fontString:SetText("")
        end
    end
    
    -- Create or reuse fontstrings array
    frame.scrollChild.migrationTexts = frame.scrollChild.migrationTexts or {}
    
    -- Add migration steps text
    local yOffset = 10
    local textIndex = 1
    
    -- Get or create new fontstring
    local function GetFontString(index)
        if not frame.scrollChild.migrationTexts[index] then
            local fontString = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            fontString:SetJustifyH("LEFT")
            fontString:SetWidth(420)
            frame.scrollChild.migrationTexts[index] = fontString
        end
        
        -- Reset and show the fontstring
        local fontString = frame.scrollChild.migrationTexts[index]
        fontString:ClearAllPoints()
        fontString:Show()
        return fontString
    end
    
    -- Get new features from version data in help module
    local newFeatures = {}
    if VUI.modules and VUI.modules.help and VUI.modules.help.helpContent and 
       VUI.modules.help.helpContent.newFeatures and 
       VUI.modules.help.helpContent.newFeatures[migrationInfo.toVersion] then
        newFeatures = VUI.modules.help.helpContent.newFeatures[migrationInfo.toVersion].features or {}
    end
    
    -- Add version header for new features
    local headerText = GetFontString(textIndex)
    headerText:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 0, -yOffset)
    headerText:SetText("New Features in " .. migrationInfo.toVersion .. ":")
    headerText:SetTextColor(1, 0.82, 0)
    headerText:SetFontObject("GameFontNormalLarge")
    yOffset = yOffset + 25
    textIndex = textIndex + 1
    
    -- Add new features from help content
    for i, feature in ipairs(newFeatures) do
        local featureText = GetFontString(textIndex)
        featureText:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 15, -yOffset)
        featureText:SetText("• " .. feature)
        featureText:SetTextColor(1, 1, 1)
        yOffset = yOffset + 20
        textIndex = textIndex + 1
    end
    
    -- Add migration section header
    yOffset = yOffset + 10
    local migrationHeader = GetFontString(textIndex)
    migrationHeader:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 0, -yOffset)
    migrationHeader:SetText("Settings Migration:")
    migrationHeader:SetTextColor(1, 0.82, 0)
    migrationHeader:SetFontObject("GameFontNormalLarge")
    yOffset = yOffset + 25
    textIndex = textIndex + 1
    
    -- Add details for each migration step applied
    for i, step in ipairs(migrationInfo.steps) do
        local stepHeader = GetFontString(textIndex)
        stepHeader:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 10, -yOffset)
        local headerText = "Migration from " .. step.fromVersion .. " to " .. step.toVersion
        stepHeader:SetText(headerText)
        
        if step.success then
            stepHeader:SetTextColor(0, 1, 0)
        else
            stepHeader:SetTextColor(1, 0.3, 0.3)
        end
        
        yOffset = yOffset + 20
        textIndex = textIndex + 1
        
        -- List major changes in this migration set (if available)
        if self.migrationSteps[i] and self.migrationSteps[i].changes then
            for _, change in ipairs(self.migrationSteps[i].changes) do
                local changeText = GetFontString(textIndex)
                changeText:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 25, -yOffset)
                changeText:SetText("• " .. change)
                changeText:SetTextColor(0.8, 0.8, 0.8)
                yOffset = yOffset + 20
                textIndex = textIndex + 1
            end
        else
            -- Default change text if no specific changes listed
            local changeText = GetFontString(textIndex)
            changeText:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 25, -yOffset)
            changeText:SetText("• Applied compatibility updates")
            changeText:SetTextColor(0.8, 0.8, 0.8)
            yOffset = yOffset + 20
            textIndex = textIndex + 1
        end
        
        yOffset = yOffset + 5
    end
    
    -- Update scroll child height
    frame.scrollChild:SetHeight(math.max(500, yOffset + 50))
    
    -- Show the notification
    frame:Show()
end

-- Safely call a migration step with error handling
function Migration:SafeCallMigrationStep(stepFunc, db)
    local success, result, message = pcall(function()
        return stepFunc(db)
    end)
    
    if not success then
        local errorMsg = tostring(result or "Unknown error")
        VUI:Print("Migration step failed: " .. errorMsg)
        return false, errorMsg
    end
    
    -- Check if we have both a result and a message
    if type(result) == "table" and #result >= 2 then
        return result[1], result[2]
    end
    
    -- Otherwise just return the result and default message
    return result, (type(result) == "boolean" and result and "Success" or "Failed")
end

-- Handle module enabled event
function Migration:OnModuleEnabled(moduleName)
    -- Specific migrations when a module is enabled
    -- For example, restore module-specific settings
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and VUI.db.profile.modules[moduleName] then
        local moduleSettings = VUI.db.profile.modules[moduleName]
        
        -- No migrations needed currently when modules are enabled
    end
end

-- Handle module disabled event
function Migration:OnModuleDisabled(moduleName)
    -- Specific migrations when a module is disabled
    -- For example, clean up or store module-specific settings
    if VUI.db and VUI.db.profile and VUI.db.profile.modules and VUI.db.profile.modules[moduleName] then
        local moduleSettings = VUI.db.profile.modules[moduleName]
        
        -- No migrations needed currently when modules are disabled
    end
end

-- Register the module with the core
VUI:RegisterCallback("OnInitialized", function()
    Migration:Initialize()
end)

-- Return the module
VUI.Migration = Migration