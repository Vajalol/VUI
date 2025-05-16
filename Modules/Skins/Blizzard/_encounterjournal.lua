local Module = VUI:NewModule("Skins.EncounterJournal");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_EncounterJournal" then
                VUI:Skin(EncounterJournal, true)
                VUI:Skin(EncounterJournal.NineSlice, true)
                VUI:Skin(EncounterJournalInset, true)
                VUI:Skin(EncounterJournalInset.NineSlice, true)
                VUI:Skin(EncounterJournalNavBar, true)
                VUI:Skin(EncounterJournalNavBar.overlay, true)

                -- Tabs
                VUI:Skin(EncounterJournalMonthlyActivitiesTab, true)
                VUI:Skin(EncounterJournalSuggestTab, true)
                VUI:Skin(EncounterJournalDungeonTab, true)
                VUI:Skin(EncounterJournalRaidTab, true)
                VUI:Skin(EncounterJournalLootJournalTab, true)
                EncounterJournalInset:SetAlpha(0)
            end
        end)
    end
end
