-- VUI Skins Module - ClassicUI Addon Skinning
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local Skins = VUI.skins

-- Register the skin module
local ClassicUISkin = Skins:RegisterAddonSkin("ClassicUI")

function ClassicUISkin:OnEnable()
    -- Check if ClassicUI is loaded
    if not C_AddOns.IsAddOnLoaded("ClassicUI") then return end
    
    -- Check if ClassicUI skinning is enabled in settings
    if not Skins.settings.skins.addons.classicui then return end
    
    -- Apply VUI skin to ClassicUI elements
    if ClassicUI then
        -- Apply skin to action bars
        if ClassicUI.ab and ClassicUI.ab.actionbars then
            for i = 1, 6 do
                local bar = ClassicUI.ab.actionbars[i]
                if bar then
                    Skins:Skin(bar, true)
                    
                    -- Style individual buttons in the bar
                    for j = 1, 12 do
                        local button = bar.buttons[j]
                        if button then
                            Skins:Skin(button, true)
                        end
                    end
                end
            end
        end
        
        -- Apply skin to ClassicUI frames
        if ClassicUI.frames then
            for frameName, frame in pairs(ClassicUI.frames) do
                if frame and type(frame) == "table" and frame.IsObjectType and frame:IsObjectType("Frame") then
                    Skins:Skin(frame, true)
                end
            end
        end
    end
end