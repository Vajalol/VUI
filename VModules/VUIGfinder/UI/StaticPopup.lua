-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create StaticPopups namespace
VUIGfinder.StaticPopups = {}
local StaticPopups = VUIGfinder.StaticPopups

-- Callback storage
StaticPopups.confirmCallback = nil
StaticPopups.inputCallback = nil

-- Show confirmation dialog
function StaticPopups:ShowConfirmation(title, text, callback)
    if not VUIGfinderConfirmationDialog then return end
    
    -- Store callback
    self.confirmCallback = callback
    
    -- Set dialog text
    VUIGfinderConfirmationDialog.Title:SetText(title or L["Confirmation"])
    VUIGfinderConfirmationDialogText:SetText(text or L["Are you sure?"])
    
    -- Set button text
    VUIGfinderConfirmationDialogYesButton:SetText(ACCEPT)
    VUIGfinderConfirmationDialogNoButton:SetText(CANCEL)
    
    -- Show dialog
    VUIGfinderConfirmationDialog:Show()
end

-- Execute the stored confirmation callback
function StaticPopups.ConfirmAction()
    if StaticPopups.confirmCallback then
        StaticPopups.confirmCallback()
        StaticPopups.confirmCallback = nil
    end
end

-- Show input dialog
function StaticPopups:ShowInput(title, text, defaultValue, callback)
    if not VUIGfinderInputDialog then return end
    
    -- Store callback
    self.inputCallback = callback
    
    -- Set dialog text
    VUIGfinderInputDialog.Title:SetText(title or L["Input"])
    VUIGfinderInputDialogText:SetText(text or L["Enter value:"])
    
    -- Set default value if provided
    VUIGfinderInputDialogInput:SetText(defaultValue or "")
    VUIGfinderInputDialogInput:HighlightText()
    
    -- Set button text
    VUIGfinderInputDialogOkButton:SetText(ACCEPT)
    VUIGfinderInputDialogCancelButton:SetText(CANCEL)
    
    -- Show dialog
    VUIGfinderInputDialog:Show()
end

-- Execute the stored input callback
function StaticPopups.ConfirmInput(input)
    if StaticPopups.inputCallback then
        StaticPopups.inputCallback(input)
        StaticPopups.inputCallback = nil
    end
end

-- Show a simple alert dialog
function StaticPopups:ShowAlert(title, text)
    -- Use the standard confirmation dialog but without the Yes button
    if not VUIGfinderConfirmationDialog then return end
    
    -- Set dialog text
    VUIGfinderConfirmationDialog.Title:SetText(title or L["Alert"])
    VUIGfinderConfirmationDialogText:SetText(text or "")
    
    -- Hide Yes button, rename No button to OK
    VUIGfinderConfirmationDialogYesButton:Hide()
    VUIGfinderConfirmationDialogNoButton:SetText(OKAY)
    VUIGfinderConfirmationDialogNoButton:ClearAllPoints()
    VUIGfinderConfirmationDialogNoButton:SetPoint("BOTTOM", VUIGfinderConfirmationDialog, "BOTTOM", 0, 20)
    
    -- Show dialog
    VUIGfinderConfirmationDialog:Show()
    
    -- Setup callback to restore button positions when dialog is closed
    VUIGfinderConfirmationDialog:SetScript("OnHide", function()
        VUIGfinderConfirmationDialogYesButton:Show()
        VUIGfinderConfirmationDialogNoButton:ClearAllPoints()
        VUIGfinderConfirmationDialogNoButton:SetPoint("BOTTOMLEFT", VUIGfinderConfirmationDialog, "BOTTOM", 10, 20)
        
        -- Remove this temporary OnHide handler
        VUIGfinderConfirmationDialog:SetScript("OnHide", nil)
    end)
end