-- Ensure VUI is available or create a minimal version
if not _G.VUI then
    _G.VUI = {}
end

-- Use the resilient module creation pattern
local Partyprofile = VUI:TryCreateModule('Data.Partyprofile')

Partyprofile.data = {
    { value = 'profile1', text = 'Profile 1' },
    { value = 'profile2', text = 'Profile 2' },
}