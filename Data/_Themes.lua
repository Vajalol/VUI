-- Ensure global VUI exists
if not _G.VUI then
    _G.VUI = {}
end

-- Create module data
local themeData = {
  { value = 'Blizzard', text = 'Blizzard' },
  { value = 'Dark', text = 'Dark' },
  { value = 'Class', text = 'Class' },
  { value = 'Custom', text = 'Custom' },
  { value = 'VUI', text = 'VUI' },
  { value = 'PhoenixFlame', text = 'Phoenix Flame' },
  { value = 'FelEnergy', text = 'Fel Energy' },
  { value = 'ArcaneMystic', text = 'Arcane Mystic' }
}

-- Try to use the resilient module creation pattern
local Themes
if type(VUI.TryCreateModule) == "function" then
    Themes = VUI:TryCreateModule('Data.Themes')
    Themes.data = themeData
elseif type(VUI.NewModule) == "function" then
    Themes = VUI:NewModule('Data.Themes')
    Themes.data = themeData
else
    -- Fallback if both module creation functions are unavailable
    VUI.Themes = VUI.Themes or {}
    VUI.Themes.data = themeData
    
    -- Setup retry once VUI is fully loaded
    C_Timer.After(1, function()
        if type(VUI.NewModule) == "function" then
            local realModule = VUI:NewModule('Data.Themes')
            realModule.data = themeData
            VUI.Themes = realModule
        end
    end)
end