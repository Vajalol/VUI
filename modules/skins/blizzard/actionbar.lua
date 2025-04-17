-- VUI Skins Module - ActionBar Skinning
local _, VUI = ...
local Skins = VUI.skins

-- Register the skin module
local ActionBarSkin = Skins:RegisterSkin("ActionBar")

function ActionBarSkin:OnEnable()
    if not Skins.settings.skins.blizzard.actionbar then return end
    
    -- Skin main menu bar
    Skins:Skin(MainMenuBar, true)
    Skins:Skin(MainMenuBar.EndCaps, true)
    Skins:Skin(MainMenuBar.ActionBarPageNumber.UpButton, true)
    Skins:Skin(MainMenuBar.ActionBarPageNumber.DownButton, true)
    
    -- Apply color to text elements
    if MainMenuBar.ActionBarPageNumber.Text then
        MainMenuBar.ActionBarPageNumber.Text:SetVertexColor(unpack(Skins:GetTextColor(0.15)))
    end
    
    -- Skin status tracking bars
    Skins:Skin(StatusTrackingBarManager, true)
    Skins:Skin(StatusTrackingBarManager.BottomBarFrameTexture, true)
    Skins:Skin(StatusTrackingBarManager.MainStatusTrackingBarContainer, true)
    Skins:Skin(StatusTrackingBarManager.SecondaryStatusTrackingBarContainer, true)
end