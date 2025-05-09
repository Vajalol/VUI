local Module = VUI:NewModule("Skins.TradeSkill");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_TradeSkillUI" then
                VUI:Skin(TradeSkillFrame, true)
                VUI:Skin(TradeSkillFrame.NineSlice, true)
            end
        end)
    end
end
