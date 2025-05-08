local Module = VUI:NewModule("Skins.TimeManager");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_TimeManager" then
                VUI:Skin(TimeManagerFrame, true)
                VUI:Skin(TimeManagerFrame.NineSlice, true)
                VUI:Skin(TimeManagerFrameInset, true)
                VUI:Skin(TimeManagerFrameInset.NineSlice, true)
                VUI:Skin({ StopwatchFrameBackgroundLeft }, true, true)
            end
        end)
    end
end
