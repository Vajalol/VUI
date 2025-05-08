local Module = VUI:NewModule("Skins.LFG");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(PVEFrame, true)
        VUI:Skin(PVEFrame.shadows, true)
        VUI:Skin(PVEFrame.NineSlice, true)
        VUI:Skin(LFGListFrame.SearchPanel.ResultsInset, true)
        VUI:Skin(LFGListFrame.SearchPanel.ResultsInset.NineSlice, true)
        VUI:Skin(PVEFrameLeftInset, true)
        VUI:Skin(PVEFrameLeftInset.NineSlice, true)
        VUI:Skin(LFDParentFrameInset, true)
        VUI:Skin(LFDParentFrameInset.NineSlice, true)
        VUI:Skin(RaidFinderFrameRoleInset, true)
        VUI:Skin(RaidFinderFrameRoleInset.NineSlice, true)
        VUI:Skin(RaidFinderFrameBottomInset, true)
        VUI:Skin(RaidFinderFrameBottomInset.NineSlice, true)
        VUI:Skin(LFGListFrame, true)
        VUI:Skin(LFGListFrame.CategorySelection, true)
        VUI:Skin(LFGListFrame.CategorySelection.Inset, true)
        VUI:Skin(LFGListFrame.CategorySelection.Inset.NineSlice, true)
        VUI:Skin(LFGListFrame.ApplicationViewer, true)
        VUI:Skin(LFGListFrame.ApplicationViewer.Inset, true)
        VUI:Skin(LFGListFrame.ApplicationViewer.Inset.NineSlice, true)
        VUI:Skin(LFGListFrame.EntryCreation, true)
        VUI:Skin(LFGListFrame.EntryCreation.Inset, true)
        VUI:Skin(LFGListFrame.EntryCreation.Inset.NineSlice, true)
        VUI:Skin(LFGListFrame.ApplicationViewer.NameColumnHeader, true)
        VUI:Skin(LFGListFrame.ApplicationViewer.RoleColumnHeader, true)
        VUI:Skin(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader, true)
        VUI:Skin(LFGApplicationViewerRatingColumnHeader, true)
        VUI:Skin(LFDRoleCheckPopup, true)
        VUI:Skin(LFDRoleCheckPopup.Border, true)
        VUI:Skin(PVPReadyDialog, true)
        VUI:Skin(PVPReadyDialog.Border, true)

        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_PVPUI" then
                VUI:Skin(PlunderstormFrame.Inset, true)
                VUI:Skin(PlunderstormFrame.Inset.NineSlice, true)
            end
        end)

        VUI:Skin({
            LFDQueueFrameBackground,
            LFDParentFrameRoleBackground,
            PVEFrameTopFiligree,
            PVEFrameBottomFiligree,
            PVEFrameBlueBg,
        }, true, true)

        -- Tabs
        VUI:Skin(PVEFrameTab1, true)
        VUI:Skin(PVEFrameTab2, true)
        VUI:Skin(PVEFrameTab3, true)
        VUI:Skin(PVEFrameTab4, true)
    end
end
