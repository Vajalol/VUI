local _, VUI = ...
local E = VUI:GetModule("VUICD")
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")
local AceGUI = LibStub("AceGUI-3.0")

-- Spell Editor for VUICD
local editor = {}
local editorFrame
local spellList = {}
local classFilterDropdown
local specFilterDropdown
local currentSpellID
local currentSpell
local dirty = false

function E:InitializeSpellEditor()
    -- Build the spell list from cooldown data
    function editor:BuildSpellList()
        wipe(spellList)
        
        -- Load spell data
        if not E.cooldownsInfo then
            return
        end
        
        for spellID, spellData in pairs(E.cooldownsInfo) do
            if type(spellData) == "table" and spellData.class then
                table.insert(spellList, {
                    spellID = spellID,
                    name = GetSpellInfo(spellID) or "Unknown Spell",
                    class = spellData.class,
                    spec = spellData.spec or 0,
                    cooldown = spellData.cooldown or 0,
                    charges = spellData.charges,
                    icon = GetSpellTexture(spellID)
                })
            end
        end
        
        -- Sort by class and name
        table.sort(spellList, function(a, b)
            if a.class == b.class then
                return a.name < b.name
            end
            return a.class < b.class
        end)
        
        return spellList
    end
    
    -- Update spell info
    function editor:UpdateSpellInfo(spellID, data)
        if not spellID or not data then return end
        
        -- Save changes to the database
        if not E.DB.global.cooldowns then
            E.DB.global.cooldowns = {}
        end
        
        -- Create or update the spell
        if not E.DB.global.cooldowns[spellID] then
            E.DB.global.cooldowns[spellID] = {}
        end
        
        -- Update fields
        for k, v in pairs(data) do
            E.DB.global.cooldowns[spellID][k] = v
        end
        
        -- Mark cooldown data as needing refresh
        E.cooldownsUpdated = true
        dirty = true
    end
    
    -- Reset spell info to default
    function editor:ResetSpellInfo(spellID)
        if not spellID then return end
        
        -- Remove custom settings
        if E.DB.global.cooldowns and E.DB.global.cooldowns[spellID] then
            E.DB.global.cooldowns[spellID] = nil
        end
        
        -- Mark cooldown data as needing refresh
        E.cooldownsUpdated = true
        dirty = true
    end
    
    -- Save changes and refresh
    function editor:SaveChanges()
        if dirty then
            -- Refresh cooldowns data
            E:RefreshCooldownsInfo()
            
            -- Update any UI elements using this data
            E:UpdateAllIcons()
            
            dirty = false
        end
    end
    
    -- Create editor UI components
    function E:CreateSpellEditor()
        if editorFrame then
            return editorFrame
        end
        
        -- Create main frame
        editorFrame = AceGUI:Create("Frame")
        editorFrame:SetTitle(L["VUI Cooldown Tracker"] .. " - " .. L["Spell Editor"])
        editorFrame:SetLayout("Flow")
        editorFrame:SetWidth(800)
        editorFrame:SetHeight(600)
        editorFrame:SetCallback("OnClose", function(widget)
            -- Ask to save if dirty
            if dirty then
                -- Use VUI dialog system if available
                if VUI.Dialogs and VUI.Dialogs.ShowConfirmDialog then
                    VUI.Dialogs:ShowConfirmDialog(
                        L["Save changes?"],
                        L["You have unsaved changes. Save before closing?"],
                        function() editor:SaveChanges() end
                    )
                else
                    -- Fallback to standard dialog
                    StaticPopupDialogs["VUICD_SAVE_DIALOG"] = {
                        text = L["You have unsaved changes. Save before closing?"],
                        button1 = YES,
                        button2 = NO,
                        OnAccept = function() editor:SaveChanges() end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3,
                    }
                    StaticPopup_Show("VUICD_SAVE_DIALOG")
                end
            end
            
            AceGUI:Release(widget)
            editorFrame = nil
        end)
        
        -- Create filter section
        local filterGroup = AceGUI:Create("SimpleGroup")
        filterGroup:SetLayout("Flow")
        filterGroup:SetFullWidth(true)
        filterGroup:SetHeight(50)
        editorFrame:AddChild(filterGroup)
        
        -- Class filter
        local classLabel = AceGUI:Create("Label")
        classLabel:SetText(L["Class Filter"] .. ":")
        classLabel:SetWidth(100)
        filterGroup:AddChild(classLabel)
        
        classFilterDropdown = AceGUI:Create("Dropdown")
        classFilterDropdown:SetWidth(150)
        
        -- Add class options
        local classOptions = {
            ["ALL"] = L["All Classes"],
            ["DEATHKNIGHT"] = L["Death Knight"],
            ["DEMONHUNTER"] = L["Demon Hunter"],
            ["DRUID"] = L["Druid"],
            ["EVOKER"] = L["Evoker"],
            ["HUNTER"] = L["Hunter"],
            ["MAGE"] = L["Mage"],
            ["MONK"] = L["Monk"],
            ["PALADIN"] = L["Paladin"],
            ["PRIEST"] = L["Priest"],
            ["ROGUE"] = L["Rogue"],
            ["SHAMAN"] = L["Shaman"],
            ["WARLOCK"] = L["Warlock"],
            ["WARRIOR"] = L["Warrior"],
        }
        classFilterDropdown:SetList(classOptions)
        classFilterDropdown:SetValue("ALL")
        filterGroup:AddChild(classFilterDropdown)
        
        -- Specialization filter
        local specLabel = AceGUI:Create("Label")
        specLabel:SetText(L["Spec Filter"] .. ":")
        specLabel:SetWidth(100)
        filterGroup:AddChild(specLabel)
        
        specFilterDropdown = AceGUI:Create("Dropdown")
        specFilterDropdown:SetWidth(150)
        
        -- Add spec options (will be populated based on class)
        local specOptions = {
            [0] = L["All Specializations"],
        }
        specFilterDropdown:SetList(specOptions)
        specFilterDropdown:SetValue(0)
        filterGroup:AddChild(specFilterDropdown)
        
        -- Refresh button
        local refreshButton = AceGUI:Create("Button")
        refreshButton:SetText(L["Refresh"])
        refreshButton:SetWidth(100)
        refreshButton:SetCallback("OnClick", function()
            editor:BuildSpellList()
            -- TODO: Update spell list display based on filters
        end)
        filterGroup:AddChild(refreshButton)
        
        -- Create splitter for spell list and editor
        local splitter = AceGUI:Create("SimpleGroup")
        splitter:SetLayout("Flow")
        splitter:SetFullWidth(true)
        splitter:SetHeight(500)
        editorFrame:AddChild(splitter)
        
        -- Spell list section
        local listFrame = AceGUI:Create("SimpleGroup")
        listFrame:SetLayout("Fill")
        listFrame:SetWidth(380)
        listFrame:SetHeight(480)
        splitter:AddChild(listFrame)
        
        -- Spell editor section
        local editorPane = AceGUI:Create("SimpleGroup")
        editorPane:SetLayout("Flow")
        editorPane:SetWidth(380)
        editorPane:SetHeight(480)
        splitter:AddChild(editorPane)
        
        -- Spell list scroll frame
        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetLayout("List")
        listFrame:AddChild(scroll)
        
        -- Bottom button panel
        local buttonPanel = AceGUI:Create("SimpleGroup")
        buttonPanel:SetLayout("Flow")
        buttonPanel:SetFullWidth(true)
        buttonPanel:SetHeight(40)
        editorFrame:AddChild(buttonPanel)
        
        -- Save button
        local saveButton = AceGUI:Create("Button")
        saveButton:SetText(L["Save Changes"])
        saveButton:SetWidth(150)
        saveButton:SetCallback("OnClick", function()
            editor:SaveChanges()
            VUI:Print(L["Cooldown settings saved."])
        end)
        buttonPanel:AddChild(saveButton)
        
        -- Cancel button
        local cancelButton = AceGUI:Create("Button")
        cancelButton:SetText(L["Cancel"])
        cancelButton:SetWidth(150)
        cancelButton:SetCallback("OnClick", function()
            editorFrame:Hide()
        end)
        buttonPanel:AddChild(cancelButton)
        
        -- Initialize the spell list
        editor:BuildSpellList()
        
        return editorFrame
    end
    
    -- Show the spell editor
    function E:ShowSpellEditor()
        local frame = E:CreateSpellEditor()
        frame:Show()
    end
end