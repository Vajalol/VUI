--[[
    VUI - MultiNotification SpellManagementUI
    Version: 1.0.0
    Author: VortexQ8
    
    Spell management UI for the unified notification system
]]

local _, VUI = ...
local MultiNotification = VUI:GetModule("MultiNotification")
local AceGUI = LibStub("AceGUI-3.0")

-- Local reference to available spell types and roles for UI dropdowns
local spellTypes = {}
local roleTypes = {}

-- Priority levels for the dropdown
local priorityLevels = {
    [1] = "Low",
    [2] = "Medium",
    [3] = "High"
}

-- Setup the UI variables once we know the categories are loaded
local function InitializeUIComponents()
    -- Use the categories from the module
    spellTypes = MultiNotification.SpellCategories or {
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
    roleTypes = MultiNotification.RoleCategories or {
        ["ALL"] = "All Roles",
        ["TANK"] = "Tank",
        ["HEALER"] = "Healer",
        ["DAMAGER"] = "Damage Dealer",
        ["PVP"] = "PvP"
    }
end

-- Function to create the spell management window
function MultiNotification:CreateSpellManagementUI()
    -- Make sure we have the categories loaded
    if not self.SpellCategories then
        VUI:Print("Spell categories not initialized. Please try again.")
        return
    end
    
    -- Initialize UI components if needed
    if not next(spellTypes) then
        InitializeUIComponents()
    end
    
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
                for id, data in pairs(self:GetAllImportantSpells()) do
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
            
            local success = self:AddCustomSpell(spellID, spellType, priority, roles, notes)
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
            if self.TestSpellNotification then
                self:TestSpellNotification(spellID, spellType)
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
            
            -- Get filtered spells
            local spells = self:FilterSpells(filterOptions)
            
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
                
                -- Roles
                local roleText = "Roles: "
                if data.roles then
                    for _, role in ipairs(data.roles) do
                        roleText = roleText .. role .. ", "
                    end
                    roleText = roleText:sub(1, -3) -- Remove trailing comma
                else
                    roleText = roleText .. "ALL"
                end
                local rolesLabel = AceGUI:Create("Label")
                rolesLabel:SetText(roleText)
                rolesLabel:SetWidth(300)
                spellRow:AddChild(rolesLabel)
                
                -- Notes (if any)
                if data.notes and data.notes ~= "" then
                    local notesLabel = AceGUI:Create("Label")
                    notesLabel:SetText("Notes: " .. data.notes)
                    notesLabel:SetFullWidth(true)
                    spellRow:AddChild(notesLabel)
                end
                
                -- Action buttons group
                local actionGroup = AceGUI:Create("SimpleGroup")
                actionGroup:SetLayout("Flow")
                actionGroup:SetFullWidth(true)
                spellRow:AddChild(actionGroup)
                
                -- Test button
                local testButton = AceGUI:Create("Button")
                testButton:SetText("Test")
                testButton:SetWidth(80)
                testButton:SetCallback("OnClick", function()
                    if self.TestSpellNotification then
                        self:TestSpellNotification(id, data.type)
                    else
                        print("|cFFFF0000Test notification function not available.|r")
                    end
                end)
                actionGroup:AddChild(testButton)
                
                -- Edit button
                local editButton = AceGUI:Create("Button")
                editButton:SetText("Edit")
                editButton:SetWidth(80)
                editButton:SetCallback("OnClick", function()
                    -- Implementation of edit functionality
                    print("Edit functionality not yet implemented")
                end)
                actionGroup:AddChild(editButton)
                
                -- Remove button
                local removeButton = AceGUI:Create("Button")
                removeButton:SetText("Remove")
                removeButton:SetWidth(80)
                removeButton:SetCallback("OnClick", function()
                    -- Remove the spell from important spells list
                    self:RemoveImportantSpell(id)
                    -- Update the spell list
                    UpdateSpellList()
                end)
                actionGroup:AddChild(removeButton)
                
                scroll:AddChild(spellRow)
            end
            
            -- Add a message if no spells were found
            if #sortedSpells == 0 then
                local noSpellsLabel = AceGUI:Create("Label")
                noSpellsLabel:SetText("No spells found matching the selected filters.")
                noSpellsLabel:SetFullWidth(true)
                scroll:AddChild(noSpellsLabel)
            end
        end
        
        -- Update filters callback
        filterDropdown:SetCallback("OnValueChanged", function(widget) UpdateSpellList() end)
        roleDropdown:SetCallback("OnValueChanged", function(widget) UpdateSpellList() end)
        classFilterCheck:SetCallback("OnValueChanged", function(widget) UpdateSpellList() end)
        customOnlyCheck:SetCallback("OnValueChanged", function(widget) UpdateSpellList() end)
        
        -- Add refresh button
        local refreshButton = AceGUI:Create("Button")
        refreshButton:SetText("Refresh List")
        refreshButton:SetWidth(150)
        refreshButton:SetCallback("OnClick", function() UpdateSpellList() end)
        container:AddChild(refreshButton)
        
        -- Initial update
        UpdateSpellList()
    end
    
    -- Function to create the Import/Export tab
    local function CreateImportExportTab(container)
        -- Header
        local header = AceGUI:Create("Heading")
        header:SetText("Import/Export Spell Notification Settings")
        header:SetFullWidth(true)
        container:AddChild(header)
        
        -- Description
        local desc = AceGUI:Create("Label")
        desc:SetText("Use this interface to import or export your spell notification settings. This allows you to share settings with others or backup your configuration.")
        desc:SetFullWidth(true)
        container:AddChild(desc)
        
        -- Export section
        local exportHeader = AceGUI:Create("Heading")
        exportHeader:SetText("Export Settings")
        exportHeader:SetFullWidth(true)
        container:AddChild(exportHeader)
        
        -- Export options
        local exportOptions = AceGUI:Create("InlineGroup")
        exportOptions:SetLayout("Flow")
        exportOptions:SetFullWidth(true)
        exportOptions:SetTitle("Export Options")
        container:AddChild(exportOptions)
        
        -- Export type select
        local exportTypeDropdown = AceGUI:Create("Dropdown")
        exportTypeDropdown:SetLabel("What to Export:")
        exportTypeDropdown:SetList({
            ["all"] = "All Spell Settings",
            ["custom"] = "Custom Spells Only",
            ["type"] = "By Spell Type"
        })
        exportTypeDropdown:SetValue("all")
        exportTypeDropdown:SetWidth(200)
        exportOptions:AddChild(exportTypeDropdown)
        
        -- Type filter for export (hidden initially)
        local exportTypeFilter = AceGUI:Create("Dropdown")
        exportTypeFilter:SetLabel("Spell Type to Export:")
        exportTypeFilter:SetList(spellTypes)
        exportTypeFilter:SetValue("interrupt")
        exportTypeFilter:SetWidth(200)
        exportTypeFilter:SetDisabled(true)
        exportOptions:AddChild(exportTypeFilter)
        
        -- Link exportTypeDropdown to show/hide exportTypeFilter
        exportTypeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
            exportTypeFilter:SetDisabled(value ~= "type")
        end)
        
        -- Export button
        local exportButton = AceGUI:Create("Button")
        exportButton:SetText("Generate Export String")
        exportButton:SetWidth(200)
        exportButton:SetCallback("OnClick", function()
            local exportType = exportTypeDropdown:GetValue()
            local exportData
            
            if exportType == "all" then
                exportData = self:ExportAllSpells()
            elseif exportType == "custom" then
                exportData = self:ExportCustomSpells()
            elseif exportType == "type" then
                local typeFilter = exportTypeFilter:GetValue()
                exportData = self:ExportSpellsByType(typeFilter)
            end
            
            if exportData then
                exportBox:SetText(exportData)
            else
                exportBox:SetText("Error generating export data.")
            end
        end)
        exportOptions:AddChild(exportButton)
        
        -- Export box
        local exportBox = AceGUI:Create("MultiLineEditBox")
        exportBox:SetLabel("Export String (Ctrl+C to copy):")
        exportBox:SetFullWidth(true)
        exportBox:SetNumLines(6)
        container:AddChild(exportBox)
        
        -- Import section
        local importHeader = AceGUI:Create("Heading")
        importHeader:SetText("Import Settings")
        importHeader:SetFullWidth(true)
        container:AddChild(importHeader)
        
        -- Import box
        local importBox = AceGUI:Create("MultiLineEditBox")
        importBox:SetLabel("Paste Import String (Ctrl+V):")
        importBox:SetFullWidth(true)
        importBox:SetNumLines(6)
        container:AddChild(importBox)
        
        -- Import options
        local importOptions = AceGUI:Create("InlineGroup")
        importOptions:SetLayout("Flow")
        importOptions:SetFullWidth(true)
        importOptions:SetTitle("Import Options")
        container:AddChild(importOptions)
        
        -- Import type select
        local importMethod = AceGUI:Create("Dropdown")
        importMethod:SetLabel("Import Method:")
        importMethod:SetList({
            ["merge"] = "Merge with Existing Settings",
            ["replace"] = "Replace Existing Settings"
        })
        importMethod:SetValue("merge")
        importMethod:SetWidth(200)
        importOptions:AddChild(importMethod)
        
        -- Import button
        local importButton = AceGUI:Create("Button")
        importButton:SetText("Import Settings")
        importButton:SetWidth(200)
        importButton:SetCallback("OnClick", function()
            local importString = importBox:GetText()
            local method = importMethod:GetValue()
            
            if not importString or importString == "" then
                print("|cFFFF0000Please enter an import string.|r")
                return
            end
            
            local success, message = self:ImportSpells(importString, method)
            if success then
                print("|cFF00FF00Import successful: " .. message .. "|r")
                importBox:SetText("")
            else
                print("|cFFFF0000Import failed: " .. (message or "Unknown error") .. "|r")
            end
        end)
        importOptions:AddChild(importButton)
    end
    
    -- Set callback to handle tab changes
    tabs:SetCallback("OnGroupSelected", function(widget, event, value)
        widget:ReleaseChildren()
        if value == "add" then
            CreateAddSpellTab(widget)
        elseif value == "manage" then
            CreateManageSpellsTab(widget)
        elseif value == "import" then
            CreateImportExportTab(widget)
        end
    end)
    
    -- Select the default tab
    tabs:SelectTab("add")
    
    -- Add the tabs to the frame
    frame:AddChild(tabs)
    
    -- Store reference to frame
    self.spellFrame = frame
end

-- Command to open the spell management UI
function MultiNotification:OpenSpellManagementUI()
    self:CreateSpellManagementUI()
end

-- Helper spell management functions
function MultiNotification:AddCustomSpell(spellID, spellType, priority, roles, notes)
    if not spellID then return false end
    if not self.db.profile.spellSettings.importantSpells then 
        self.db.profile.spellSettings.importantSpells = {}
    end
    
    -- Get spell info
    local name, _, icon = GetSpellInfo(spellID)
    if not name then
        print("|cFFFF0000Error:|r Could not find spell with ID " .. spellID)
        return false
    end
    
    -- Add to important spells
    self.db.profile.spellSettings.importantSpells[spellID] = {
        id = spellID,
        name = name,
        icon = icon,
        type = spellType or "important",
        priority = priority or 2, -- Default to medium priority
        roles = roles or {"ALL"},
        notes = notes,
        custom = true -- Mark as custom added
    }
    
    print("|cFF00FF00Added|r " .. name .. " to notification list as " .. (spellType or "important"))
    return true
end

function MultiNotification:RemoveImportantSpell(spellID)
    if not spellID or not self.db.profile.spellSettings.importantSpells then return false end
    
    -- Check if spell exists
    local spellData = self.db.profile.spellSettings.importantSpells[spellID]
    if not spellData then
        print("|cFFFF0000Error:|r Spell not found in notification list.")
        return false
    end
    
    -- Remove from list
    self.db.profile.spellSettings.importantSpells[spellID] = nil
    print("|cFF00FF00Removed|r " .. (spellData.name or "Spell #" .. spellID) .. " from notification list.")
    return true
end

function MultiNotification:GetAllImportantSpells()
    return self.db.profile.spellSettings.importantSpells or {}
end

function MultiNotification:FilterSpells(options)
    local spells = self:GetAllImportantSpells()
    local filteredSpells = {}
    
    -- Default options
    options = options or {}
    options.type = options.type or "all"
    options.role = options.role or "ALL"
    options.customOnly = options.customOnly or false
    
    for id, data in pairs(spells) do
        local includeSpell = true
        
        -- Filter by type
        if options.type ~= "all" and data.type ~= options.type then
            includeSpell = false
        end
        
        -- Filter by role
        if options.role ~= "ALL" and data.roles then
            local hasRole = false
            for _, role in ipairs(data.roles) do
                if role == "ALL" or role == options.role then
                    hasRole = true
                    break
                end
            end
            if not hasRole then includeSpell = false end
        end
        
        -- Filter by class
        if options.class and data.class and data.class ~= options.class then
            includeSpell = false
        end
        
        -- Filter by custom flag
        if options.customOnly and not data.custom then
            includeSpell = false
        end
        
        if includeSpell then
            filteredSpells[id] = data
        end
    end
    
    return filteredSpells
end

-- Import/Export functions
function MultiNotification:ExportAllSpells()
    local exportData = {
        version = VUI.version,
        timestamp = time(),
        spells = self:GetAllImportantSpells()
    }
    
    -- Serialize the data
    local serialized = LibStub("AceSerializer-3.0"):Serialize(exportData)
    return LibStub("LibDeflate"):EncodeForPrint(LibStub("LibDeflate"):CompressDeflate(serialized))
end

function MultiNotification:ExportCustomSpells()
    local exportData = {
        version = VUI.version,
        timestamp = time(),
        spells = {}
    }
    
    -- Only include custom spells
    for id, data in pairs(self:GetAllImportantSpells()) do
        if data.custom then
            exportData.spells[id] = data
        end
    end
    
    -- Serialize the data
    local serialized = LibStub("AceSerializer-3.0"):Serialize(exportData)
    return LibStub("LibDeflate"):EncodeForPrint(LibStub("LibDeflate"):CompressDeflate(serialized))
end

function MultiNotification:ExportSpellsByType(spellType)
    if not spellType then return nil end
    
    local exportData = {
        version = VUI.version,
        timestamp = time(),
        spells = {}
    }
    
    -- Only include spells of the specified type
    for id, data in pairs(self:GetAllImportantSpells()) do
        if data.type == spellType then
            exportData.spells[id] = data
        end
    end
    
    -- Serialize the data
    local serialized = LibStub("AceSerializer-3.0"):Serialize(exportData)
    return LibStub("LibDeflate"):EncodeForPrint(LibStub("LibDeflate"):CompressDeflate(serialized))
end

function MultiNotification:ImportSpells(importString, method)
    if not importString or importString == "" then
        return false, "No import string provided"
    end
    
    -- Decompress and deserialize the data
    local decoded = LibStub("LibDeflate"):DecodeForPrint(importString)
    if not decoded then
        return false, "Invalid import string format"
    end
    
    local decompressed = LibStub("LibDeflate"):DecompressDeflate(decoded)
    if not decompressed then
        return false, "Failed to decompress import data"
    end
    
    local success, importData = LibStub("AceSerializer-3.0"):Deserialize(decompressed)
    if not success or not importData then
        return false, "Failed to deserialize import data"
    end
    
    -- Check version compatibility
    if not importData.version then
        return false, "Import data missing version information"
    end
    
    -- Import the spells
    local count = 0
    if method == "replace" then
        -- Replace existing spells
        self.db.profile.spellSettings.importantSpells = {}
    end
    
    -- Add imported spells
    for id, data in pairs(importData.spells) do
        self.db.profile.spellSettings.importantSpells[id] = data
        count = count + 1
    end
    
    return true, "Imported " .. count .. " spells"
end

-- Register this file to be loaded with the module
VUI:RegisterModuleScript("MultiNotification", "SpellManagementUI")