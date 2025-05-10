local _, VUI = ...
local E = VUI:GetModule("VUICD")
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")
local LibDeflate = LibStub("LibDeflate")
local AceSerializer = LibStub("AceSerializer-3.0")

-- Profile sharing system for VUICD
local profileSharing = {}

function E:InitializeProfileSharing()
    -- Add serialization/deserialization methods
    function E:SerializeProfile(profileType, profileKey)
        local profiles
        
        if profileType == "VUICD" then
            profiles = E.DB.profiles
        elseif profileType == "Party" then
            profiles = E.Party.db.profiles
        else
            return nil, "Invalid profile type"
        end
        
        local profile = profiles[profileKey]
        if not profile then
            return nil, "Profile not found"
        end
        
        local serialized = AceSerializer:Serialize(profile)
        local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
        local encoded = LibDeflate:EncodeForPrint(compressed)
        
        return encoded, nil
    end
    
    function E:DeserializeProfile(encoded, profileType, profileKey)
        if not encoded or encoded == "" then
            return nil, "No profile data provided"
        end
        
        local decoded = LibDeflate:DecodeForPrint(encoded)
        if not decoded then
            return nil, "Failed to decode profile data"
        end
        
        local decompressed = LibDeflate:DecompressDeflate(decoded)
        if not decompressed then
            return nil, "Failed to decompress profile data"
        end
        
        local success, profile = AceSerializer:Deserialize(decompressed)
        if not success then
            return nil, "Failed to deserialize profile data"
        end
        
        -- Apply the profile based on type
        if profileType == "VUICD" then
            E.DB.profiles[profileKey] = profile
        elseif profileType == "Party" then
            E.Party.db.profiles[profileKey] = profile
        else
            return nil, "Invalid profile type"
        end
        
        return true, nil
    end
    
    -- Add profile sharing to export/import dialog
    function E:ShowExportDialog(profileType, profileKey)
        if not profileType or not profileKey then
            VUI:Print(L["No profile selected for export"])
            return
        end
        
        local encoded, err = E:SerializeProfile(profileType, profileKey)
        if not encoded then
            VUI:Print(L["Export error:"] .. " " .. (err or "unknown error"))
            return
        end
        
        -- Use VUI dialog system to show export dialog
        if VUI.Dialogs and VUI.Dialogs.CreateStringDialog then
            VUI.Dialogs:CreateStringDialog(
                L["Export Profile"],
                L["Copy the text below to share your profile:"],
                encoded,
                true -- readonly
            )
        else
            -- Fallback to default dialog
            StaticPopupDialogs["VUICD_EXPORT_DIALOG"] = {
                text = L["Copy the text below to share your profile:"],
                button1 = OKAY,
                timeout = 0,
                whileDead = true,
                hasEditBox = true,
                editBoxWidth = 350,
                OnShow = function(self, data)
                    self.editBox:SetText(encoded)
                    self.editBox:HighlightText()
                    self.editBox:SetFocus()
                end,
                EditBoxOnEscapePressed = function(self)
                    self:GetParent():Hide()
                end,
                preferredIndex = 3,
            }
            StaticPopup_Show("VUICD_EXPORT_DIALOG")
        end
    end
    
    function E:ShowImportDialog(profileType, profileKey)
        if not profileType or not profileKey then
            VUI:Print(L["No profile selected for import"])
            return
        end
        
        -- Use VUI dialog system to show import dialog
        if VUI.Dialogs and VUI.Dialogs.CreateStringDialog then
            VUI.Dialogs:CreateStringDialog(
                L["Import Profile"],
                L["Paste profile data here:"],
                "",
                false, -- not readonly
                function(importString)
                    local success, err = E:DeserializeProfile(importString, profileType, profileKey)
                    if not success then
                        VUI:Print(L["Import error:"] .. " " .. (err or "unknown error"))
                    else
                        VUI:Print(L["Profile imported successfully"])
                        E:Refresh() -- Update UI after import
                    end
                end
            )
        else
            -- Fallback to default dialog
            StaticPopupDialogs["VUICD_IMPORT_DIALOG"] = {
                text = L["Paste profile data here:"],
                button1 = ACCEPT,
                button2 = CANCEL,
                timeout = 0,
                whileDead = true,
                hasEditBox = true,
                editBoxWidth = 350,
                OnAccept = function(self, data)
                    local importString = self.editBox:GetText()
                    local success, err = E:DeserializeProfile(importString, profileType, profileKey)
                    if not success then
                        VUI:Print(L["Import error:"] .. " " .. (err or "unknown error"))
                    else
                        VUI:Print(L["Profile imported successfully"])
                        E:Refresh() -- Update UI after import
                    end
                end,
                EditBoxOnEscapePressed = function(self)
                    self:GetParent():Hide()
                end,
                preferredIndex = 3,
            }
            StaticPopup_Show("VUICD_IMPORT_DIALOG")
        end
    end
end