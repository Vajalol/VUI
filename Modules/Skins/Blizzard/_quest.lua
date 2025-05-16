local Module = VUI:NewModule("Skins.Quest");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(QuestFrame, true)
        VUI:Skin(QuestFrame.NineSlice, true)
        VUI:Skin(QuestFrameInset, true)
        VUI:Skin(QuestFrameInset.NineSlice, true)
        VUI:Skin(QuestLogPopupDetailFrame, true)
        VUI:Skin(QuestLogPopupDetailFrame.NineSlice, true)
        VUI:Skin(ObjectiveTrackerFrame, true)
        VUI:Skin(ObjectiveTrackerFrame.Header, true)
        VUI:Skin(CampaignQuestObjectiveTracker, true)
        VUI:Skin(CampaignQuestObjectiveTracker.Header, true)
        VUI:Skin(QuestObjectiveTracker, true)
        VUI:Skin(QuestObjectiveTracker.Header, true)
        VUI:Skin(ProfessionsRecipeTracker, true)
        VUI:Skin(ProfessionsRecipeTracker.Header, true)
        VUI:Skin(ScenarioObjectiveTracker, true)
        VUI:Skin(ScenarioObjectiveTracker.Header, true)
        VUI:Skin({
            QuestNPCModelTopBorder,
            QuestNPCModelRightBorder,
            QuestNPCModelTopRightCorner,
            QuestNPCModelBottomRightCorner,
            QuestNPCModelBottomBorder,
            QuestNPCModelBottomLeftCorner,
            QuestNPCModelLeftBorder,
            QuestNPCModelTopLeftCorner,
            QuestNPCModelTextTopBorder,
            QuestNPCModelTextRightBorder,
            QuestNPCModelTextTopRightCorner,
            QuestNPCModelTextBottomRightCorner,
            QuestNPCModelTextBottomBorder,
            QuestNPCModelTextBottomLeftCorner,
            QuestNPCModelTextLeftBorder,
            QuestNPCModelTextTopLeftCorner
        }, true, true)
    end
end
