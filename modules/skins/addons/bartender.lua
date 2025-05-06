-- VUI Skins Module - Bartender Addon Skinning
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local Skins = VUI.skins

-- Register the skin module
local BartenderSkin = Skins:RegisterAddonSkin("Bartender")

function BartenderSkin:OnEnable()
    -- Check if Bartender is loaded
    if not C_AddOns.IsAddOnLoaded("Bartender4") then return end
    
    -- Check if Bartender skinning is enabled in settings
    if not Skins.settings.skins.addons.bartender then return end
    
    -- List of Bartender UI elements to skin
    local bartenderElements = {
        BT4StatusBarTrackingManager.SingleBarLarge,
        BT4StatusBarTrackingManager.SingleBarSmall,
        BT4StatusBarTrackingManager.SingleBarLargeUpper,
        BT4StatusBarTrackingManager.SingleBarSmallUpper,
        BlizzardArtRightCap,
        BlizzardArtLeftCap,
        BlizzardArtTex0,
        BlizzardArtTex1,
        BlizzardArtTex2,
        BlizzardArtTex3,
    }
    
    -- Apply VUI color scheme to all elements
    for _, element in pairs(bartenderElements) do
        if element then 
            element:SetVertexColor(unpack(Skins:GetBackdropColor(0.15)))
        end
    end
    
    -- Additional Bartender skinning
    hooksecurefunc(Bartender4, "UpdateBlizzardBar", function()
        for i, v in pairs(bartenderElements) do
            if v then 
                v:SetVertexColor(unpack(Skins:GetBackdropColor(0.15)))
            end
        end
    end)
end