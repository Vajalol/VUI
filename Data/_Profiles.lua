-- Ensure VUI is available or create a minimal version
if not _G.VUI then
    _G.VUI = {}
end

-- Use the resilient module creation pattern
local Profiles = VUI:TryCreateModule('Data.Profiles')

Profiles.data = {
    { value = 'Default', text = 'Default' },
}