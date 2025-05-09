-- LibDBIcon-1.0 minimal implementation
local MAJOR, MINOR = "LibDBIcon-1.0", 46 -- Bump minor on changes
local LibDBIcon = LibStub:NewLibrary(MAJOR, MINOR)

if not LibDBIcon then return end -- No upgrade needed

-- Lua APIs
local next, pairs = next, pairs
local UIParent = UIParent

-- WoW APIs
local CreateFrame = CreateFrame
local C_Timer = C_Timer

LibDBIcon.objects = LibDBIcon.objects or {}
LibDBIcon.callback = LibDBIcon.callback or LibStub:GetLibrary("CallbackHandler-1.0"):New(LibDBIcon)
LibDBIcon.tooltip = LibDBIcon.tooltip or GameTooltip
LibDBIcon.notCreated = LibDBIcon.notCreated or {}

-- Basic functions required for minimal operation
function LibDBIcon:Register(name, object, db)
    if not object.icon then error("Can't register LDB objects without icons set!") end
    
    self.objects[name] = {
        name = name,
        object = object,
        db = db,
    }
    
    return self.objects[name]
end

function LibDBIcon:Hide(name)
    if not self.objects[name] then return end
    local button = self.objects[name].button
    if button then
        button:Hide()
    end
end

function LibDBIcon:Show(name)
    if not self.objects[name] then return end
    local button = self.objects[name].button
    if button then
        button:Show()
    end
end

function LibDBIcon:IsRegistered(name)
    return self.objects[name] ~= nil
end

-- Used by other functions, creating minimal placeholder
function LibDBIcon:UpdatePosition()
    -- Minimal placeholder that does nothing
end

-- Dataminer
function LibDBIcon:GetButtonList()
    local t = {}
    for name in pairs(self.objects) do
        t[#t + 1] = name
    end
    return t
end