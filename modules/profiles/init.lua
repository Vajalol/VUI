-- VUI Profiles Module - Initialization
local _, VUI = ...

-- Create the module using the module API
local Profiles = VUI.ModuleAPI:CreateModule("profiles")

-- Get configuration options for main UI integration
function Profiles:GetConfig()
    local config = {
        name = "Profiles",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Profiles",
                desc = "Enable or disable the Profiles module",
                get = function() return self.db.enabled end,
                set = function(_, value) 
                    self.db.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            autoSave = {
                type = "toggle",
                name = "Auto-Save Profiles",
                desc = "Automatically save profile changes periodically",
                get = function() return self.db.autoSave end,
                set = function(_, value) 
                    self.db.autoSave = value
                    self:UpdateAutoSave()
                end,
                order = 2
            },
            saveFrequency = {
                type = "range",
                name = "Save Frequency",
                desc = "How often to automatically save profiles (in minutes)",
                min = 1,
                max = 60,
                step = 1,
                get = function() return self.db.saveFrequency / 60 end, -- Convert seconds to minutes
                set = function(_, value) 
                    self.db.saveFrequency = value * 60 -- Convert minutes to seconds
                    self:UpdateAutoSave()
                end,
                disabled = function() return not self.db.autoSave end,
                order = 3
            },
            backupCount = {
                type = "range",
                name = "Backup Count",
                desc = "Number of profile backups to keep",
                min = 1,
                max = 10,
                step = 1,
                get = function() return self.db.backupCount end,
                set = function(_, value) 
                    self.db.backupCount = value
                    self:CleanupBackups()
                end,
                order = 4
            },
            importExport = {
                type = "execute",
                name = "Import/Export Profile",
                desc = "Open the profile import/export interface",
                func = function() self:ShowImportExportFrame() end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
-- Module config registration is done later with extended options

-- Set up module defaults
local defaults = {
    enabled = true,
    -- Profile Management Settings
    autoSave = true,
    saveFrequency = 300, -- 5 minutes in seconds
    backupCount = 3,     -- Number of profile backups to keep
    -- Display Settings
    showImportExportFrame = true,
    previewChanges = true,
    confirmOverwrite = true,
    -- Advanced Settings
    compressExports = true,
    includeGlobalSettings = true,
    includeCharacterSettings = true,
    includeUILayout = true,
    -- Storage for profiles
    savedProfiles = {},
    -- Storage for backups
    profileBackups = {},
    -- Last profile actions
    lastExported = nil,
    lastImported = nil,
    lastSaved = nil,
}

-- Initialize module settings
Profiles.settings = VUI.ModuleAPI:InitializeModuleSettings("profiles", defaults)

-- Set up data structures for temp storage
Profiles.tempProfileData = {}
Profiles.currentProfile = nil
Profiles.currentBackup = nil

-- Register module configuration
local config = {
    type = "group",
    name = "Profiles",
    desc = "Profile Management",
    args = {
        enable = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable profiles module",
            order = 1,
            get = function() return VUI:IsModuleEnabled("profiles") end,
            set = function(_, value)
                if value then
                    VUI:EnableModule("profiles")
                else
                    VUI:DisableModule("profiles")
                end
            end,
        },
        generalHeader = {
            type = "header",
            name = "General Settings",
            order = 2,
        },
        autoSave = {
            type = "toggle",
            name = "Auto Save",
            desc = "Automatically save profile changes",
            order = 3,
            get = function() return Profiles.settings.autoSave end,
            set = function(_, value)
                Profiles.settings.autoSave = value
                if value then
                    Profiles:StartAutoSave()
                else
                    Profiles:StopAutoSave()
                end
            end,
        },
        saveFrequency = {
            type = "range",
            name = "Auto Save Frequency",
            desc = "How often (in minutes) to automatically save profile changes",
            min = 1,
            max = 60,
            step = 1,
            order = 4,
            get = function() return Profiles.settings.saveFrequency / 60 end,
            set = function(_, value)
                Profiles.settings.saveFrequency = value * 60
                if Profiles.settings.autoSave then
                    Profiles:RestartAutoSave()
                end
            end,
            disabled = function() return not Profiles.settings.autoSave end,
        },
        backupCount = {
            type = "range",
            name = "Backup Count",
            desc = "Number of profile backups to maintain",
            min = 1,
            max = 10,
            step = 1,
            order = 5,
            get = function() return Profiles.settings.backupCount end,
            set = function(_, value)
                Profiles.settings.backupCount = value
                Profiles:CleanupBackups()
            end,
        },
        displayHeader = {
            type = "header",
            name = "Display Settings",
            order = 6,
        },
        showImportExportFrame = {
            type = "toggle",
            name = "Show Import/Export Frame",
            desc = "Show the import/export frame when importing or exporting profiles",
            order = 7,
            get = function() return Profiles.settings.showImportExportFrame end,
            set = function(_, value)
                Profiles.settings.showImportExportFrame = value
            end,
        },
        previewChanges = {
            type = "toggle",
            name = "Preview Changes",
            desc = "Preview changes before applying a profile",
            order = 8,
            get = function() return Profiles.settings.previewChanges end,
            set = function(_, value)
                Profiles.settings.previewChanges = value
            end,
        },
        confirmOverwrite = {
            type = "toggle",
            name = "Confirm Overwrite",
            desc = "Confirm before overwriting existing profiles or settings",
            order = 9,
            get = function() return Profiles.settings.confirmOverwrite end,
            set = function(_, value)
                Profiles.settings.confirmOverwrite = value
            end,
        },
        advancedHeader = {
            type = "header",
            name = "Advanced Settings",
            order = 10,
        },
        compressExports = {
            type = "toggle",
            name = "Compress Exports",
            desc = "Compress exported profiles to reduce size",
            order = 11,
            get = function() return Profiles.settings.compressExports end,
            set = function(_, value)
                Profiles.settings.compressExports = value
            end,
        },
        includeGlobalSettings = {
            type = "toggle",
            name = "Include Global Settings",
            desc = "Include global settings in profiles",
            order = 12,
            get = function() return Profiles.settings.includeGlobalSettings end,
            set = function(_, value)
                Profiles.settings.includeGlobalSettings = value
            end,
        },
        includeCharacterSettings = {
            type = "toggle",
            name = "Include Character Settings",
            desc = "Include character-specific settings in profiles",
            order = 13,
            get = function() return Profiles.settings.includeCharacterSettings end,
            set = function(_, value)
                Profiles.settings.includeCharacterSettings = value
            end,
        },
        includeUILayout = {
            type = "toggle",
            name = "Include UI Layout",
            desc = "Include UI layout information in profiles",
            order = 14,
            get = function() return Profiles.settings.includeUILayout end,
            set = function(_, value)
                Profiles.settings.includeUILayout = value
            end,
        },
        profileManagementHeader = {
            type = "header",
            name = "Profile Management",
            order = 15,
        },
        createProfile = {
            type = "execute",
            name = "Create New Profile",
            desc = "Create a new profile with current settings",
            order = 16,
            func = function()
                Profiles:ShowCreateProfileDialog()
            end,
        },
        exportProfile = {
            type = "execute",
            name = "Export Current Profile",
            desc = "Export current settings as a profile string",
            order = 17,
            func = function()
                Profiles:ExportCurrentProfile()
            end,
        },
        importProfile = {
            type = "execute",
            name = "Import Profile",
            desc = "Import a profile from a string",
            order = 18,
            func = function()
                Profiles:ShowImportDialog()
            end,
        },
        manageProfiles = {
            type = "execute",
            name = "Manage Profiles",
            desc = "View and manage saved profiles",
            order = 19,
            func = function()
                Profiles:ShowProfileManager()
            end,
        },
        savedProfilesHeader = {
            type = "header",
            name = "Saved Profiles",
            order = 20,
        },
        savedProfilesDesc = {
            type = "description",
            name = function()
                local profiles = Profiles:GetSavedProfilesList()
                if #profiles == 0 then
                    return "No saved profiles found. Create a profile to save your current configuration."
                else
                    return "Select a saved profile to load or manage:"
                end
            end,
            order = 21,
        },
        profileSelector = {
            type = "select",
            name = "Saved Profiles",
            desc = "Select a saved profile",
            values = function()
                return Profiles:GetSavedProfilesMap()
            end,
            get = function()
                return Profiles.currentProfile
            end,
            set = function(_, value)
                Profiles.currentProfile = value
                Profiles:SelectProfile(value)
            end,
            order = 22,
            hidden = function()
                local profiles = Profiles:GetSavedProfilesList()
                return #profiles == 0
            end,
        },
        loadProfile = {
            type = "execute",
            name = "Load Profile",
            desc = "Load the selected profile",
            confirm = function()
                if Profiles.settings.confirmOverwrite then
                    return "Are you sure you want to load this profile? This will overwrite your current settings."
                end
                return false
            end,
            order = 23,
            func = function()
                if Profiles.currentProfile then
                    Profiles:LoadProfile(Profiles.currentProfile)
                end
            end,
            disabled = function() return not Profiles.currentProfile end,
            hidden = function()
                local profiles = Profiles:GetSavedProfilesList()
                return #profiles == 0
            end,
        },
        updateProfile = {
            type = "execute",
            name = "Update Profile",
            desc = "Update the selected profile with current settings",
            confirm = function()
                if Profiles.settings.confirmOverwrite then
                    return "Are you sure you want to update this profile with your current settings? This will overwrite the saved profile."
                end
                return false
            end,
            order = 24,
            func = function()
                if Profiles.currentProfile then
                    Profiles:UpdateProfile(Profiles.currentProfile)
                end
            end,
            disabled = function() return not Profiles.currentProfile end,
            hidden = function()
                local profiles = Profiles:GetSavedProfilesList()
                return #profiles == 0
            end,
        },
        deleteProfile = {
            type = "execute",
            name = "Delete Profile",
            desc = "Delete the selected profile",
            confirm = function()
                return "Are you sure you want to delete this profile? This cannot be undone."
            end,
            order = 25,
            func = function()
                if Profiles.currentProfile then
                    Profiles:DeleteProfile(Profiles.currentProfile)
                    Profiles.currentProfile = nil
                end
            end,
            disabled = function() return not Profiles.currentProfile end,
            hidden = function()
                local profiles = Profiles:GetSavedProfilesList()
                return #profiles == 0
            end,
        },
        backupHeader = {
            type = "header",
            name = "Profile Backups",
            order = 26,
        },
        backupDesc = {
            type = "description",
            name = function()
                local backups = Profiles:GetBackupsList()
                if #backups == 0 then
                    return "No profile backups found. Backups are created automatically when profiles are updated."
                else
                    return "Select a backup to restore:"
                end
            end,
            order = 27,
        },
        backupSelector = {
            type = "select",
            name = "Profile Backups",
            desc = "Select a profile backup",
            values = function()
                return Profiles:GetBackupsMap()
            end,
            get = function()
                return Profiles.currentBackup
            end,
            set = function(_, value)
                Profiles.currentBackup = value
            end,
            order = 28,
            hidden = function()
                local backups = Profiles:GetBackupsList()
                return #backups == 0
            end,
        },
        restoreBackup = {
            type = "execute",
            name = "Restore Backup",
            desc = "Restore the selected backup",
            confirm = function()
                if Profiles.settings.confirmOverwrite then
                    return "Are you sure you want to restore this backup? This will overwrite your current settings."
                end
                return false
            end,
            order = 29,
            func = function()
                if Profiles.currentBackup then
                    Profiles:RestoreBackup(Profiles.currentBackup)
                end
            end,
            disabled = function() return not Profiles.currentBackup end,
            hidden = function()
                local backups = Profiles:GetBackupsList()
                return #backups == 0
            end,
        },
        createBackup = {
            type = "execute",
            name = "Create Backup",
            desc = "Create a backup of current settings",
            order = 30,
            func = function()
                Profiles:CreateBackup("Manual Backup")
                VUI:Print("Manual backup created successfully.")
            end,
        },
    }
}

-- Register module config
VUI.ModuleAPI:RegisterModuleConfig("profiles", config)

-- Register slash command
VUI.ModuleAPI:RegisterModuleSlashCommand("profiles", "vuiprofile", function(input)
    if not input or input:trim() == "" then
        Profiles:ShowProfileManager()
    elseif input:trim() == "export" then
        Profiles:ExportCurrentProfile()
    elseif input:trim() == "import" then
        Profiles:ShowImportDialog()
    elseif input:trim():match("^save%s+(.+)$") then
        local profileName = input:trim():match("^save%s+(.+)$")
        Profiles:SaveProfile(profileName)
    elseif input:trim():match("^load%s+(.+)$") then
        local profileName = input:trim():match("^load%s+(.+)$")
        Profiles:LoadProfileByName(profileName)
    elseif input:trim():match("^delete%s+(.+)$") then
        local profileName = input:trim():match("^delete%s+(.+)$")
        Profiles:DeleteProfileByName(profileName)
    elseif input:trim() == "list" then
        Profiles:ListProfiles()
    elseif input:trim() == "backup" then
        Profiles:CreateBackup("Manual Backup")
        VUI:Print("Manual backup created successfully.")
    elseif input:trim() == "help" or input:trim() == "?" then
        Profiles:ShowHelp()
    else
        Profiles:ShowHelp()
    end
end)

-- Helper function to get a list of saved profiles
function Profiles:GetSavedProfilesList()
    local profiles = {}
    for name, _ in pairs(self.settings.savedProfiles) do
        table.insert(profiles, name)
    end
    table.sort(profiles)
    return profiles
end

-- Helper function to get a map of saved profiles for dropdown
function Profiles:GetSavedProfilesMap()
    local profiles = {}
    for name, profile in pairs(self.settings.savedProfiles) do
        profiles[name] = string.format("%s (%s)", name, date("%Y-%m-%d %H:%M", profile.timestamp))
    end
    return profiles
end

-- Helper function to get a list of backups
function Profiles:GetBackupsList()
    local backups = {}
    for name, _ in pairs(self.settings.profileBackups) do
        table.insert(backups, name)
    end
    table.sort(backups, function(a, b)
        return self.settings.profileBackups[a].timestamp > self.settings.profileBackups[b].timestamp
    end)
    return backups
end

-- Helper function to get a map of backups for dropdown
function Profiles:GetBackupsMap()
    local backups = {}
    for name, backup in pairs(self.settings.profileBackups) do
        backups[name] = string.format("%s (%s)", name, date("%Y-%m-%d %H:%M", backup.timestamp))
    end
    return backups
end

-- Helper function to show help
function Profiles:ShowHelp()
    VUI:Print("VUI Profile Commands:")
    VUI:Print("  /vuiprofile - Show profile manager")
    VUI:Print("  /vuiprofile export - Export current profile")
    VUI:Print("  /vuiprofile import - Import a profile")
    VUI:Print("  /vuiprofile save <name> - Save current settings as a profile")
    VUI:Print("  /vuiprofile load <name> - Load a saved profile")
    VUI:Print("  /vuiprofile delete <name> - Delete a saved profile")
    VUI:Print("  /vuiprofile list - List all saved profiles")
    VUI:Print("  /vuiprofile backup - Create a manual backup")
    VUI:Print("  /vuiprofile help - Show this help")
end

-- Initialize module
function Profiles:Initialize()
    -- Register with VUI
    VUI:Print("Profiles module initialized")
    
    -- Create frames we'll need for import/export
    self:CreateFrames()
    
    -- Register events
    self:RegisterEvent("PLAYER_LOGOUT", "OnPlayerLogout")
    
    -- Set up auto-save if enabled
    if self.settings.autoSave then
        self:StartAutoSave()
    end
    
    -- Initialize theme integration
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
end

-- Enable module
function Profiles:Enable()
    self.enabled = true
    
    -- Start auto-save if enabled
    if self.settings.autoSave then
        self:StartAutoSave()
    end
    
    VUI:Print("Profiles module enabled")
end

-- Disable module
function Profiles:Disable()
    self.enabled = false
    
    -- Stop auto-save
    self:StopAutoSave()
    
    VUI:Print("Profiles module disabled")
end

-- Event registration helper
function Profiles:RegisterEvent(event, method)
    if type(method) == "string" and self[method] then
        method = self[method]
    end
    
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if self[event] then
                self[event](self, ...)
            end
        end)
    end
    
    self.eventFrame:RegisterEvent(event)
    self[event] = method
end

-- PLAYER_LOGOUT event handler
function Profiles:OnPlayerLogout()
    -- Optionally create a backup on logout
    if self.settings.autoSave then
        self:CreateBackup("Logout Backup")
    end
end

-- Start auto-save timer
function Profiles:StartAutoSave()
    if self.autoSaveTimer then
        self:StopAutoSave()
    end
    
    self.autoSaveTimer = C_Timer.NewTicker(self.settings.saveFrequency, function()
        self:CreateBackup("Auto Backup")
    end)
end

-- Stop auto-save timer
function Profiles:StopAutoSave()
    if self.autoSaveTimer then
        self.autoSaveTimer:Cancel()
        self.autoSaveTimer = nil
    end
end

-- Restart auto-save timer (for when frequency changes)
function Profiles:RestartAutoSave()
    self:StopAutoSave()
    self:StartAutoSave()
end

-- Create a backup of current settings
function Profiles:CreateBackup(name)
    if not self.enabled then return end
    
    -- Generate backup name with timestamp
    local timestamp = time()
    local backupName = string.format("%s-%s", name, date("%Y%m%d%H%M%S", timestamp))
    
    -- Collect current settings
    local backupData = self:CollectCurrentSettings()
    
    -- Store the backup
    self.settings.profileBackups[backupName] = {
        name = name,
        timestamp = timestamp,
        data = backupData,
    }
    
    -- Cleanup old backups if we have too many
    self:CleanupBackups()
    
    return backupName
end

-- Cleanup old backups to stay within backupCount limit
function Profiles:CleanupBackups()
    local backups = self:GetBackupsList()
    
    if #backups > self.settings.backupCount then
        -- Sort backups by timestamp (oldest first)
        table.sort(backups, function(a, b)
            return self.settings.profileBackups[a].timestamp < self.settings.profileBackups[b].timestamp
        end)
        
        -- Delete oldest backups until we're within limit
        for i = 1, #backups - self.settings.backupCount do
            self.settings.profileBackups[backups[i]] = nil
        end
    end
end

-- Restore a backup
function Profiles:RestoreBackup(backupName)
    if not self.enabled or not self.settings.profileBackups[backupName] then return end
    
    -- Create a backup of current settings before restoring
    self:CreateBackup("Pre-Restore Backup")
    
    -- Get backup data
    local backupData = self.settings.profileBackups[backupName].data
    
    -- Apply the backup
    self:ApplySettings(backupData)
    
    VUI:Print(string.format("Restored backup: %s", backupName))
    
    -- Reload UI to apply all changes
    ReloadUI()
end

-- Create necessary frames for import/export
function Profiles:CreateFrames()
    -- Create the main dialog frame
    self.importExportFrame = CreateFrame("Frame", "VUIProfileImportExportFrame", UIParent, "DialogBoxFrame")
    self.importExportFrame:SetSize(500, 300)
    self.importExportFrame:SetPoint("CENTER")
    self.importExportFrame:SetFrameStrata("DIALOG")
    self.importExportFrame:SetMovable(true)
    self.importExportFrame:EnableMouse(true)
    self.importExportFrame:RegisterForDrag("LeftButton")
    self.importExportFrame:SetScript("OnDragStart", self.importExportFrame.StartMoving)
    self.importExportFrame:SetScript("OnDragStop", self.importExportFrame.StopMovingOrSizing)
    self.importExportFrame:Hide()
    
    -- Set up the title
    self.importExportFrame.Title = self.importExportFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.importExportFrame.Title:SetPoint("TOP", 0, -10)
    self.importExportFrame.Title:SetText("VUI Profile Import/Export")
    
    -- Create scroll frame for the text
    self.importExportFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, self.importExportFrame, "UIPanelScrollFrameTemplate")
    self.importExportFrame.ScrollFrame:SetPoint("TOPLEFT", 15, -30)
    self.importExportFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", -35, 40)
    
    -- Create edit box for text input/output
    self.importExportFrame.EditBox = CreateFrame("EditBox", nil, self.importExportFrame.ScrollFrame)
    self.importExportFrame.EditBox:SetSize(self.importExportFrame.ScrollFrame:GetSize())
    self.importExportFrame.EditBox:SetMultiLine(true)
    self.importExportFrame.EditBox:SetAutoFocus(true)
    self.importExportFrame.EditBox:SetFontObject(ChatFontNormal)
    self.importExportFrame.EditBox:SetScript("OnEscapePressed", function()
        self.importExportFrame:Hide()
    end)
    
    self.importExportFrame.ScrollFrame:SetScrollChild(self.importExportFrame.EditBox)
    
    -- Create buttons
    self.importExportFrame.AcceptButton = CreateFrame("Button", nil, self.importExportFrame, "UIPanelButtonTemplate")
    self.importExportFrame.AcceptButton:SetSize(100, 22)
    self.importExportFrame.AcceptButton:SetPoint("BOTTOMRIGHT", -10, 10)
    self.importExportFrame.AcceptButton:SetText("Accept")
    
    self.importExportFrame.CancelButton = CreateFrame("Button", nil, self.importExportFrame, "UIPanelButtonTemplate")
    self.importExportFrame.CancelButton:SetSize(100, 22)
    self.importExportFrame.CancelButton:SetPoint("BOTTOMLEFT", 10, 10)
    self.importExportFrame.CancelButton:SetText("Cancel")
    self.importExportFrame.CancelButton:SetScript("OnClick", function()
        self.importExportFrame:Hide()
    end)
    
    -- Create profile manager frame
    self.profileManagerFrame = CreateFrame("Frame", "VUIProfileManagerFrame", UIParent, "DialogBoxFrame")
    self.profileManagerFrame:SetSize(400, 500)
    self.profileManagerFrame:SetPoint("CENTER")
    self.profileManagerFrame:SetFrameStrata("DIALOG")
    self.profileManagerFrame:SetMovable(true)
    self.profileManagerFrame:EnableMouse(true)
    self.profileManagerFrame:RegisterForDrag("LeftButton")
    self.profileManagerFrame:SetScript("OnDragStart", self.profileManagerFrame.StartMoving)
    self.profileManagerFrame:SetScript("OnDragStop", self.profileManagerFrame.StopMovingOrSizing)
    self.profileManagerFrame:Hide()
    
    -- Set up the title
    self.profileManagerFrame.Title = self.profileManagerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.profileManagerFrame.Title:SetPoint("TOP", 0, -10)
    self.profileManagerFrame.Title:SetText("VUI Profile Manager")
    
    -- We'll fill in the rest of the profile manager dynamically when it's shown
end

-- Show the import dialog
function Profiles:ShowImportDialog()
    if not self.enabled then return end
    
    self.importExportFrame.Title:SetText("Import Profile")
    self.importExportFrame.EditBox:SetText("")
    self.importExportFrame.EditBox:SetFocus()
    
    self.importExportFrame.AcceptButton:SetText("Import")
    self.importExportFrame.AcceptButton:SetScript("OnClick", function()
        local importString = self.importExportFrame.EditBox:GetText()
        if importString and importString ~= "" then
            self:ImportProfile(importString)
            self.importExportFrame:Hide()
        else
            VUI:Print("No profile data entered.")
        end
    end)
    
    self.importExportFrame:Show()
end

-- Show the create profile dialog
function Profiles:ShowCreateProfileDialog()
    if not self.enabled then return end
    
    -- Create simple dialog to enter profile name
    StaticPopup_Show("VUI_CREATE_PROFILE")
end

-- Register static popups
StaticPopupDialogs["VUI_CREATE_PROFILE"] = {
    text = "Enter a name for the new profile:",
    button1 = "Create",
    button2 = "Cancel",
    hasEditBox = true,
    maxLetters = 32,
    OnAccept = function(self)
        local profileName = self.editBox:GetText()
        if profileName and profileName ~= "" then
            VUI.profiles:SaveProfile(profileName)
        else
            VUI:Print("Profile name cannot be empty.")
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local profileName = self:GetText()
        if profileName and profileName ~= "" then
            VUI.profiles:SaveProfile(profileName)
            self:GetParent():Hide()
        else
            VUI:Print("Profile name cannot be empty.")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Export the current profile
function Profiles:ExportCurrentProfile()
    if not self.enabled then return end
    
    -- Collect current settings
    local profileData = self:CollectCurrentSettings()
    
    -- Convert to string
    local exportString = self:SerializeProfile(profileData)
    
    -- Show export frame
    self.importExportFrame.Title:SetText("Export Profile")
    self.importExportFrame.EditBox:SetText(exportString)
    self.importExportFrame.EditBox:HighlightText()
    self.importExportFrame.EditBox:SetFocus()
    
    self.importExportFrame.AcceptButton:SetText("Close")
    self.importExportFrame.AcceptButton:SetScript("OnClick", function()
        self.importExportFrame:Hide()
    end)
    
    self.importExportFrame:Show()
    
    -- Store export timestamp
    self.settings.lastExported = time()
end

-- Import a profile from a string
function Profiles:ImportProfile(importString)
    if not self.enabled or not importString or importString == "" then return end
    
    -- Deserialize the string to get profile data
    local success, profileData = self:DeserializeProfile(importString)
    
    if not success then
        VUI:Print("Failed to import profile: Invalid profile data.")
        return
    end
    
    -- Create a backup before importing
    self:CreateBackup("Pre-Import Backup")
    
    -- Apply the profile
    self:ApplySettings(profileData)
    
    VUI:Print("Profile imported successfully. Reloading UI...")
    
    -- Store import timestamp
    self.settings.lastImported = time()
    
    -- Reload UI to apply all changes
    ReloadUI()
end

-- Save current settings as a named profile
function Profiles:SaveProfile(profileName)
    if not self.enabled or not profileName or profileName == "" then return end
    
    -- Check if profile already exists
    if self.settings.savedProfiles[profileName] and self.settings.confirmOverwrite then
        -- Show confirmation dialog
        StaticPopupDialogs["VUI_CONFIRM_OVERWRITE"] = {
            text = string.format("Profile '%s' already exists. Overwrite?", profileName),
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                self:FinalizeSaveProfile(profileName)
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("VUI_CONFIRM_OVERWRITE")
    else
        -- Save directly
        self:FinalizeSaveProfile(profileName)
    end
end

-- Finalize saving a profile after confirmation
function Profiles:FinalizeSaveProfile(profileName)
    -- Collect current settings
    local profileData = self:CollectCurrentSettings()
    
    -- Store the profile
    self.settings.savedProfiles[profileName] = {
        name = profileName,
        timestamp = time(),
        data = profileData,
    }
    
    VUI:Print(string.format("Profile '%s' saved successfully.", profileName))
    
    -- Store save timestamp
    self.settings.lastSaved = time()
    
    -- Update current profile
    self.currentProfile = profileName
end

-- Load a saved profile by name
function Profiles:LoadProfileByName(profileName)
    if not self.enabled or not profileName or profileName == "" then return end
    
    -- Check if profile exists
    if not self.settings.savedProfiles[profileName] then
        VUI:Print(string.format("Profile '%s' not found.", profileName))
        return
    end
    
    -- Load the profile
    self:LoadProfile(profileName)
end

-- Load a selected profile
function Profiles:LoadProfile(profileName)
    if not self.enabled or not self.settings.savedProfiles[profileName] then return end
    
    -- Create a backup before loading
    self:CreateBackup("Pre-Load Backup")
    
    -- Get profile data
    local profileData = self.settings.savedProfiles[profileName].data
    
    -- Apply the profile
    self:ApplySettings(profileData)
    
    VUI:Print(string.format("Profile '%s' loaded successfully. Reloading UI...", profileName))
    
    -- Reload UI to apply all changes
    ReloadUI()
end

-- Update an existing profile with current settings
function Profiles:UpdateProfile(profileName)
    if not self.enabled or not profileName or profileName == "" then return end
    
    -- Check if profile exists
    if not self.settings.savedProfiles[profileName] then
        VUI:Print(string.format("Profile '%s' not found.", profileName))
        return
    end
    
    -- Back up the old profile first
    local oldProfile = self.settings.savedProfiles[profileName]
    local backupName = string.format("%s-Backup-%s", profileName, date("%Y%m%d%H%M%S", oldProfile.timestamp))
    self.settings.profileBackups[backupName] = CopyTable(oldProfile)
    
    -- Collect current settings
    local profileData = self:CollectCurrentSettings()
    
    -- Update the profile
    self.settings.savedProfiles[profileName] = {
        name = profileName,
        timestamp = time(),
        data = profileData,
    }
    
    VUI:Print(string.format("Profile '%s' updated successfully.", profileName))
    
    -- Store save timestamp
    self.settings.lastSaved = time()
    
    -- Clean up old backups
    self:CleanupBackups()
end

-- Delete a profile by name
function Profiles:DeleteProfileByName(profileName)
    if not self.enabled or not profileName or profileName == "" then return end
    
    -- Check if profile exists
    if not self.settings.savedProfiles[profileName] then
        VUI:Print(string.format("Profile '%s' not found.", profileName))
        return
    end
    
    -- Delete the profile
    self:DeleteProfile(profileName)
end

-- Delete a selected profile
function Profiles:DeleteProfile(profileName)
    if not self.enabled or not self.settings.savedProfiles[profileName] then return end
    
    -- Back up the profile before deleting
    local oldProfile = self.settings.savedProfiles[profileName]
    local backupName = string.format("%s-Deleted-%s", profileName, date("%Y%m%d%H%M%S", oldProfile.timestamp))
    self.settings.profileBackups[backupName] = CopyTable(oldProfile)
    
    -- Delete the profile
    self.settings.savedProfiles[profileName] = nil
    
    VUI:Print(string.format("Profile '%s' deleted.", profileName))
    
    -- Reset current profile if it was the deleted one
    if self.currentProfile == profileName then
        self.currentProfile = nil
    end
    
    -- Clean up old backups
    self:CleanupBackups()
end

-- Show a list of all saved profiles
function Profiles:ListProfiles()
    if not self.enabled then return end
    
    local profiles = self:GetSavedProfilesList()
    
    if #profiles == 0 then
        VUI:Print("No saved profiles found.")
        return
    end
    
    VUI:Print("Saved profiles:")
    for _, name in ipairs(profiles) do
        local profile = self.settings.savedProfiles[name]
        VUI:Print(string.format("  %s (Created: %s)", name, date("%Y-%m-%d %H:%M", profile.timestamp)))
    end
end

-- Show the profile manager
function Profiles:ShowProfileManager()
    if not self.enabled then return end
    
    -- We'll implement this later
    VUI:Print("Profile manager not implemented yet. Use the slash commands or configuration panel.")
end

-- Select a profile (for the dropdown)
function Profiles:SelectProfile(profileName)
    if not self.enabled or not profileName then return end
    
    -- Just update the selection, don't load yet
    self.currentProfile = profileName
    
    -- If preview is enabled, we could show a preview here
    if self.settings.previewChanges then
        -- Implement preview functionality
    end
end

-- Collect current settings for a profile
function Profiles:CollectCurrentSettings()
    local settings = {}
    
    -- Collect global settings
    if self.settings.includeGlobalSettings and VUIDB then
        settings.global = CopyTable(VUIDB)
    end
    
    -- Collect character settings
    if self.settings.includeCharacterSettings and VUICharacterDB then
        settings.character = CopyTable(VUICharacterDB)
    end
    
    -- Collect UI layout
    if self.settings.includeUILayout then
        settings.layout = self:CollectUILayout()
    end
    
    -- Add metadata
    settings.metadata = {
        version = VUI.version,
        date = time(),
        character = UnitName("player"),
        realm = GetRealmName(),
        class = select(2, UnitClass("player")),
    }
    
    return settings
end

-- Collect UI layout information
function Profiles:CollectUILayout()
    local layout = {}
    
    -- This would collect the positions of various frames
    -- We'll implement a basic version
    
    -- Get positions of module frames
    for moduleName, module in pairs(VUI.modules) do
        if module.frames then
            layout[moduleName] = {}
            for frameName, frame in pairs(module.frames) do
                if frame and frame:GetPoint() then
                    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
                    layout[moduleName][frameName] = {
                        point = point,
                        relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
                        relativePoint = relativePoint,
                        xOfs = xOfs,
                        yOfs = yOfs,
                    }
                end
            end
        end
    end
    
    return layout
end

-- Apply settings from a profile
function Profiles:ApplySettings(profileData)
    if not profileData then return end
    
    -- Apply global settings
    if profileData.global and VUIDB then
        VUIDB = CopyTable(profileData.global)
    end
    
    -- Apply character settings
    if profileData.character and VUICharacterDB then
        VUICharacterDB = CopyTable(profileData.character)
    end
    
    -- Apply UI layout
    if profileData.layout then
        self:ApplyUILayout(profileData.layout)
    end
end

-- Apply UI layout from a profile
function Profiles:ApplyUILayout(layout)
    if not layout then return end
    
    -- This would restore the positions of various frames
    -- We'll implement a basic version
    
    -- Restore positions of module frames
    for moduleName, moduleLayout in pairs(layout) do
        if VUI.modules[moduleName] and VUI.modules[moduleName].frames then
            for frameName, frameLayout in pairs(moduleLayout) do
                local frame = VUI.modules[moduleName].frames[frameName]
                if frame then
                    frame:ClearAllPoints()
                    frame:SetPoint(
                        frameLayout.point,
                        frameLayout.relativeTo == "UIParent" and UIParent or _G[frameLayout.relativeTo],
                        frameLayout.relativePoint,
                        frameLayout.xOfs,
                        frameLayout.yOfs
                    )
                end
            end
        end
    end
end

-- Serialize a profile to a string
function Profiles:SerializeProfile(profileData)
    if not profileData then return "" end
    
    -- Convert the profile data to a string
    local serialized = VUI.Utils.TableToString(profileData)
    
    -- Compress if enabled
    if self.settings.compressExports then
        serialized = VUI.Utils.CompressString(serialized)
    end
    
    -- Add header for identification
    local header = string.format("VUI:%s:", self.settings.compressExports and "compressed" or "normal")
    
    return header .. serialized
end

-- Deserialize a string to a profile
function Profiles:DeserializeProfile(importString)
    if not importString or importString == "" then
        return false, nil
    end
    
    -- Check for header
    local header, format, data = importString:match("^(VUI:([%w]+):)(.+)")
    
    if not header or not format or not data then
        return false, nil
    end
    
    -- Decompress if needed
    if format == "compressed" then
        data = VUI.Utils.DecompressString(data)
        if not data then
            return false, nil
        end
    end
    
    -- Convert string back to table
    local success, profileData = pcall(VUI.Utils.StringToTable, data)
    
    if not success or not profileData then
        return false, nil
    end
    
    return true, profileData
end

-- Register the module with VUI
VUI.profiles = Profiles