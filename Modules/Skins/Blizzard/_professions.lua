local Module = VUI:NewModule("Skins.Professions");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_Professions" then
                VUI:Skin(ProfessionsFrame, true)
                VUI:Skin(ProfessionsFrame.NineSlice, true)
                VUI:Skin(ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice, true)
                VUI:Skin(ProfessionsFrame.CraftingPage.SchematicForm.NineSlice, true)
                VUI:Skin(ProfessionsFrame.CraftingPage.SchematicForm.Details, true)
                VUI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList.NineSlice, true)
                VUI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.BackgroundNineSlice, true)

                -- Tabs
                VUI:Skin(ProfessionsFrame.TabSystem.tabs[1], true)
                VUI:Skin(ProfessionsFrame.TabSystem.tabs[2], true)
                VUI:Skin(ProfessionsFrame.TabSystem.tabs[3], true)
                VUI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton, true)
                VUI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.GuildOrdersButton, true)
                VUI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.NpcOrdersButton, true)
                VUI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton, true)
            end
        end)
    end
end
