-- Ensure global VUI exists
if not _G.VUI then
    _G.VUI = {}
end

-- Get LibSharedMedia
local LSM = LibStub("LibSharedMedia-3.0")
local LSM_StatusBarTexturesList = LSM:List('statusbar')
local LSM_StatusBarTexturesHash = LSM:HashTable('statusbar')

-- Convert to textures list - handle missing LSB_Helper
local texturesData
if type(VUI.LSB_Helper) == "function" then
    texturesData = VUI:LSB_Helper(LSM_StatusBarTexturesList, LSM_StatusBarTexturesHash)
else
    -- Manual conversion if helper isn't available
    texturesData = {}
    for index, name in pairs(LSM_StatusBarTexturesList) do
        texturesData[index] = {}
        for k, v in pairs(LSM_StatusBarTexturesHash) do
            if (name == k) then
                texturesData[index] = {
                    text = name,
                    value = v
                }
            end
        end
    end
end

-- Try to use the resilient module creation pattern
local Textures
if type(VUI.TryCreateModule) == "function" then
    Textures = VUI:TryCreateModule('Data.Textures')
    Textures.data = texturesData
elseif type(VUI.NewModule) == "function" then
    Textures = VUI:NewModule('Data.Textures')
    Textures.data = texturesData
else
    -- Fallback if both module creation functions are unavailable
    VUI.Textures = VUI.Textures or {}
    VUI.Textures.data = texturesData
    
    -- Setup retry once VUI is fully loaded
    C_Timer.After(1, function()
        if type(VUI.NewModule) == "function" then
            local realModule = VUI:NewModule('Data.Textures')
            realModule.data = texturesData
            VUI.Textures = realModule
        end
    end)
end
