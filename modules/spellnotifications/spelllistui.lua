local addonName, VUI = ...
local module = VUI:GetModule("SpellNotifications")
local AceGUI = LibStub("AceGUI-3.0")

-- Use the categories from the module
local spellTypes = module.SpellCategories or {
    ["interrupt"] = "Interrupt",
    ["dispel"] = "Dispel",
    ["important"] = "Important",
    ["defensive"] = "Defensive Cooldowns",
    ["offensive"] = "Offensive Cooldowns",
    ["utility"] = "Utility Abilities",
    ["cc"] = "Crowd Control",
    ["healing"] = "Healing Abilities"
}

-- Use the roles from the module
local roleTypes = module.RoleCategories or {
    ["ALL"] = "All Roles",
    ["TANK"] = "Tank",
    ["HEALER"] = "Healer",
    ["DAMAGER"] = "Damage Dealer",
    ["PVP"] = "PvP"
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
        
        -- Role selection group
        local roleGroup = AceGUI:Create("InlineGroup")
        roleGroup:SetTitle("Important for Roles")
        roleGroup:SetLayout("Flow")
        roleGroup:SetFullWidth(true)
        spellInfoGroup:AddChild(roleGroup)
        
        -- Create checkboxes for each role
        local roleChecks = {}
        -- By default, select ALL role
        local selectedRoles = {ALL = true}
        
        for roleKey, roleName in pairs(roleTypes) do
            local check = AceGUI:Create("CheckBox")
            check:SetLabel(roleName)
            check:SetWidth(120)
            check:SetValue(roleKey == "ALL") -- ALL is checked by default
            check:SetCallback("OnValueChanged", function(widget, event, value)
                selectedRoles[roleKey] = value
                
                -- If ALL is selected, uncheck others
                if roleKey == "ALL" and value then
                    for k, v in pairs(roleChecks) do
                        if k ~= "ALL" then
                            v:SetValue(false)
                            selectedRoles[k] = false
                        end
                    end
                -- If a specific role is selected, uncheck ALL
                elseif roleKey ~= "ALL" and value then
                    roleChecks["ALL"]:SetValue(false)
                    selectedRoles["ALL"] = false
                end
                
                -- If no roles are selected, default to ALL
                local anySelected = false
                for k, v in pairs(selectedRoles) do
                    if v then
                        anySelected = true
                        break
                    end
                end
                
                if not anySelected then
                    roleChecks["ALL"]:SetValue(true)
                    selectedRoles["ALL"] = true
                end
            end)
            roleGroup:AddChild(check)
            roleChecks[roleKey] = check
        end
        
        -- Notes field
        local notesField = AceGUI:Create("MultiLineEditBox")
        notesField:SetLabel("Notes (optional):")
        notesField:SetFullWidth(true)
        notesField:SetNumLines(2)
        spellInfoGroup:AddChild(notesField)
        
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
            local notes = notesField:GetText()
            
            -- Collect selected roles
            local roles = {}
            for roleKey, isSelected in pairs(selectedRoles) do
                if isSelected then
                    table.insert(roles, roleKey)
                end
            end
            
            local success = module:AddCustomSpell(spellID, spellType, priority, roles, notes)
            if success then
                -- Clear the form
                spellIDInput:SetText("")
                spellName:SetText("Spell Name: ")
                spellIcon:SetImage(nil)
                notesField:SetText("")
                
                -- Reset role selection to default (ALL selected)
                for roleKey, check in pairs(roleChecks) do
                    check:SetValue(roleKey == "ALL")
                    selectedRoles[roleKey] = (roleKey == "ALL")
                end
                
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
        
        -- Create dropdown with all available spell types
        local filterList = {["all"] = "All Types"}
        for key, name in pairs(spellTypes) do
            filterList[key] = name
        end
        
        local filterDropdown = AceGUI:Create("Dropdown")
        filterDropdown:SetList(filterList)
        filterDropdown:SetValue("all") -- Default to all
        filterDropdown:SetWidth(200)
        filterGroup:AddChild(filterDropdown)
        
        -- Role filter dropdown
        local roleLabel = AceGUI:Create("Label")
        roleLabel:SetText("Filter by Role:")
        roleLabel:SetWidth(100)
        filterGroup:AddChild(roleLabel)
        
        local roleDropdown = AceGUI:Create("Dropdown")
        roleDropdown:SetList(roleTypes)
        roleDropdown:SetValue("ALL") -- Default to ALL
        roleDropdown:SetWidth(200)
        filterGroup:AddChild(roleDropdown)
        
        -- Class filter checkbox
        local classFilterCheck = AceGUI:Create("CheckBox")
        classFilterCheck:SetLabel("Show Only My Class Spells")
        classFilterCheck:SetWidth(250)
        classFilterCheck:SetValue(false)
        filterGroup:AddChild(classFilterCheck)
        
        -- Custom spells only checkbox
        local customOnlyCheck = AceGUI:Create("CheckBox")
        customOnlyCheck:SetLabel("Show Only Custom Spells")
        customOnlyCheck:SetWidth(250)
        customOnlyCheck:SetValue(false)
        filterGroup:AddChild(customOnlyCheck)
        
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
            
            -- Gather all filter settings
            local typeFilter = filterDropdown:GetValue()
            local roleFilter = roleDropdown:GetValue()
            local classFilterEnabled = classFilterCheck:GetValue()
            local customOnlyEnabled = customOnlyCheck:GetValue()
            
            -- Use our advanced filtering function
            local filterOptions = {
                type = typeFilter,
                role = roleFilter,
                customOnly = customOnlyEnabled
            }
            
            -- Add class filter if enabled
            if classFilterEnabled then
                filterOptions.class = select(2, UnitClass("player"))
            end
            
            -- Get filtered spells using the new FilterSpells function
            local spells = module:FilterSpells(filterOptions)
            
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
        
        -- Add a search box for name filtering
        local searchGroup = AceGUI:Create("SimpleGroup")
        searchGroup:SetLayout("Flow")
        searchGroup:SetFullWidth(true)
        container:AddChild(searchGroup)
        
        local searchLabel = AceGUI:Create("Label")
        searchLabel:SetText("Search:")
        searchLabel:SetWidth(70)
        searchGroup:AddChild(searchLabel)
        
        local searchBox = AceGUI:Create("EditBox")
        searchBox:SetWidth(250)
        searchBox:SetCallback("OnTextChanged", function(widget, event, text) 
            -- Create a short delay before updating to avoid excessive updates while typing
            if searchBox.updateTimer then
                searchBox.updateTimer:Cancel()
            end
            searchBox.updateTimer = C_Timer.After(0.3, function()
                UpdateSpellList()
                searchBox.updateTimer = nil
            end)
        end)
        searchGroup:AddChild(searchBox)
        
        -- Set callbacks for filter changes
        filterDropdown:SetCallback("OnValueChanged", function() UpdateSpellList() end)
        roleDropdown:SetCallback("OnValueChanged", function() UpdateSpellList() end)
        classFilterCheck:SetCallback("OnValueChanged", function() UpdateSpellList() end)
        customOnlyCheck:SetCallback("OnValueChanged", function() UpdateSpellList() end)
        
        -- Update our filter function to include search text
        local originalUpdateSpellList = UpdateSpellList
        UpdateSpellList = function()
            -- Get the search text
            local searchText = searchBox:GetText()
            
            -- Gather all filter settings
            local typeFilter = filterDropdown:GetValue()
            local roleFilter = roleDropdown:GetValue()
            local classFilterEnabled = classFilterCheck:GetValue()
            local customOnlyEnabled = customOnlyCheck:GetValue()
            
            -- Use our advanced filtering function
            local filterOptions = {
                type = typeFilter,
                role = roleFilter,
                customOnly = customOnlyEnabled,
                nameFilter = searchText
            }
            
            -- Add class filter if enabled
            if classFilterEnabled then
                filterOptions.class = select(2, UnitClass("player"))
            end
            
            -- Clear existing list
            scroll:ReleaseChildren()
            
            -- Get filtered spells using the new FilterSpells function
            local spells = module:FilterSpells(filterOptions)
            
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
                
                -- (rest of spell row creation code)
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
            
            -- Show count of displayed spells
            local countLabel = AceGUI:Create("Label")
            local spellCount = #sortedSpells
            local countText = spellCount .. " spell" .. (spellCount ~= 1 and "s" or "") .. " found"
            countLabel:SetText(countText)
            countLabel:SetFullWidth(true)
            scroll:AddChild(countLabel)
        end
        
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
                        class = data.class,
                        roles = data.roles,
                        notes = data.notes
                    }
                end
            end
            
            -- Convert to string
            local exportString = ""
            if next(exportTable) then
                -- Use the core VUI.Utils functions for consistent serialization
                exportString = VUI.Utils:TableToString(exportTable)
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
                return VUI.Utils:StringToTable(importString)
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
                    -- Extract roles and priority with fallback values
                    local priority = data.priority or 2
                    local roles = data.roles or {"ALL"}
                    local notes = data.notes or ""
                    
                    -- Import the spell with all available data
                    module:AddCustomSpell(spellID, data.type, priority, roles, notes)
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