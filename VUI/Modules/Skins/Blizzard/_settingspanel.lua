local Module = VUI:NewModule("Skins.Settingspanel");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            VUI:Skin(SettingsPanel, true)
            VUI:Skin(SettingsPanel.Bg, true)
            VUI:Skin(SettingsPanel.NineSlice, true)
        end)
    end
end
