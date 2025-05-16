-- Ensure global VUI exists
if not _G.VUI then
    _G.VUI = {}
end

-- Define the colors data
local colorData = {
    -- User roles & classes
    aut    = '|cfff72a53',
    mod    = '|cff2a91f7',
    dev    = '|cff2af7af',
    sup    = '|cffe08000',
    dk     = '|cffC41E3A',
    druid  = '|cffFF7C0A',
    pala   = '|cffF48CBA',
    monk   = '|cff00FF98',
    hunter = '|cffAAD372',
    sham   = '|cff0070DD',
    priest = '|cffFFFFFF',
    lock   = '|cff8788EE',
    warri  = '|cffC69B6D',
    rog    = '|cffFFF468',
    mage   = '|cff3FC7EB',
    dh     = '|cffA330C9',
    evoker = '|cff33937F',

    -- VUI theme colors
    vui_primary = '|cff0D9DE6', -- Medium blue from logo gradient
    vui_accent = '|cff3EBEFF',  -- Light blue from logo gradient
    vui_dark = '|cff0A6B9F',    -- Darker shade for contrast

    -- Phoenix Flame theme colors
    phoenix_primary = '|cffE64D0D', -- Orange/red from logo gradient
    phoenix_accent = '|cffFFA31A',  -- Light orange from logo gradient
    phoenix_dark = '|cffB23A0A',    -- Darker shade for contrast

    -- Fel Energy theme colors
    fel_primary = '|cff1AFF1A', -- Bright green from logo gradient
    fel_accent = '|cff00AA00',  -- Darker green from logo gradient
    fel_dark = '|cff008800',    -- Darker shade for contrast

    -- Arcane Mystic theme colors
    arcane_primary = '|cff9D0DE6', -- Purple from logo gradient
    arcane_accent = '|cffD459FF',  -- Light purple from logo gradient
    arcane_dark = '|cff6A099F'    -- Darker shade for contrast
}

-- Try to use the resilient module creation pattern
local Colors
if type(VUI.TryCreateModule) == "function" then
    Colors = VUI:TryCreateModule('Data.Colors')
    -- Copy all color values to the module
    for k, v in pairs(colorData) do
        Colors[k] = v
    end
elseif type(VUI.NewModule) == "function" then
    Colors = VUI:NewModule('Data.Colors')
    -- Copy all color values to the module
    for k, v in pairs(colorData) do
        Colors[k] = v
    end
else
    -- Fallback if both module creation functions are unavailable
    VUI.Colors = VUI.Colors or {}
    -- Copy all color values directly to VUI.Colors
    for k, v in pairs(colorData) do
        VUI.Colors[k] = v
    end
    
    -- Setup retry once VUI is fully loaded
    C_Timer.After(1, function()
        if type(VUI.NewModule) == "function" then
            local realModule = VUI:NewModule('Data.Colors')
            -- Copy all color values to the module
            for k, v in pairs(colorData) do
                realModule[k] = v
            end
            VUI.Colors = realModule
        end
    end)
end
