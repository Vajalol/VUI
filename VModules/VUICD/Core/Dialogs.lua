-- VUICD: Dialog Popups
-- Handles various confirmation dialogs and user interactions

local AddonName, VUI = ...
local CD = VUI.VUICD
local L = CD.L

-- AceGUI for our dialogs
local AceGUI = LibStub("AceGUI-3.0")

-- Create a namespace for all dialogs
CD.Dialogs = {}

-- Dialog Types
local DIALOG_TYPES = {
    CONFIRM_DELETE_PROFILE = 1,
    CONFIRM_RESET_PROFILE = 2,
    CONFIRM_CLEAR_SPELLS = 3,
    CONFIRM_IMPORT_PROFILE = 4,
    CONFIRM_EXPORT_PROFILE = 5,
}

-- Store dialog type for reference
CD.Dialogs.TYPES = DIALOG_TYPES

-- Create a dialog frame
function CD.Dialogs:Create(dialogType, data)
    -- Close any existing dialog
    self:CloseAll()
    
    -- Common dialog setup
    local frame = AceGUI:Create("Frame")
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    frame:SetLayout("Flow")
    frame:SetWidth(400)
    frame:SetHeight(200)
    
    -- Build dialog content based on type
    if dialogType == DIALOG_TYPES.CONFIRM_DELETE_PROFILE then
        self:BuildDeleteProfileDialog(frame, data)
    elseif dialogType == DIALOG_TYPES.CONFIRM_RESET_PROFILE then
        self:BuildResetProfileDialog(frame, data)
    elseif dialogType == DIALOG_TYPES.CONFIRM_CLEAR_SPELLS then
        self:BuildClearSpellsDialog(frame, data)
    elseif dialogType == DIALOG_TYPES.CONFIRM_IMPORT_PROFILE then
        self:BuildImportProfileDialog(frame, data)
    elseif dialogType == DIALOG_TYPES.CONFIRM_EXPORT_PROFILE then
        self:BuildExportProfileDialog(frame, data)
    end
    
    -- Save active dialog reference
    self.currentDialog = frame
    
    return frame
end

-- Close all dialogs
function CD.Dialogs:CloseAll()
    if self.currentDialog then
        self.currentDialog:Release()
        self.currentDialog = nil
    end
end

-- Build dialog for deleting a profile
function CD.Dialogs:BuildDeleteProfileDialog(frame, data)
    local profileName = data.profileName
    
    frame:SetTitle(L["Delete Profile"])
    
    -- Warning text
    local desc = AceGUI:Create("Label")
    desc:SetText(string.format(L["Are you sure you want to delete the profile '%s'? This cannot be undone."], profileName))
    desc:SetFullWidth(true)
    frame:AddChild(desc)
    
    -- Button layout container
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    frame:AddChild(buttonGroup)
    
    -- Cancel button
    local cancelBtn = AceGUI:Create("Button")
    cancelBtn:SetText(L["Cancel"])
    cancelBtn:SetWidth(150)
    cancelBtn:SetCallback("OnClick", function()
        frame:Release()
    end)
    buttonGroup:AddChild(cancelBtn)
    
    -- Delete button
    local deleteBtn = AceGUI:Create("Button")
    deleteBtn:SetText(L["Delete"])
    deleteBtn:SetWidth(150)
    deleteBtn:SetCallback("OnClick", function()
        if data.callback then
            data.callback(profileName)
        end
        frame:Release()
    end)
    buttonGroup:AddChild(deleteBtn)
end

-- Build dialog for resetting profile
function CD.Dialogs:BuildResetProfileDialog(frame, data)
    frame:SetTitle(L["Reset Profile"])
    
    -- Warning text
    local desc = AceGUI:Create("Label")
    desc:SetText(L["Are you sure you want to reset the current profile? This will restore all default settings."])
    desc:SetFullWidth(true)
    frame:AddChild(desc)
    
    -- Button layout container
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    frame:AddChild(buttonGroup)
    
    -- Cancel button
    local cancelBtn = AceGUI:Create("Button")
    cancelBtn:SetText(L["Cancel"])
    cancelBtn:SetWidth(150)
    cancelBtn:SetCallback("OnClick", function()
        frame:Release()
    end)
    buttonGroup:AddChild(cancelBtn)
    
    -- Reset button
    local resetBtn = AceGUI:Create("Button")
    resetBtn:SetText(L["Reset"])
    resetBtn:SetWidth(150)
    resetBtn:SetCallback("OnClick", function()
        if data.callback then
            data.callback()
        end
        frame:Release()
    end)
    buttonGroup:AddChild(resetBtn)
end

-- Build dialog for clearing spells
function CD.Dialogs:BuildClearSpellsDialog(frame, data)
    frame:SetTitle(L["Clear Spells"])
    
    -- Warning text
    local desc = AceGUI:Create("Label")
    desc:SetText(L["Are you sure you want to clear all spell settings? This cannot be undone."])
    desc:SetFullWidth(true)
    frame:AddChild(desc)
    
    -- Button layout container
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    frame:AddChild(buttonGroup)
    
    -- Cancel button
    local cancelBtn = AceGUI:Create("Button")
    cancelBtn:SetText(L["Cancel"])
    cancelBtn:SetWidth(150)
    cancelBtn:SetCallback("OnClick", function()
        frame:Release()
    end)
    buttonGroup:AddChild(cancelBtn)
    
    -- Clear button
    local clearBtn = AceGUI:Create("Button")
    clearBtn:SetText(L["Clear"])
    clearBtn:SetWidth(150)
    clearBtn:SetCallback("OnClick", function()
        if data.callback then
            data.callback()
        end
        frame:Release()
    end)
    buttonGroup:AddChild(clearBtn)
end

-- Build dialog for importing a profile
function CD.Dialogs:BuildImportProfileDialog(frame, data)
    frame:SetTitle(L["Import Profile"])
    frame:SetHeight(350)
    
    -- Description
    local desc = AceGUI:Create("Label")
    desc:SetText(L["Paste a profile string below to import settings:"])
    desc:SetFullWidth(true)
    frame:AddChild(desc)
    
    -- Import string input
    local input = AceGUI:Create("MultiLineEditBox")
    input:SetLabel("")
    input:SetFullWidth(true)
    input:SetNumLines(10)
    input:DisableButton(true)
    frame:AddChild(input)
    
    -- Button layout container
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    frame:AddChild(buttonGroup)
    
    -- Cancel button
    local cancelBtn = AceGUI:Create("Button")
    cancelBtn:SetText(L["Cancel"])
    cancelBtn:SetWidth(150)
    cancelBtn:SetCallback("OnClick", function()
        frame:Release()
    end)
    buttonGroup:AddChild(cancelBtn)
    
    -- Import button
    local importBtn = AceGUI:Create("Button")
    importBtn:SetText(L["Import"])
    importBtn:SetWidth(150)
    importBtn:SetCallback("OnClick", function()
        local importString = input:GetText()
        if importString and importString ~= "" then
            if data.callback then
                data.callback(importString)
            end
        end
        frame:Release()
    end)
    buttonGroup:AddChild(importBtn)
end

-- Build dialog for exporting a profile
function CD.Dialogs:BuildExportProfileDialog(frame, data)
    frame:SetTitle(L["Export Profile"])
    frame:SetHeight(350)
    
    -- Description
    local desc = AceGUI:Create("Label")
    desc:SetText(L["Copy the string below to share your profile:"])
    desc:SetFullWidth(true)
    frame:AddChild(desc)
    
    -- Export string display
    local output = AceGUI:Create("MultiLineEditBox")
    output:SetLabel("")
    output:SetFullWidth(true)
    output:SetNumLines(10)
    output:DisableButton(true)
    
    -- Set the export string if provided
    if data and data.exportString then
        output:SetText(data.exportString)
        output:HighlightText()
        output:SetFocus()
    end
    
    frame:AddChild(output)
    
    -- Close button
    local closeBtn = AceGUI:Create("Button")
    closeBtn:SetText(L["Close"])
    closeBtn:SetFullWidth(true)
    closeBtn:SetCallback("OnClick", function()
        frame:Release()
    end)
    frame:AddChild(closeBtn)
end