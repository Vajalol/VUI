local Module = VUI:NewModule("Skins.Challenges");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_ChallengesUI" then
                VUI:Skin(ChallengesFrameInset.NineSlice, true)
            end
        end)
    end
end
