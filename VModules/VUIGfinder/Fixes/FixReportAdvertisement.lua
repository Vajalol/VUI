-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-------------------------------------------------------------------------------
-- FixReportAdvertisement
-- 
-- This fix adds enhanced functionality to the report group advertisement feature
-- to make it easier to report inappropriate group listings.
-------------------------------------------------------------------------------

-- Only load this fix in retail WoW
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

local function IsReportAdvertisementAvailable()
    return C_LFGList and C_LFGList.ReportAdvertisement ~= nil
end

-- Setup hook for context menu
local function FixReportAdvertisementButton()
    if not IsReportAdvertisementAvailable() then return end
    
    -- No need to hook if we've already done so
    if VUIGfinder.isReportAdvertisementFixed then return end
    
    -- Hook the context menu creation function
    hooksecurefunc("LFGListSearchEntry_OnClick", function(self, button)
        if button ~= "RightButton" then return end
        
        -- Add report option to the context menu
        local resultID = self.resultID
        if resultID and C_LFGList.CanReportAdvertisement(resultID) then
            local info = UIDropDownMenu_CreateInfo()
            info.text = REPORT_GROUP_FINDER_ADVERTISEMENT
            info.notCheckable = true
            info.func = function()
                C_LFGList.ReportAdvertisement(resultID)
                VUIGfinder.Logger:Debug("Reported advertisement ID: " .. resultID)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    VUIGfinder.isReportAdvertisementFixed = true
    VUIGfinder.Logger:Info("Report Advertisement fix applied")
end

-- Initialize the fix when addon loads
local function Initialize()
    if IsReportAdvertisementAvailable() then
        FixReportAdvertisementButton()
    else
        VUIGfinder.Logger:Warning("Report Advertisement function not available in this client")
    end
end

VUIGfinder:RegisterCallback("OnInitialize", Initialize)