local Module = VUI:NewModule("Skins.Achievment");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_AchievementUI" then
                VUI:Skin(AchievementFrame, true)
                VUI:Skin(AchievementFrame.Header, true)
                VUI:Skin(AchievementFrame.Searchbox, true)
                VUI:Skin(AchievementFrameSummary, true)
                VUI:Skin(AchievementFrameTab1, true)
                VUI:Skin(AchievementFrameTab2, true)
                VUI:Skin(AchievementFrameTab3, true)
                AchievementFrame.Header.PointBorder:SetAlpha(0)
                select(8, AchievementFrame.Header:GetRegions()):SetVertexColor(1, 1, 1)
            end
        end)
    end
end
