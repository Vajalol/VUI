-- Ensure global VUI exists
if not _G.VUI then
    _G.VUI = {}
end

-- Get LibSharedMedia
local LSM = LibStub("LibSharedMedia-3.0")
local LSM_StatusBarFontsList = LSM:List('font')
local LSM_StatusBarFontsHash = LSM:HashTable('font')

-- Convert to fonts list - handle missing LSB_Helper
local fontsData 
if type(VUI.LSB_Helper) == "function" then
    fontsData = VUI:LSB_Helper(LSM_StatusBarFontsList, LSM_StatusBarFontsHash)
else
    -- Manual conversion if helper isn't available
    fontsData = {}
    for index, name in pairs(LSM_StatusBarFontsList) do
        fontsData[index] = {}
        for k, v in pairs(LSM_StatusBarFontsHash) do
            if (name == k) then
                fontsData[index] = {
                    text = name,
                    value = v
                }
            end
        end
    end
end

-- Try to use the resilient module creation pattern
local Fonts
if type(VUI.TryCreateModule) == "function" then
    Fonts = VUI:TryCreateModule('Data.Fonts')
    Fonts.data = fontsData
elseif type(VUI.NewModule) == "function" then
    Fonts = VUI:NewModule('Data.Fonts')
    Fonts.data = fontsData
else
    -- Fallback if both module creation functions are unavailable
    VUI.Fonts = VUI.Fonts or {}
    VUI.Fonts.data = fontsData
    
    -- Setup retry once VUI is fully loaded
    C_Timer.After(1, function()
        if type(VUI.NewModule) == "function" then
            local realModule = VUI:NewModule('Data.Fonts')
            realModule.data = fontsData
            VUI.Fonts = realModule
        end
    end)
end