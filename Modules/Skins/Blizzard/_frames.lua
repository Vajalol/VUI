local Module = VUI:NewModule("Skins.Frames");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(GameMenuFrame, true)
        VUI:Skin(GameMenuFrame.Header, true)
        VUI:Skin(GameMenuFrame.Border, true)
        VUI:Skin(StaticPopup1, true)
        VUI:Skin(StaticPopup1.Border, true)
        VUI:Skin(StaticPopup2, true)
        VUI:Skin(StaticPopup2.Border, true)
        VUI:Skin(StaticPopup3, true)
        VUI:Skin(StaticPopup3.Border, true)
        VUI:Skin(EditModeManagerFrame, true)
        VUI:Skin(EditModeManagerFrame.Border, true)
        VUI:Skin(VehicleSeatIndicator, true)
        VUI:Skin(ReportFrame, true)
        VUI:Skin(ReportFrame.Border, true)
        VUI:Skin(ReadyStatus.Border, true)
        VUI:Skin(LFGDungeonReadyStatus.Border, true)
        VUI:Skin(LFGDungeonReadyDialog, true)
        VUI:Skin(LFGDungeonReadyDialog.Border, true)
        VUI:Skin(PVPMatchScoreboard.Content, true)
        VUI:Skin(QueueStatusFrame, true)
        VUI:Skin(QueueStatusFrame.NineSlice, true)
        VUI:Skin(LFGListInviteDialog, true)
        VUI:Skin(LFGListInviteDialog.Border, true)

        PVPMatchScoreboard:HookScript("OnShow", function()
            VUI:Skin(PVPMatchScoreboard, true)
        end)

        -- Tabs
        VUI:Skin(PVPScoreboardTab1, true)
        VUI:Skin(PVPScoreboardTab2, true)
        VUI:Skin(PVPScoreboardTab3, true)
    end
end
