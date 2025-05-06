-- VUI Profiles Module - Core Functionality
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local Profiles = VUI.profiles

-- Constants
local PROFILE_VERSION = 1.0

-- Utility functions to enhance the profile system
local Utils = {}

-- Convert a string to a table (safe deserialization)
function Utils.StringToTable(str)
    -- This is a basic implementation
    -- In a real addon, we would use proper serialization libraries
    local func, err = loadstring("return " .. str)
    if not func then
        error("Failed to deserialize: " .. (err or "unknown error"))
        return nil
    end
    
    -- Create a secure environment for execution
    setfenv(func, {})
    
    -- Get the table
    local success, result = pcall(func)
    if not success then
        error("Failed to execute deserialized data: " .. (result or "unknown error"))
        return nil
    end
    
    return result
end

-- Convert a table to a string (safe serialization)
function Utils.TableToString(tbl)
    -- This is a basic implementation
    -- In a real addon, we would use proper serialization libraries
    local result = "{"
    
    -- Helper function for recursion
    local function serializeValue(val)
        if type(val) == "string" then
            return string.format("%q", val)
        elseif type(val) == "number" or type(val) == "boolean" then
            return tostring(val)
        elseif type(val) == "table" then
            return Utils.TableToString(val)
        else
            return "nil"
        end
    end
    
    -- Process the table
    local first = true
    for k, v in pairs(tbl) do
        if not first then
            result = result .. ","
        end
        
        first = false
        
        if type(k) == "string" then
            result = result .. "[" .. string.format("%q", k) .. "]="
        else
            result = result .. "[" .. tostring(k) .. "]="
        end
        
        result = result .. serializeValue(v)
    end
    
    result = result .. "}"
    return result
end

-- Function to compress a string
function Utils.CompressString(str)
    -- This is a placeholder for a real compression function
    -- In a real addon, we would use a proper compression library
    -- For now, we'll just prefix with "compressed:"
    return "compressed:" .. str
end

-- Function to decompress a string
function Utils.DecompressString(str)
    -- This is a placeholder for a real decompression function
    -- In a real addon, we would use a proper decompression library
    -- For now, we'll just check for the prefix and remove it
    if str:sub(1, 11) == "compressed:" then
        return str:sub(12)
    end
    
    return nil
end

-- Add these utility functions to VUI.Utils
if not VUI.Utils then
    VUI.Utils = {}
end

VUI.Utils.TableToString = Utils.TableToString
VUI.Utils.StringToTable = Utils.StringToTable
VUI.Utils.CompressString = Utils.CompressString
VUI.Utils.DecompressString = Utils.DecompressString

-- Function to create a deep copy of a table
function Profiles:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Function to get the WoW version
function Profiles:GetWoWVersion()
    local version, build, date, tocversion = GetBuildInfo()
    return {
        version = version,
        build = build,
        date = date,
        tocversion = tocversion
    }
end

-- Function to get character information
function Profiles:GetCharacterInfo()
    return {
        name = UnitName("player"),
        realm = GetRealmName(),
        class = select(2, UnitClass("player")),
        race = select(2, UnitRace("player")),
        level = UnitLevel("player"),
        faction = UnitFactionGroup("player")
    }
end

-- Function to find all frame positions for a module
function Profiles:GetModuleFramePositions(moduleName)
    local positions = {}
    
    if VUI.modules[moduleName] and VUI.modules[moduleName].frames then
        for frameName, frame in pairs(VUI.modules[moduleName].frames) do
            positions[frameName] = self:GetFramePosition(frame)
        end
    end
    
    return positions
end

-- Function to get a frame's position
function Profiles:GetFramePosition(frame)
    if not frame or not frame.GetPoint or not frame:IsVisible() then
        return nil
    end
    
    local position = {}
    local numPoints = frame:GetNumPoints()
    
    for i = 1, numPoints do
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(i)
        position[i] = {
            point = point,
            relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs
        }
    end
    
    return position
end

-- Function to set a frame's position
function Profiles:SetFramePosition(frame, position)
    if not frame or not position then
        return
    end
    
    frame:ClearAllPoints()
    
    for i, posInfo in ipairs(position) do
        local relativeTo = posInfo.relativeTo == "UIParent" and UIParent or _G[posInfo.relativeTo]
        if relativeTo then
            frame:SetPoint(
                posInfo.point,
                relativeTo,
                posInfo.relativePoint,
                posInfo.xOfs,
                posInfo.yOfs
            )
        end
    end
end

-- Function to create a profile summary for display
function Profiles:CreateProfileSummary(profileData)
    if not profileData or not profileData.metadata then
        return "Unknown profile"
    end
    
    local metadata = profileData.metadata
    local summary = {}
    
    table.insert(summary, string.format("Profile Version: %s", metadata.version or "Unknown"))
    
    if metadata.date then
        table.insert(summary, string.format("Created: %s", date("%Y-%m-%d %H:%M", metadata.date)))
    end
    
    if metadata.character and metadata.realm then
        table.insert(summary, string.format("Character: %s-%s", metadata.character, metadata.realm))
    end
    
    if metadata.class then
        local className = LOCALIZED_CLASS_NAMES_MALE[metadata.class] or metadata.class
        table.insert(summary, string.format("Class: %s", className))
    end
    
    -- Count enabled modules
    local enabledModules = 0
    if profileData.global and profileData.global.modules then
        for _, moduleInfo in pairs(profileData.global.modules) do
            if moduleInfo.enabled then
                enabledModules = enabledModules + 1
            end
        end
        
        table.insert(summary, string.format("Enabled Modules: %d", enabledModules))
    end
    
    return table.concat(summary, "\n")
end

-- Function to verify profile compatibility
function Profiles:VerifyProfileCompatibility(profileData)
    if not profileData or not profileData.metadata then
        return false, "Invalid profile data"
    end
    
    local metadata = profileData.metadata
    
    -- Check version compatibility
    if metadata.version then
        local profileVersion = tonumber(metadata.version)
        local currentVersion = tonumber(VUI.version)
        
        if profileVersion and currentVersion and (profileVersion > currentVersion) then
            return false, string.format(
                "Profile version (%s) is newer than your VUI version (%s). This may cause issues.",
                metadata.version,
                VUI.version
            )
        end
    end
    
    return true, "Profile is compatible"
end

-- Function to display profile details
function Profiles:DisplayProfileDetails(profileName)
    if not profileName or not self.settings.savedProfiles[profileName] then
        VUI:Print("Profile not found.")
        return
    end
    
    local profile = self.settings.savedProfiles[profileName]
    local summary = self:CreateProfileSummary(profile.data)
    
    VUI:Print(string.format("Profile: %s", profileName))
    VUI:Print(summary:gsub("\n", "\n  "))
end

-- Function to compare two profiles
function Profiles:CompareProfiles(profile1Name, profile2Name)
    local profile1 = self.settings.savedProfiles[profile1Name]
    local profile2 = self.settings.savedProfiles[profile2Name]
    
    if not profile1 or not profile2 then
        VUI:Print("One or both profiles not found.")
        return
    end
    
    local differences = {}
    
    -- Compare metadata
    if profile1.data.metadata.version ~= profile2.data.metadata.version then
        table.insert(differences, string.format("Version: %s vs %s", 
            profile1.data.metadata.version, profile2.data.metadata.version))
    end
    
    -- Compare modules
    if profile1.data.global and profile2.data.global and 
       profile1.data.global.modules and profile2.data.global.modules then
        
        local modules1 = profile1.data.global.modules
        local modules2 = profile2.data.global.modules
        
        for moduleName, moduleInfo1 in pairs(modules1) do
            local moduleInfo2 = modules2[moduleName]
            
            if moduleInfo2 then
                -- Module exists in both profiles
                if moduleInfo1.enabled ~= moduleInfo2.enabled then
                    table.insert(differences, string.format("Module %s: %s vs %s", 
                        moduleName, moduleInfo1.enabled and "Enabled" or "Disabled", 
                        moduleInfo2.enabled and "Enabled" or "Disabled"))
                end
            else
                -- Module only exists in profile1
                table.insert(differences, string.format("Module %s: Only in %s", 
                    moduleName, profile1Name))
            end
        end
        
        for moduleName, moduleInfo2 in pairs(modules2) do
            if not modules1[moduleName] then
                -- Module only exists in profile2
                table.insert(differences, string.format("Module %s: Only in %s", 
                    moduleName, profile2Name))
            end
        end
    end
    
    -- Display results
    if #differences == 0 then
        VUI:Print(string.format("Profiles %s and %s are identical.", profile1Name, profile2Name))
    else
        VUI:Print(string.format("Differences between %s and %s:", profile1Name, profile2Name))
        for _, diff in ipairs(differences) do
            VUI:Print("  " .. diff)
        end
    end
end

-- Function to merge two profiles
function Profiles:MergeProfiles(targetProfileName, sourceProfileName, newProfileName)
    local targetProfile = self.settings.savedProfiles[targetProfileName]
    local sourceProfile = self.settings.savedProfiles[sourceProfileName]
    
    if not targetProfile or not sourceProfile then
        VUI:Print("One or both profiles not found.")
        return
    end
    
    -- Create a copy of the target profile
    local mergedProfile = self:DeepCopy(targetProfile)
    
    -- Merge in elements from the source profile
    -- This is a simplified implementation
    if mergedProfile.data.global and sourceProfile.data.global then
        -- Merge modules
        if mergedProfile.data.global.modules and sourceProfile.data.global.modules then
            for moduleName, moduleInfo in pairs(sourceProfile.data.global.modules) do
                if not mergedProfile.data.global.modules[moduleName] then
                    mergedProfile.data.global.modules[moduleName] = self:DeepCopy(moduleInfo)
                end
            end
        end
    end
    
    -- Update metadata
    mergedProfile.data.metadata.date = time()
    mergedProfile.data.metadata.merged = {
        from = {targetProfileName, sourceProfileName},
        date = time()
    }
    
    -- Save as a new profile
    self.settings.savedProfiles[newProfileName] = {
        name = newProfileName,
        timestamp = time(),
        data = mergedProfile.data
    }
    
    VUI:Print(string.format("Created merged profile '%s' from '%s' and '%s'.", 
        newProfileName, targetProfileName, sourceProfileName))
end

-- Function to rename a profile
function Profiles:RenameProfile(oldName, newName)
    if not self.settings.savedProfiles[oldName] then
        VUI:Print(string.format("Profile '%s' not found.", oldName))
        return
    end
    
    if self.settings.savedProfiles[newName] then
        VUI:Print(string.format("Profile '%s' already exists.", newName))
        return
    end
    
    -- Create a copy with the new name
    self.settings.savedProfiles[newName] = self:DeepCopy(self.settings.savedProfiles[oldName])
    self.settings.savedProfiles[newName].name = newName
    
    -- Delete the old profile
    self.settings.savedProfiles[oldName] = nil
    
    -- Update current profile if needed
    if self.currentProfile == oldName then
        self.currentProfile = newName
    end
    
    VUI:Print(string.format("Renamed profile '%s' to '%s'.", oldName, newName))
end

-- Function to duplicate a profile
function Profiles:DuplicateProfile(sourceName, newName)
    if not self.settings.savedProfiles[sourceName] then
        VUI:Print(string.format("Profile '%s' not found.", sourceName))
        return
    end
    
    if self.settings.savedProfiles[newName] then
        VUI:Print(string.format("Profile '%s' already exists.", newName))
        return
    end
    
    -- Create a copy with the new name
    self.settings.savedProfiles[newName] = self:DeepCopy(self.settings.savedProfiles[sourceName])
    self.settings.savedProfiles[newName].name = newName
    self.settings.savedProfiles[newName].timestamp = time()
    
    -- Update metadata
    self.settings.savedProfiles[newName].data.metadata.date = time()
    self.settings.savedProfiles[newName].data.metadata.copied_from = sourceName
    
    VUI:Print(string.format("Duplicated profile '%s' as '%s'.", sourceName, newName))
    
    return newName
end

-- Function to export a specific profile
function Profiles:ExportSpecificProfile(profileName)
    if not profileName or not self.settings.savedProfiles[profileName] then
        VUI:Print("Profile not found.")
        return
    end
    
    -- Get profile data
    local profileData = self.settings.savedProfiles[profileName].data
    
    -- Convert to string
    local exportString = self:SerializeProfile(profileData)
    
    -- Show export frame
    self.importExportFrame.Title:SetText(string.format("Export Profile: %s", profileName))
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

-- Function to import a profile with a specific name
function Profiles:ImportProfileWithName(importString, profileName)
    if not self.enabled or not importString or importString == "" or not profileName or profileName == "" then 
        return 
    end
    
    -- Deserialize the string to get profile data
    local success, profileData = self:DeserializeProfile(importString)
    
    if not success then
        VUI:Print("Failed to import profile: Invalid profile data.")
        return
    end
    
    -- Save as a new profile
    self.settings.savedProfiles[profileName] = {
        name = profileName,
        timestamp = time(),
        data = profileData
    }
    
    VUI:Print(string.format("Profile imported and saved as '%s'.", profileName))
    
    -- Store import timestamp
    self.settings.lastImported = time()
    
    return profileName
end

-- Function to create a report of all profiles
function Profiles:CreateProfileReport()
    local profiles = self:GetSavedProfilesList()
    
    if #profiles == 0 then
        VUI:Print("No saved profiles found.")
        return
    end
    
    local report = {"VUI Profile Report\n"}
    
    for _, profileName in ipairs(profiles) do
        local profile = self.settings.savedProfiles[profileName]
        table.insert(report, string.format("Profile: %s", profileName))
        table.insert(report, string.format("  Created: %s", date("%Y-%m-%d %H:%M", profile.timestamp)))
        
        if profile.data and profile.data.metadata then
            local metadata = profile.data.metadata
            table.insert(report, string.format("  Version: %s", metadata.version or "Unknown"))
            
            if metadata.character and metadata.realm then
                table.insert(report, string.format("  Character: %s-%s", metadata.character, metadata.realm))
            end
            
            if metadata.class then
                local className = LOCALIZED_CLASS_NAMES_MALE[metadata.class] or metadata.class
                table.insert(report, string.format("  Class: %s", className))
            end
        end
        
        table.insert(report, "")
    end
    
    -- Show report in frame
    self.importExportFrame.Title:SetText("Profile Report")
    self.importExportFrame.EditBox:SetText(table.concat(report, "\n"))
    self.importExportFrame.EditBox:SetFocus()
    
    self.importExportFrame.AcceptButton:SetText("Close")
    self.importExportFrame.AcceptButton:SetScript("OnClick", function()
        self.importExportFrame:Hide()
    end)
    
    self.importExportFrame:Show()
end

-- Enhanced profile manager UI
function Profiles:EnhancedProfileManager()
    if not self.enabled then return end
    
    -- This is a placeholder for a more sophisticated profile manager UI
    -- In a real addon, this would be implemented with proper widgets and frames
    
    VUI:Print("Enhanced Profile Manager:")
    
    -- Display profiles
    local profiles = self:GetSavedProfilesList()
    
    if #profiles == 0 then
        VUI:Print("No saved profiles found.")
    else
        VUI:Print("Saved Profiles:")
        for i, profileName in ipairs(profiles) do
            local profile = self.settings.savedProfiles[profileName]
            VUI:Print(string.format("%d. %s (Created: %s)", 
                i, profileName, date("%Y-%m-%d %H:%M", profile.timestamp)))
        end
        
        VUI:Print("\nUse the following commands to manage profiles:")
        VUI:Print("  /vuiprofile load <name> - Load a profile")
        VUI:Print("  /vuiprofile update <name> - Update a profile")
        VUI:Print("  /vuiprofile delete <name> - Delete a profile")
        VUI:Print("  /vuiprofile export <name> - Export a profile")
    end
    
    -- Display backups
    local backups = self:GetBackupsList()
    
    if #backups > 0 then
        VUI:Print("\nProfile Backups:")
        for i, backupName in ipairs(backups) do
            local backup = self.settings.profileBackups[backupName]
            VUI:Print(string.format("%d. %s (Created: %s)", 
                i, backupName, date("%Y-%m-%d %H:%M", backup.timestamp)))
        end
        
        VUI:Print("\nUse /vuiprofile restore <backup_name> to restore a backup.")
    end
end

-- Register the profiles with VUI
VUI.profiles = Profiles