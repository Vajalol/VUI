-- VUITGCD MasqueHelper.lua
-- Provides integration with the Masque addon for skinning

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace
if not ns.masqueHelper then ns.masqueHelper = {} end

-- Check for Masque addon
local Masque = LibStub and LibStub("Masque", true)

-- Group reference
local masqueGroup = nil

---@return boolean
function ns.masqueHelper.IsMasqueAvailable()
    return Masque ~= nil
end

---@param buttonData table
function ns.masqueHelper.AddButton(buttonData)
    if not Masque or not masqueGroup or not buttonData then return end
    
    masqueGroup:AddButton(buttonData)
end

---@param buttonData table
function ns.masqueHelper.RemoveButton(buttonData)
    if not Masque or not masqueGroup or not buttonData then return end
    
    masqueGroup:RemoveButton(buttonData)
end

-- Initialize Masque group
function ns.masqueHelper.Initialize()
    if not Masque then return end
    
    -- Create group
    masqueGroup = Masque:Group("VUI", "Ability History")
    
    -- Hook ReskinCallback
    if masqueGroup then
        masqueGroup.ReskinCallback = function()
            -- This will be called when Masque applies skins
            -- To be implemented with full icon functionality
        end
    end
end

-- Update all buttons with new skin
function ns.masqueHelper.Update()
    if not Masque or not masqueGroup then return end
    
    masqueGroup:ReSkin()
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.MasqueHelper = ns.masqueHelper
end

-- Initialize when PLAYER_LOGIN occurs
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        ns.masqueHelper.Initialize()
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)