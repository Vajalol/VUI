local Skin = VUI:NewModule("Skins.ClassicUI");

function Skin:OnEnable()
    local ClassicUI = C_AddOns.IsAddOnLoaded("ClassicUI")
    if not (ClassicUI) then return end
    if (VUI:Color()) then
        for i, v in pairs({
            MainMenuBarArtFrameBackground.BackgroundLarge2,
            MainMenuBarArtFrameBackground.BagsArt,
            MainMenuBarArtFrameBackground.MicroButtonArt,
        }) do
            v:SetVertexColor(unpack(VUI:Color(0.15)))
        end
    end
end
