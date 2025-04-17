-- VUI Skins Module - Minimap Skinning
local _, VUI = ...
local Skins = VUI.skins

-- Register the skin module
local MinimapSkin = Skins:RegisterSkin("Minimap")

function MinimapSkin:OnEnable()
    if not Skins.settings.skins.blizzard.minimap then return end
    
    -- Apply skin to minimap elements
    
    -- Skin the minimap border
    if MinimapCompassTexture then
        MinimapCompassTexture:SetAlpha(0)
    end
    
    -- Skin tracking button
    if MiniMapTracking then
        Skins:SkinFrame(MiniMapTracking)
    end
    
    -- Skin calendar button
    if GameTimeFrame then
        Skins:SkinFrame(GameTimeFrame)
    end
    
    -- Skin mail icon
    if MiniMapMailFrame then
        Skins:SkinFrame(MiniMapMailFrame)
    end
    
    -- Skin queue status button
    if QueueStatusMinimapButton then
        Skins:SkinFrame(QueueStatusMinimapButton)
    end
    
    -- Skin zone text
    if MinimapZoneText then
        MinimapZoneText:SetDrawLayer("OVERLAY")
        if Skins.settings.advancedUI.customFonts then
            Skins:SkinFontString(MinimapZoneText)
        end
    end
end