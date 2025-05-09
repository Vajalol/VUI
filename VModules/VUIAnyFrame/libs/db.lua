-- VUIAnyFrame - Database Helper Functions
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")

-- Database helper functions
function VUIAnyFrame:GetWoWBuild()
    local _, _, _, tocversion = GetBuildInfo()
    return tonumber(tocversion)
end

function VUIAnyFrame:IsRetail()
    local build = self:GetWoWBuild()
    return build >= 90000
end

function VUIAnyFrame:IsTBC()
    local build = self:GetWoWBuild()
    return build > 20000 and build < 30000
end

function VUIAnyFrame:IsWrath()
    local build = self:GetWoWBuild()
    return build > 30000 and build < 40000
end

function VUIAnyFrame:IsCata()
    local build = self:GetWoWBuild()
    return build > 40000 and build < 50000
end

-- Frame existence checking
function VUIAnyFrame:DoesFrameExist(frameName)
    if not frameName then return false end
    
    if type(frameName) == "string" then
        return _G[frameName] ~= nil
    elseif type(frameName) == "table" then
        return true
    end
    
    return false
end

-- Safely check if a frame exists before registering
function VUIAnyFrame:SafeRegisterWidget(frameName, displayName, category)
    if self:DoesFrameExist(frameName) then
        self:RegisterWidget(frameName, displayName, category)
        return true
    end
    
    return false
end