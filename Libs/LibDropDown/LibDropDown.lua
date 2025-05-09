-- LibDropDown placeholder
local MAJOR, MINOR = "LibDropDown", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

lib.dropdowns = {}

function lib:Create(parent, name)
    -- Placeholder functions that would normally create a dropdown menu
    local dropdown = CreateFrame("Frame", name, parent)
    return dropdown
end