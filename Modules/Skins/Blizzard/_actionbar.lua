local Module = VUI:NewModule("Skins.ActionBar");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(MainMenuBar, true)
        VUI:Skin(MainMenuBar.EndCaps, true)
        VUI:Skin(MainMenuBar.ActionBarPageNumber.UpButton, true)
        VUI:Skin(MainMenuBar.ActionBarPageNumber.DownButton, true)
        MainMenuBar.ActionBarPageNumber.Text:SetVertexColor(unpack(VUI:Color(0.15)))
        VUI:Skin(StatusTrackingBarManager, true)
        VUI:Skin(StatusTrackingBarManager.BottomBarFrameTexture, true)
        VUI:Skin(StatusTrackingBarManager.MainStatusTrackingBarContainer, true)
        VUI:Skin(StatusTrackingBarManager.SecondaryStatusTrackingBarContainer, true)
    end
end
