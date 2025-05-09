local Module = VUI:NewModule("Skins.Macro");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_MacroUI" then
                VUI:Skin(MacroFrame, true)
                VUI:Skin(MacroFrame.NineSlice, true)
                VUI:Skin(MacroFrameInset, true)
                VUI:Skin(MacroFrameInset.NineSlice, true)
                VUI:Skin(MacroFrameTextBackground, true)
                VUI:Skin(MacroFrameTextBackground.NineSlice, true)
                VUI:Skin({
                    MacroButtonScrollFrameTop,
                    MacroButtonScrollFrameMiddle,
                    MacroButtonScrollFrameBottom,
                    MacroButtonScrollFrameScrollBarThumbTexture
                }, true, true)

                -- Tabs
                VUI:Skin(MacroFrameTab1, true)
                VUI:Skin(MacroFrameTab2, true)
            end
        end)
    end
end
