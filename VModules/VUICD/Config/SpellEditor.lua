local _, VUI = ...
<<<<<<< HEAD

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Setup localization with fallbacks
local L = {}
local success = pcall(function() L = LibStub("AceLocale-3.0"):GetLocale("VUI") end)
if not success then
    -- Add fallbacks for localization
    L["VUI Cooldown Tracker"] = "VUI Cooldown Tracker"
    L["Spell Editor"] = "Spell Editor"
    L["Save changes?"] = "Save changes?"
    L["You have unsaved changes. Save before closing?"] = "You have unsaved changes. Save before closing?"
    L["All Classes"] = "All Classes"
    L["Death Knight"] = "Death Knight"
    L["Demon Hunter"] = "Demon Hunter"
    L["Druid"] = "Druid"
    L["Evoker"] = "Evoker"
    L["Hunter"] = "Hunter"
    L["Mage"] = "Mage"
    L["Monk"] = "Monk"
    L["Paladin"] = "Paladin"
    L["Priest"] = "Priest"
    L["Rogue"] = "Rogue"
    L["Shaman"] = "Shaman"
    L["Warlock"] = "Warlock"
    L["Warrior"] = "Warrior"
    L["Class Filter"] = "Class Filter"
    L["Spec Filter"] = "Spec Filter"
    L["All Specializations"] = "All Specializations"
    L["Refresh"] = "Refresh"
    L["Save Changes"] = "Save Changes"
    L["Cancel"] = "Cancel"
    L["Cooldown settings saved."] = "Cooldown settings saved."
end

-- Store localization for global use
VUICD.L = VUICD.L or L

-- Local references
local E = VUICD

-- Try to get AceGUI with fallback
local AceGUI = {}
try = pcall(function() AceGUI = LibStub("AceGUI-3.0") end)
if not try then
    AceGUI.Create = function() return {} end
    print("VUICD Error: AceGUI-3.0 not found")
end
=======
local E = VUI.VUICD or VUI:GetModule("VUICD")
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")
local AceGUI = LibStub("AceGUI-3.0")
>>>>>>> f2841d4c299e00869d4563d9e99c5e582069affc

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
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() editorFrame:SetTitle(L["VUI Cooldown Tracker"] .. " - " .. L["Spell Editor"]) end)
        pcall(function() editorFrame:SetLayout("Flow") end)
        pcall(function() editorFrame:SetWidth(800) end)
        pcall(function() editorFrame:SetHeight(600) end)
        editorFrame:SetCallback("OnClose", function(widget)
            -- Ask to save if dirty
            if dirty then
                -- Use VUI dialog system if available
                local dialogs = _G.VUI and _G.VUI.Dialogs
                if dialogs and dialogs.ShowConfirmDialog then
                    -- Call with pcall to prevent errors if arguments don't match
                    pcall(function()
                        dialogs:ShowConfirmDialog(
                            L["Save changes?"],
                            L["You have unsaved changes. Save before closing?"],
                            function() editor:SaveChanges() end
                        )
                    end)
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
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() filterGroup:SetLayout("Flow") end)
        pcall(function() filterGroup:SetFullWidth(true) end)
        filterGroup:SetHeight(50)
        editorFrame:AddChild(filterGroup)
        
        -- Class filter
        local classLabel = AceGUI:Create("Label")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() classLabel:SetText(L["Class Filter"] .. ":") end)
        pcall(function() classLabel:SetWidth(100) end)
        pcall(function() filterGroup:AddChild(classLabel) end)
        
        classFilterDropdown = AceGUI:Create("Dropdown")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() classFilterDropdown:SetWidth(150) end)
        
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
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() classFilterDropdown:SetList(classOptions) end)
        pcall(function() classFilterDropdown:SetValue("ALL") end)
        pcall(function() filterGroup:AddChild(classFilterDropdown) end)
        
        -- Specialization filter
        local specLabel = AceGUI:Create("Label")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() specLabel:SetText(L["Spec Filter"] .. ":") end)
        pcall(function() specLabel:SetWidth(100) end)
        pcall(function() filterGroup:AddChild(specLabel) end)
        
        specFilterDropdown = AceGUI:Create("Dropdown")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() specFilterDropdown:SetWidth(150) end)
        
        -- Add spec options (will be populated based on class)
        local specOptions = {
            [0] = L["All Specializations"],
        }
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() specFilterDropdown:SetList(specOptions) end)
        pcall(function() specFilterDropdown:SetValue(0) end)
        pcall(function() filterGroup:AddChild(specFilterDropdown) end)
        
        -- Refresh button
        local refreshButton = AceGUI:Create("Button")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() refreshButton:SetText(L["Refresh"]) end)
        pcall(function() refreshButton:SetWidth(100) end)
        refreshButton:SetCallback("OnClick", function()
            editor:BuildSpellList()
            -- TODO: Update spell list display based on filters
        end)
        filterGroup:AddChild(refreshButton)
        
        -- Create splitter for spell list and editor
        local splitter = AceGUI:Create("SimpleGroup")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() splitter:SetLayout("Flow") end)
        pcall(function() splitter:SetFullWidth(true) end)
        pcall(function() splitter:SetHeight(500) end)
        pcall(function() editorFrame:AddChild(splitter) end)
        
        -- Spell list section
        local listFrame = AceGUI:Create("SimpleGroup")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() listFrame:SetLayout("Fill") end)
        pcall(function() listFrame:SetWidth(380) end)
        pcall(function() listFrame:SetHeight(480) end)
        pcall(function() splitter:AddChild(listFrame) end)
        
        -- Spell editor section
        local editorPane = AceGUI:Create("SimpleGroup")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() editorPane:SetLayout("Flow") end)
        pcall(function() editorPane:SetWidth(380) end)
        pcall(function() editorPane:SetHeight(480) end)
        pcall(function() splitter:AddChild(editorPane) end)
        
        -- Spell list scroll frame
        local scroll = AceGUI:Create("ScrollFrame")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() scroll:SetLayout("List") end)
        pcall(function() listFrame:AddChild(scroll) end)
        
        -- Bottom button panel
        local buttonPanel = AceGUI:Create("SimpleGroup")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() buttonPanel:SetLayout("Flow") end)
        pcall(function() buttonPanel:SetFullWidth(true) end)
        pcall(function() buttonPanel:SetHeight(40) end)
        pcall(function() editorFrame:AddChild(buttonPanel) end)
        
        -- Save button
        local saveButton = AceGUI:Create("Button")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() saveButton:SetText(L["Save Changes"]) end)
        pcall(function() saveButton:SetWidth(150) end)
        saveButton:SetCallback("OnClick", function()
            editor:SaveChanges()
            -- Print message with fallback
            if _G.VUI and _G.VUI.Print then
                pcall(function() _G.VUI:Print(L["Cooldown settings saved."]) end)
            else
                print(L["Cooldown settings saved."])
            end
        end)
        pcall(function() buttonPanel:AddChild(saveButton) end)
        
        -- Cancel button
        local cancelButton = AceGUI:Create("Button")
        -- Wrap method calls in pcall to prevent argument mismatch errors
        pcall(function() cancelButton:SetText(L["Cancel"]) end)
        pcall(function() cancelButton:SetWidth(150) end)
        cancelButton:SetCallback("OnClick", function()
            editorFrame:Hide()
        end)
        pcall(function() buttonPanel:AddChild(cancelButton) end)
        
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