-- VUICD: Profile Sharing
-- Handles export and import of profile data

local AddonName, VUI = ...
local CD = VUI.VUICD
local L = CD.L

-- Libraries
local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

-- Create profile sharing namespace
CD.ProfileSharing = {}

-- Encoding and compression options
local EXPORT_PREFIX = "VUICD:"
local EXPORT_VERSION = 1

-- Pack a profile for export
-- Returns a serialized and compressed string representing the profile
function CD.ProfileSharing:ExportProfile()
    -- Get current profile settings
    local profileSettings = self:GetCurrentProfileSettings()
    
    -- Add metadata
    local exportData = {
        version = EXPORT_VERSION,
        timestamp = time(),
        profileName = CD.db:GetCurrentProfile(),
        settings = profileSettings
    }
    
    -- Serialize the data to a string
    local serialized = AceSerializer:Serialize(exportData)
    if not serialized then
        return nil, "Serialization failed"
    end
    
    -- Compress the string
    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    if not compressed then
        return nil, "Compression failed"
    end
    
    -- Encode for safe string transfer (printable ASCII)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    if not encoded then
        return nil, "Encoding failed"
    end
    
    -- Final export string
    return EXPORT_PREFIX .. encoded
end

-- Parse an import string and apply the profile
-- Returns success status and message
function CD.ProfileSharing:ImportProfile(importString)
    -- Remove any whitespace
    importString = importString:gsub("%s+", "")
    
    -- Verify the string starts with our prefix
    if not importString:match("^" .. EXPORT_PREFIX) then
        return false, L["Invalid import string format"]
    end
    
    -- Extract the encoded portion
    local encoded = importString:sub(#EXPORT_PREFIX + 1)
    
    -- Decode from print-safe format
    local compressed = LibDeflate:DecodeForPrint(encoded)
    if not compressed then
        return false, L["Failed to decode import string"]
    end
    
    -- Decompress
    local serialized = LibDeflate:DecompressDeflate(compressed)
    if not serialized then
        return false, L["Failed to decompress import string"]
    end
    
    -- Deserialize
    local success, importData = AceSerializer:Deserialize(serialized)
    if not success or type(importData) ~= "table" then
        return false, L["Failed to deserialize import string"]
    end
    
    -- Verify version compatibility
    if not importData.version or importData.version > EXPORT_VERSION then
        return false, L["Import string is from a newer version and cannot be imported"]
    end
    
    -- Apply the imported settings
    return self:ApplyImportedProfile(importData)
end

-- Get current profile settings
function CD.ProfileSharing:GetCurrentProfileSettings()
    -- Get a deep copy of the current profile
    local currentProfile = CD.db:GetCurrentProfile()
    local profileSettings = CD.db.profiles[currentProfile]
    
    -- Create a deep copy to avoid reference issues
    return self:DeepCopy(profileSettings)
end

-- Apply imported profile settings to the current profile
function CD.ProfileSharing:ApplyImportedProfile(importData)
    if not importData or not importData.settings then
        return false, L["Import data is missing required fields"]
    end
    
    -- Get current profile and a new name for the imported profile
    local currentProfile = CD.db:GetCurrentProfile()
    local importName = importData.profileName or "ImportedProfile"
    local newProfileName = importName
    
    -- Make sure profile name is unique
    local i = 1
    while CD.db.profiles[newProfileName] do
        newProfileName = importName .. i
        i = i + 1
    end
    
    -- Create new profile
    CD.db:SetProfile(newProfileName)
    
    -- Apply settings
    for k, v in pairs(importData.settings) do
        -- Skip certain keys that should not be imported
        if k ~= "name" and k ~= "version" then
            CD.db[k] = self:DeepCopy(v)
        end
    end
    
    -- Update the UI
    CD:RefreshConfig()
    
    return true, string.format(L["Profile '%s' successfully imported"], newProfileName)
end

-- Deep copy a table
function CD.ProfileSharing:DeepCopy(src)
    if type(src) ~= "table" then
        return src
    end
    
    local dest = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = self:DeepCopy(v)
        else
            dest[k] = v
        end
    end
    
    return dest
end

-- Show export dialog
function CD.ProfileSharing:ShowExportDialog()
    local exportString = self:ExportProfile()
    if not exportString then
        CD:Print(L["Failed to generate export string"])
        return
    end
    
    CD.Dialogs:Create(CD.Dialogs.TYPES.CONFIRM_EXPORT_PROFILE, {
        exportString = exportString
    })
end

-- Show import dialog
function CD.ProfileSharing:ShowImportDialog()
    CD.Dialogs:Create(CD.Dialogs.TYPES.CONFIRM_IMPORT_PROFILE, {
        callback = function(importString)
            local success, message = self:ImportProfile(importString)
            CD:Print(message)
        end
    })
end