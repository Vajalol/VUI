local Module = VUI:NewModule("Skins.Talents");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_PlayerSpells" then
                VUI:Skin(PlayerSpellsFrame, true)
                VUI:Skin(PlayerSpellsFrame.TalentsFrame, true)
                VUI:Skin(PlayerSpellsFrame.TalentsFrame.SearchPreviewContainer, true)
                VUI:Skin(PlayerSpellsFrame.TalentsFrame.SearchPreviewContainer.DefaultResultButton, true)
                VUI:Skin(PlayerSpellsFrame.TalentsFrame.SearchBox, true)
                VUI:Skin(PlayerSpellsFrame.TalentsFrame.LoadSystem, true)
                VUI:Skin(PlayerSpellsFrame.TalentsFrame.LoadSystem.Dropdown, true)
                VUI:Skin(HeroTalentsSelectionDialog, true)
                VUI:Skin(HeroTalentsSelectionDialog.NineSlice, true)
                VUI:Skin({
                    ClassTalentFrameTitleBg,
                    ClassTalentFrameBg,
                    ClassTalentFrameTalentsPvpTalentFrameTalentListBg
                }, true, true)

                -- Tabs
                VUI:Skin(PlayerSpellsFrame.TalentsFrame.ApplyButton, true)
                VUI:Skin(PlayerSpellsFrame.TabSystem.tabs[1], true)
                VUI:Skin(PlayerSpellsFrame.TabSystem.tabs[2], true)
                VUI:Skin(PlayerSpellsFrame.TabSystem.tabs[3], true)

                -- Reset Background
                select(4, PlayerSpellsFrame.TalentsFrame:GetRegions()):SetVertexColor(1, 1, 1, 0.7)
                select(4, PlayerSpellsFrame.TalentsFrame:GetRegions()):SetDesaturated(false)
            end
        end)
    end
end
