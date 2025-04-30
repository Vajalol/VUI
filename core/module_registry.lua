-- VUI Module Registry
-- Central registry for all VUI modules with metadata and dependency management
local addonName, VUI = ...

-- Create the Module Registry namespace
VUI.ModuleRegistry = {
    modules = {},
    status = {
        total = 0,
        enabled = 0,
        loading = 0,
        errors = 0
    }
}

-- Reference to the registry
local Registry = VUI.ModuleRegistry

-- Default module metadata template
local DEFAULT_METADATA = {
    name = "Unknown",
    description = "No description available",
    version = "0.1.0",
    author = "VUI Team",
    category = "Uncategorized",
    dependencies = {},
    conflicts = {},
    features = {},
    hooks = {},
    isCore = false,
    isRequired = false,
    loadOnDemand = false,
    loadOrder = 50,
    settings = {},
    hasCommands = false,
    hasMigration = false,
    hasEvents = false,
    hasGUI = false,
    hasAPI = false,
    created = "2024-04-30",
    lastUpdated = "2024-04-30",
    documentation = "",
    repo = "",
    forkedFrom = "",
    attribution = "",
    parentModule = nil
}

-- Register a module with the registry
function Registry:RegisterModule(name, metadata)
    if not name then
        VUI:Print("Error: Cannot register module without a name")
        return false
    end
    
    -- Merge with default metadata
    local moduleData = {}
    for k, v in pairs(DEFAULT_METADATA) do
        moduleData[k] = v
    end
    
    -- Override with provided metadata
    if metadata then
        for k, v in pairs(metadata) do
            moduleData[k] = v
        end
    end
    
    -- Ensure name is set
    moduleData.name = name
    
    -- Store in registry
    self.modules[name] = moduleData
    
    -- Update status
    self.status.total = self.status.total + 1
    
    -- Check if module is enabled
    local lowerName = name:lower()
    if VUI.db and VUI.db.profile.modules and VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled then
        self.status.enabled = self.status.enabled + 1
    end
    
    -- Debug output
    if VUI.debug then
        VUI:Print("Registered module: " .. name)
    end
    
    return true
end

-- Unregister a module from the registry
function Registry:UnregisterModule(name)
    if not name or not self.modules[name] then
        return false
    end
    
    -- Check if module was enabled before removing
    local lowerName = name:lower()
    local wasEnabled = VUI.db and VUI.db.profile.modules and VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled
    
    -- Remove from registry
    self.modules[name] = nil
    
    -- Update status
    self.status.total = self.status.total - 1
    if wasEnabled then
        self.status.enabled = self.status.enabled - 1
    end
    
    -- Debug output
    if VUI.debug then
        VUI:Print("Unregistered module: " .. name)
    end
    
    return true
end

-- Check if a module is registered
function Registry:IsModuleRegistered(name)
    return self.modules[name] ~= nil
end

-- Get a module's metadata
function Registry:GetModuleMetadata(name)
    return self.modules[name]
end

-- Get all registered modules
function Registry:GetAllModules()
    return self.modules
end

-- Get enabled modules
function Registry:GetEnabledModules()
    local enabled = {}
    
    for name, metadata in pairs(self.modules) do
        local lowerName = name:lower()
        if VUI.db and VUI.db.profile.modules and VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled then
            enabled[name] = metadata
        end
    end
    
    return enabled
end

-- Get modules by category
function Registry:GetModulesByCategory(category)
    if not category then return {} end
    
    local modules = {}
    
    for name, metadata in pairs(self.modules) do
        if metadata.category == category then
            modules[name] = metadata
        end
    end
    
    return modules
end

-- Get modules with a specific feature
function Registry:GetModulesWithFeature(feature)
    if not feature then return {} end
    
    local modules = {}
    
    for name, metadata in pairs(self.modules) do
        if metadata.features and tContains(metadata.features, feature) then
            modules[name] = metadata
        end
    end
    
    return modules
end

-- Check if a module has dependencies
function Registry:HasDependencies(name)
    if not name or not self.modules[name] then return false end
    
    return self.modules[name].dependencies and #self.modules[name].dependencies > 0
end

-- Check if a module's dependencies are satisfied
function Registry:AreDependenciesSatisfied(name)
    if not name or not self.modules[name] then return false end
    if not self:HasDependencies(name) then return true end
    
    local metadata = self.modules[name]
    
    -- Check each dependency
    for _, dependency in ipairs(metadata.dependencies) do
        -- Check if dependency exists and is enabled
        if not self:IsModuleRegistered(dependency) then
            return false
        end
        
        local lowerName = dependency:lower()
        if not VUI.db or not VUI.db.profile.modules or not VUI.db.profile.modules[lowerName] or not VUI.db.profile.modules[lowerName].enabled then
            return false
        end
    end
    
    return true
end

-- Check for conflicts with other modules
function Registry:HasConflicts(name)
    if not name or not self.modules[name] then return false end
    
    local metadata = self.modules[name]
    
    -- No conflicts defined
    if not metadata.conflicts or #metadata.conflicts == 0 then
        return false
    end
    
    -- Check each conflict
    for _, conflict in ipairs(metadata.conflicts) do
        -- Check if conflicting module exists and is enabled
        if self:IsModuleRegistered(conflict) then
            local lowerName = conflict:lower()
            if VUI.db and VUI.db.profile.modules and VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled then
                return true
            end
        end
    end
    
    return false
end

-- Get sorted modules based on load order
function Registry:GetSortedModules()
    local sorted = {}
    
    -- Collect modules
    for name, metadata in pairs(self.modules) do
        table.insert(sorted, {
            name = name,
            loadOrder = metadata.loadOrder or 50
        })
    end
    
    -- Sort by load order
    table.sort(sorted, function(a, b)
        return a.loadOrder < b.loadOrder
    end)
    
    return sorted
end

-- Update module statistics
function Registry:UpdateStatistics()
    -- Reset counters
    self.status.total = 0
    self.status.enabled = 0
    self.status.loading = 0
    self.status.errors = 0
    
    -- Count modules
    for name, _ in pairs(self.modules) do
        self.status.total = self.status.total + 1
        
        -- Check if enabled
        local lowerName = name:lower()
        if VUI.db and VUI.db.profile.modules and VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled then
            self.status.enabled = self.status.enabled + 1
        end
    end
end

-- Check if a module is enabled
function Registry:IsModuleEnabled(name)
    if not name then return false end
    
    local lowerName = name:lower()
    return VUI.db and VUI.db.profile.modules and VUI.db.profile.modules[lowerName] and VUI.db.profile.modules[lowerName].enabled
end

-- Enable a module
function Registry:EnableModule(name)
    if not name or not self:IsModuleRegistered(name) then
        return false
    end
    
    local lowerName = name:lower()
    
    -- Create settings if they don't exist
    if not VUI.db.profile.modules[lowerName] then
        VUI.db.profile.modules[lowerName] = {}
    end
    
    -- Enable the module
    VUI.db.profile.modules[lowerName].enabled = true
    
    -- Call Enable method if it exists
    if VUI[name] and VUI[name].Enable then
        VUI[name]:Enable()
    end
    
    -- Update status
    self.status.enabled = self.status.enabled + 1
    
    return true
end

-- Disable a module
function Registry:DisableModule(name)
    if not name or not self:IsModuleRegistered(name) then
        return false
    end
    
    local lowerName = name:lower()
    
    -- Check if already disabled
    if not VUI.db.profile.modules[lowerName] or not VUI.db.profile.modules[lowerName].enabled then
        return true
    end
    
    -- Disable the module
    VUI.db.profile.modules[lowerName].enabled = false
    
    -- Call Disable method if it exists
    if VUI[name] and VUI[name].Disable then
        VUI[name]:Disable()
    end
    
    -- Update status
    self.status.enabled = self.status.enabled - 1
    
    return true
end

-- Update a module's metadata
function Registry:UpdateModuleMetadata(name, metadata)
    if not name or not self:IsModuleRegistered(name) then
        return false
    end
    
    -- Update fields from metadata
    for k, v in pairs(metadata) do
        self.modules[name][k] = v
    end
    
    return true
end

-- Generate module documentation
function Registry:GenerateModuleDocumentation(name)
    if not name or not self:IsModuleRegistered(name) then
        return ""
    end
    
    local metadata = self.modules[name]
    local doc = {
        "# " .. name,
        "",
        "## Description",
        metadata.description or "No description available",
        "",
        "## Version",
        metadata.version or "0.1.0",
        "",
        "## Author",
        metadata.author or "VUI Team",
        "",
        "## Category",
        metadata.category or "Uncategorized",
        ""
    }
    
    -- Add dependencies if any
    if metadata.dependencies and #metadata.dependencies > 0 then
        table.insert(doc, "## Dependencies")
        for _, dep in ipairs(metadata.dependencies) do
            table.insert(doc, "- " .. dep)
        end
        table.insert(doc, "")
    end
    
    -- Add conflicts if any
    if metadata.conflicts and #metadata.conflicts > 0 then
        table.insert(doc, "## Conflicts")
        for _, conflict in ipairs(metadata.conflicts) do
            table.insert(doc, "- " .. conflict)
        end
        table.insert(doc, "")
    end
    
    -- Add features if any
    if metadata.features and #metadata.features > 0 then
        table.insert(doc, "## Features")
        for _, feature in ipairs(metadata.features) do
            table.insert(doc, "- " .. feature)
        end
        table.insert(doc, "")
    end
    
    -- Add additional info
    if metadata.documentation and metadata.documentation ~= "" then
        table.insert(doc, "## Documentation")
        table.insert(doc, metadata.documentation)
        table.insert(doc, "")
    end
    
    -- Join all lines with newlines
    return table.concat(doc, "\n")
end

-- Initialize the Registry
function Registry:Initialize()
    -- Scan for modules in VUI table
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and type(name) == "string" then
            -- Only register if not already registered
            if not self:IsModuleRegistered(name) then
                self:RegisterModule(name, {
                    name = name,
                    description = "Core VUI module",
                    version = "0.1.0",
                    author = "VUI Team",
                    category = "Core"
                })
            end
        end
    end
    
    -- Update statistics
    self:UpdateStatistics()
    
    -- Debug output
    if VUI.debug then
        VUI:Print("Module Registry initialized with " .. self.status.total .. " modules")
    end
end

-- Hook into VUI initialization
if VUI.HookInitialize then
    VUI:HookInitialize(function()
        Registry:Initialize()
    end)
end