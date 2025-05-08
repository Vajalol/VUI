local Module = VUI:NewModule("Skins.Minimap");

function Module:OnEnable()
    if (VUI:Color()) then
        local compass = MinimapCompassTexture
        compass:SetDesaturated(true)
        compass:SetVertexColor(unpack(VUI:Color(0.15)))
    end
end
