local addonName, VUI = ...
local module = VUI:GetModule("SpellNotifications")
local AceGUI = LibStub("AceGUI-3.0")

-- Types for the dropdown
local spellTypes = {
    ["interrupt"] = "Interrupt",
    ["dispel"] = "Dispel",
    ["important"] = "Important"
}

-- Priority levels for the dropdown
local priorityLevels = {
    [1] = "Low",
    [2] = "Medium",
    [3] = "High"
}

-- Function to create the spell management window
function module:CreateSpellManagementUI()
    if self.spellFrame then
        self.spellFrame:Show()
        return
    end
    
    -- Create main frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI Spell Notifications Manager")
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(500)
    frame:EnableResize(false)
    
    -- Set callback for when the frame is closed
    frame:SetCallback("OnClose", function(widget)
        self.spellFrame = nil
    end)
    
    -- Create tab group
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "Add Spell", value = "add"},
        {text = "Manage Spells", value = "manage"},
        {text = "Import/Export", value = "import"}
    })
    tabs:SetFullWidth(true)
    tabs:SetFullHeight(true)
    
    -- Function to create the Add Spell tab
    local function CreateAddSpellTab(container)
        -- Header
        local header = AceGUI:Create("Heading")
        header:SetText("Add New Spell to Notification List")
        header:SetFullWidth(true)
        container:AddChild(header)
        
        -- Description text
        local desc = AceGUI:Create("Label")
        desc:SetText("Enter a spell ID or name to add it to your custom notification list. You can find spell IDs by using websites like Wowhead or by enabling spell IDs in-game using an addon like idTip.")
        desc:SetFullWidth(true)
        container:AddChild(desc)
        
        -- Spell ID input
        local spellIDInput = AceGUI:Create("EditBox")
        spellIDInput:SetLabel("Spell ID or Name:")
        spellIDInput:SetWidth(250)
        container:AddChild(spellIDInput)
        
        -- Spell lookup button
        local lookupButton = AceGUI:Create("Button")
        lookupButton:SetText("Look Up Spell")
        lookupButton:SetWidth(150)
        lookupButton:SetCallback("OnClick", function()
            local input = spellIDInput:GetText()
            if not input or input == "" then
                print("|cFFFF0000Please enter a spell ID or name.|r")
                return
            end
            
            -- Check if input is a number (spell ID)
            local spellID = tonumber(input)
            if not spellID then
                -- Input is a name, try to find matching spells
                local matches = {}
                for id, data in pairs(module:GetAllImportantSpells()) do
                    if string.find(string.lower(data.name), string.lower(input)) then
                        table.insert(matches, {id = id, name = data.name})
                    end
                end
                
                if #matches == 0 then
                    print("|cFFFF0000No spells found matching that name.|r")
                else
                    print("|cFF00FF00Found " .. #matches .. " spells matching '" .. input .. "':|r")
                    for _, match in ipairs(matches) do
                        print(" - " .. match.name .. " (ID: " .. match.id .. ")")
                    end
                end
                return
            end
            
            -- Try to get spell info
            local name, _, icon = GetSpellInfo(spellID)
            if not name then
                print("|cFFFF0000Invalid spell ID.|r")
                return
            end
            
            -- Update the UI with spell info
            spellName:SetText("Spell Name: " .. name)
            if icon then
                spellIcon:SetImage(icon)
                spellIcon:SetImageSize(32, 32)
            end
            
            -- Show the spell info group
            spellInfoGroup:SetVisible(true)
            container:DoLayout()
        end)
        container:AddChild(lookupButton)
        
        -- Spell info group (hidden initially)
        local spellInfoGroup = AceGUI:Create("InlineGroup")
        spellInfoGroup:SetTitle("Spell Information")
        spellInfoGroup:SetLayout("Flow")
        spellInfoGroup:SetFullWidth(true)
        spellInfoGroup:SetVisible(false)
        container:AddChild(spellInfoGroup)
        
        -- Spell name display
        local spellName = AceGUI:Create("Label")
        spellName:SetText("Spell Name: ")
        spellName:SetWidth(300)
        spellInfoGroup:AddChild(spellName)
        
        -- Spell icon display
        local spellIcon = AceGUI:Create("Icon")
        spellIcon:SetImageSize(32, 32)
        spellIcon:SetWidth(50)
        spellInfoGroup:AddChild(spellIcon)
        
        -- Spell type dropdown
        local spellTypeDropdown = AceGUI:Create("Dropdown")
        spellTypeDropdown:SetLabel("Notification Type:")
        spellTypeDropdown:SetList(spellTypes)
        spellTypeDropdown:SetValue("important") -- Default to important
        spellTypeDropdown:SetWidth(200)
        spellInfoGroup:AddChild(spellTypeDropdown)
        
        -- Priority dropdown
        local priorityDropdown = AceGUI:Create("Dropdown")
        priorityDropdown:SetLabel("Priority:")
        priorityDropdown:SetList(priorityLevels)
        priorityDropdown:SetValue(2) -- Default to medium
        priorityDropdown:SetWidth(200)
        spellInfoGroup:AddChild(priorityDropdown)
        
        -- Add button
        local addButton = AceGUI:Create("Button")
        addButton:SetText("Add to Notification List")
        addButton:SetWidth(200)
        addButton:SetCallback("OnClick", function()
            local input = spellIDInput:GetText()
            if not input or input == "" then
                print("|cFFFF0000Please enter a spell ID.|r")
                return
            end
            
            local spellID = tonumber(input)
            if not spellID then
                print("|cFFFF0000Please enter a valid spell ID (numeric).|r")
                return
            end
            
            local spellType = spellTypeDropdown:GetValue()
            local priority = priorityDropdown:GetValue()
            
            local success = module:AddCustomSpell(spellID, spellType, priority)
            if success then
                -- Clear the form
                spellIDInput:SetText("")
                spellName:SetText("Spell Name: ")
                spellIcon:SetImage(nil)
                spellInfoGroup:SetVisible(false)
                container:DoLayout()
            end
        end)
        spellInfoGroup:AddChild(addButton)
        
        -- Test button
        local testButton = AceGUI:Create("Button")
        testButton:SetText("Test Notification")
        testButton:SetWidth(200)
        testButton:SetCallback("OnClick", function()
            local input = spellIDInput:GetText()
            if not input or input == "" then
                print("|cFFFF0000Please enter a spell ID.|r")
                return
            end
            
            local spellID = tonumber(input)
            if not spellID then
                print("|cFFFF0000Please enter a valid spell ID (numeric).|r")
                return
            end
            
            local spellType = spellTypeDropdown:GetValue()
            
            -- Call the notification function directly to test
            if module.TestNotification then
                module:TestNotification(spellID, spellType)
            else
                print("|cFFFF0000Test notification function not available.|r")
            end
        end)
        spellInfoGroup:AddChild(testButton)
    end
    
    -- Function to create the Manage Spells tab
    local function CreateManageSpellsTab(container)
        -- Header
        local header = AceGUI:Create("Heading")
        header:SetText("Manage Custom Notification Spells")
        header:SetFullWidth(true)
        container:AddChild(header)
        
        -- Type filter dropdown
        local filterGroup = AceGUI:Create("SimpleGroup")
        filterGroup:SetLayout("Flow")
        filterGroup:SetFullWidth(true)
        container:AddChild(filterGroup)
        
        local filterLabel = AceGUI:Create("Label")
        filterLabel:SetText("Filter by Type:")
        filterLabel:SetWidth(100)
        filterGroup:AddChild(filterLabel)
        
        local filterDropdown = AceGUI:Create("Dropdown")
        filterDropdown:SetList({
            ["all"] = "All Types",
            ["interrupt"] = "Interrupts",
            ["dispel"] = "Dispels",
            ["important"] = "Important"
        })
        filterDropdown:SetValue("all") -- Default to all
        filterDropdown:SetWidth(200)
        filterGroup:AddChild(filterDropdown)
        
        -- Class filter checkbox
        local classFilterCheck = AceGUI:Create("CheckBox")
        classFilterCheck:SetLabel("Show Only My Class Spells")
        classFilterCheck:SetWidth(250)
        classFilterCheck:SetValue(false)
        filterGroup:AddChild(classFilterCheck)
        
        -- ScrollFrame for the spell list
        local scrollContainer = AceGUI:Create("SimpleGroup")
        scrollContainer:SetLayout("Fill")
        scrollContainer:SetFullWidth(true)
        scrollContainer:SetHeight(250)
        container:AddChild(scrollContainer)
        
        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetLayout("List")
        scrollContainer:AddChild(scroll)
        
        -- Function to update the spell list based on filters
        local function UpdateSpellList()
            scroll:ReleaseChildren()
            
            local filter = filterDropdown:GetValue()
            local classFilterEnabled = classFilterCheck:GetValue()
            
            local spells = {}
            if filter == "all" then
                spells = module:GetAllImportantSpells()
            else
                spells = module:GetSpellsByType(filter)
            end
            
            -- Apply class filter if enabled
            if classFilterEnabled then
                local playerClass = select(2, UnitClass("player"))
                local classFiltered = {}
                for id, data in pairs(spells) do
                    if data.class == playerClass then
                        classFiltered[id] = data
                    end
                end
                spells = classFiltered
            end
            
            -- Sort spells by name
            local sortedSpells = {}
            for id, data in pairs(spells) do
                table.insert(sortedSpells, {id = id, data = data})
            end
            table.sort(sortedSpells, function(a, b) return a.data.name < b.data.name end)
            
            -- Add spells to the list
            for _, spell in ipairs(sortedSpells) do
                local id = spell.id
                local data = spell.data
                
                local spellRow = AceGUI:Create("InlineGroup")
                spellRow:SetLayout("Flow")
                spellRow:SetFullWidth(true)
                spellRow:SetTitle(data.name .. " (ID: " .. id .. ")")
                
                -- Spell type
                local typeLabel = AceGUI:Create("Label")
                typeLabel:SetText("Type: " .. (spellTypes[data.type] or data.type))
                typeLabel:SetWidth(150)
                spellRow:AddChild(typeLabel)
                
                -- Priority
                local priorityLabel = AceGUI:Create("Label")
                priorityLabel:SetText("Priority: " .. (priorityLevels[data.priority] or data.priority))
                priorityLabel:SetWidth(150)
                spellRow:AddChild(priorityLabel)
                
                -- Class
                local classLabel = AceGUI:Create("Label")
                classLabel:SetText("Class: " .. (data.class or "Any"))
                classLabel:SetWidth(150)
                spellRow:AddChild(classLabel)
                
                -- Remove button (only for custom spells)
                if data.custom then
                    local removeButton = AceGUI:Create("Button")
                    removeButton:SetText("Remove")
                    removeButton:SetWidth(100)
                    removeButton:SetCallback("OnClick", function()
                        local success = module:RemoveCustomSpell(id)
                        if success then
                            UpdateSpellList()
                        end
                    end)
                    spellRow:AddChild(removeButton)
                else
                    local defaultLabel = AceGUI:Create("Label")
                    defaultLabel:SetText("Default Spell")
                    defaultLabel:SetWidth(100)
                    defaultLabel:SetColor(0.5, 0.5, 0.5)
                    spellRow:AddChild(defaultLabel)
                end
                
                -- Test button
                local testButton = AceGUI:Create("Button")
                testButton:SetText("Test")
                testButton:SetWidth(80)
                testButton:SetCallback("OnClick", function()
                    if module.TestNotification then
                        module:TestNotification(id, data.type)
                    else
                        print("|cFFFF0000Test notification function not available.|r")
                    end
                end)
                spellRow:AddChild(testButton)
                
                scroll:AddChild(spellRow)
            end
        end
        
        -- Set callbacks for filter changes
        filterDropdown:SetCallback("OnValueChanged", function() UpdateSpellList() end)
        classFilterCheck:SetCallback("OnValueChanged", function() UpdateSpellList() end)
        
        -- Initial spell list update
        UpdateSpellList()
        
        -- Buttons for management operations
        local buttonGroup = AceGUI:Create("SimpleGroup")
        buttonGroup:SetLayout("Flow")
        buttonGroup:SetFullWidth(true)
        container:AddChild(buttonGroup)
        
        local resetButton = AceGUI:Create("Button")
        resetButton:SetText("Reset Custom Spells")
        resetButton:SetWidth(200)
        resetButton:SetCallback("OnClick", function()
            StaticPopupDialogs["VUI_RESET_CUSTOM_SPELLS"] = {
                text = "Are you sure you want to reset all custom spells? This cannot be undone.",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    module.CustomSpells = {}
                    module.db.profile.customSpells = {}
                    print("|cFFFF0000All custom spells have been reset.|r")
                    UpdateSpellList()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("VUI_RESET_CUSTOM_SPELLS")
        end)
        buttonGroup:AddChild(resetButton)
    end
    
    -- Function to create the Import/Export tab
    local function CreateImportExportTab(container)
        -- Header
        local header = AceGUI:Create("Heading")
        header:SetText("Import and Export Custom Spells")
        header:SetFullWidth(true)
        container:AddChild(header)
        
        -- Description text
        local desc = AceGUI:Create("Label")
        desc:SetText("Use this panel to import or export your custom spell list. Exported data can be shared with others or saved for backup purposes.")
        desc:SetFullWidth(true)
        container:AddChild(desc)
        
        -- Export box
        local exportGroup = AceGUI:Create("InlineGroup")
        exportGroup:SetTitle("Export Custom Spells")
        exportGroup:SetLayout("Flow")
        exportGroup:SetFullWidth(true)
        container:AddChild(exportGroup)
        
        local exportBox = AceGUI:Create("MultiLineEditBox")
        exportBox:SetLabel("Copy the text below to export your custom spells:")
        exportBox:SetFullWidth(true)
        exportBox:SetNumLines(6)
        exportBox:DisableButton(true)
        exportGroup:AddChild(exportBox)
        
        -- Export button
        local exportButton = AceGUI:Create("Button")
        exportButton:SetText("Generate Export String")
        exportButton:SetWidth(200)
        exportButton:SetCallback("OnClick", function()
            -- Create export string
            local exportTable = {}
            for id, data in pairs(module.CustomSpells) do
                if data.custom then
                    exportTable[id] = {
                        type = data.type,
                        name = data.name,
                        priority = data.priority,
                        class = data.class
                    }
                end
            end
            
            -- Convert to string
            local exportString = ""
            if next(exportTable) then
                -- We'll use a very simple encoding here
                -- In a real addon, you might want to use AceSerializer
                exportString = VUI.Util:TableToString(exportTable)
            end
            
            exportBox:SetText(exportString)
            exportBox:HighlightText(0, -1)
            exportBox:SetFocus()
        end)
        exportGroup:AddChild(exportButton)
        
        -- Import box
        local importGroup = AceGUI:Create("InlineGroup")
        importGroup:SetTitle("Import Custom Spells")
        importGroup:SetLayout("Flow")
        importGroup:SetFullWidth(true)
        container:AddChild(importGroup)
        
        local importBox = AceGUI:Create("MultiLineEditBox")
        importBox:SetLabel("Paste an export string here to import custom spells:")
        importBox:SetFullWidth(true)
        importBox:SetNumLines(6)
        importBox:DisableButton(true)
        importGroup:AddChild(importBox)
        
        -- Import button
        local importButton = AceGUI:Create("Button")
        importButton:SetText("Import Spells")
        importButton:SetWidth(200)
        importButton:SetCallback("OnClick", function()
            local importString = importBox:GetText()
            if not importString or importString == "" then
                print("|cFFFF0000Please paste an export string first.|r")
                return
            end
            
            -- Try to decode the string
            local success, importTable = pcall(function()
                return VUI.Util:StringToTable(importString)
            end)
            
            if not success or type(importTable) ~= "table" then
                print("|cFFFF0000Invalid import string. Please check your input.|r")
                return
            end
            
            -- Count imported spells
            local count = 0
            for id, data in pairs(importTable) do
                local spellID = tonumber(id)
                if spellID and data.type and data.name then
                    module:AddCustomSpell(spellID, data.type, data.priority)
                    count = count + 1
                end
            end
            
            print("|cFF00FF00Successfully imported " .. count .. " custom spells.|r")
            importBox:SetText("")
        end)
        importGroup:AddChild(importButton)
    end
    
    -- Set the tab change callback
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "add" then
            CreateAddSpellTab(container)
        elseif group == "manage" then
            CreateManageSpellsTab(container)
        elseif group == "import" then
            CreateImportExportTab(container)
        end
    end)
    
    -- Select the initial tab
    tabs:SelectTab("add")
    
    -- Add the tabs to the frame
    frame:AddChild(tabs)
    
    -- Store reference to the frame
    self.spellFrame = frame
end

-- Command to open the spell management UI
function module:OpenSpellManagementUI()
    self:CreateSpellManagementUI()
end

-- Add test notification function
function module:TestNotification(spellID, spellType)
    local name, _, icon = GetSpellInfo(spellID)
    if name then
        print("|cFF00FF00Testing notification for spell:|r " .. name)
        
        -- If ShowNotification exists in the module
        if self.ShowNotification then
            self.ShowNotification(spellID, UnitGUID("player"), spellType)
        end
    else
        print("|cFFFF0000Invalid spell ID for testing.|r")
    end
end