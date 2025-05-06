-- VUI Module Verifier Tool
-- Verifies that modules comply with the standardization guidelines
local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Create the Module Verifier namespace
VUI.ModuleVerifier = {
    version = "1.0.0",
    author = "VUI Team",
    results = {},
    options = {
        autoFix = false,
        verboseOutput = true,
        checkRegistry = true,
        checkMethods = true,
        checkStructure = true,
        checkConfig = true,
        checkNaming = true,
        failOnWarning = false,
        outputToChat = true,
        generateReport = true
    }
}

-- Verifier reference
local Verifier = VUI.ModuleVerifier

-- Required methods for a standard module
local REQUIRED_METHODS = {
    "Initialize",
    "Enable",
    "Disable",
    "ApplyTheme"
}

-- Standard methods that should be available
local STANDARD_METHODS = {
    "RegisterEvents",
    "UnregisterEvents",
    "RegisterCallback",
    "UnregisterCallback",
    "CreateConfig",
    "RegisterConfig",
    "Hook",
    "Unhook",
    "Log",
    "Debug",
    "GetModuleInfo"
}

-- Initialize verifier results
function Verifier:ResetResults()
    self.results = {
        modules = {},
        total = 0,
        passed = 0,
        warnings = 0,
        errors = 0,
        fixableIssues = 0,
        modulesPassed = 0,
        modulesFailed = 0
    }
end

-- Log a message
function Verifier:Log(level, moduleName, message)
    if not moduleName then
        moduleName = "Verifier"
    end
    
    if level == "error" then
        VUI:Print("|cFFFF0000[" .. moduleName .. " Error]|r " .. message)
        self.results.errors = self.results.errors + 1
    elseif level == "warning" then
        VUI:Print("|cFFFFCC00[" .. moduleName .. " Warning]|r " .. message)
        self.results.warnings = self.results.warnings + 1
    elseif level == "info" then
        VUI:Print("|cFF00AAFF[" .. moduleName .. " Info]|r " .. message)
    elseif level == "success" then
        VUI:Print("|cFF00FF00[" .. moduleName .. " Success]|r " .. message)
    end
    
    -- Add to module results
    if moduleName ~= "Verifier" then
        if not self.results.modules[moduleName] then
            self.results.modules[moduleName] = {
                errors = 0,
                warnings = 0,
                fixable = 0,
                issues = {}
            }
        end
        
        -- Update module counters
        if level == "error" then
            self.results.modules[moduleName].errors = self.results.modules[moduleName].errors + 1
        elseif level == "warning" then
            self.results.modules[moduleName].warnings = self.results.modules[moduleName].warnings + 1
        end
        
        -- Add to issues list
        table.insert(self.results.modules[moduleName].issues, {
            level = level,
            message = message
        })
    end
end

-- Verify a module meets standards
function Verifier:VerifyModule(moduleName)
    -- Check if module exists
    if not VUI[moduleName] then
        self:Log("error", "Verifier", "Module does not exist: " .. moduleName)
        return false
    end
    
    local module = VUI[moduleName]
    local issues = 0
    
    -- Add to results
    if not self.results.modules[moduleName] then
        self.results.modules[moduleName] = {
            errors = 0,
            warnings = 0,
            fixable = 0,
            issues = {}
        }
    end
    
    -- Check if module is in registry
    if self.options.checkRegistry and VUI.ModuleRegistry then
        if not VUI.ModuleRegistry:IsModuleRegistered(moduleName) then
            self:Log("warning", moduleName, "Not registered in module registry")
            issues = issues + 1
            
            -- Mark as fixable
            self.results.modules[moduleName].fixable = self.results.modules[moduleName].fixable + 1
            self.results.fixableIssues = self.results.fixableIssues + 1
            
            -- Auto-fix if enabled
            if self.options.autoFix and VUI.ModuleStandardizer then
                self:Log("info", moduleName, "Auto-registering with module registry...")
                VUI.ModuleStandardizer:StandardizeModule(moduleName)
            end
        end
    end
    
    -- Check required methods
    if self.options.checkMethods then
        for _, method in ipairs(REQUIRED_METHODS) do
            if not module[method] or type(module[method]) ~= "function" then
                self:Log("error", moduleName, "Missing required method: " .. method)
                issues = issues + 1
                
                -- Mark as fixable
                self.results.modules[moduleName].fixable = self.results.modules[moduleName].fixable + 1
                self.results.fixableIssues = self.results.fixableIssues + 1
            end
        end
        
        -- Check standard methods (warnings only)
        for _, method in ipairs(STANDARD_METHODS) do
            if not module[method] or type(module[method]) ~= "function" then
                self:Log("warning", moduleName, "Missing standard method: " .. method)
                issues = issues + 1
                
                -- Mark as fixable
                self.results.modules[moduleName].fixable = self.results.modules[moduleName].fixable + 1
                self.results.fixableIssues = self.results.fixableIssues + 1
            end
        end
    end
    
    -- Check module structure
    if self.options.checkStructure then
        -- Check for enabled property
        if module.enabled == nil then
            self:Log("warning", moduleName, "Missing 'enabled' property")
            issues = issues + 1
            
            -- Mark as fixable
            self.results.modules[moduleName].fixable = self.results.modules[moduleName].fixable + 1
            self.results.fixableIssues = self.results.fixableIssues + 1
        end
        
        -- Check for proper event frame if RegisterEvents exists
        if module.RegisterEvents and type(module.RegisterEvents) == "function" then
            if not module.eventFrame then
                -- Only a warning if RegisterEvents exists but no eventFrame yet
                self:Log("warning", moduleName, "Has RegisterEvents but no eventFrame property")
                issues = issues + 1
            end
        end
    end
    
    -- Check configuration setup
    if self.options.checkConfig then
        -- Check if module has settings in database
        if VUI.db and VUI.db.profile and VUI.db.profile.modules then
            local lowerName = moduleName:lower()
            if not VUI.db.profile.modules[lowerName] then
                self:Log("warning", moduleName, "No settings in database profile")
                issues = issues + 1
                
                -- Mark as fixable
                self.results.modules[moduleName].fixable = self.results.modules[moduleName].fixable + 1
                self.results.fixableIssues = self.results.fixableIssues + 1
            end
        end
        
        -- Check if module has config in options panel
        if VUI.options and VUI.options.args and not VUI.options.args[moduleName] then
            self:Log("warning", moduleName, "No configuration in options panel")
            issues = issues + 1
            
            -- Mark as fixable
            self.results.modules[moduleName].fixable = self.results.modules[moduleName].fixable + 1
            self.results.fixableIssues = self.results.fixableIssues + 1
        end
    end
    
    -- Check module naming conventions
    if self.options.checkNaming then
        -- Module name should start with a capital letter
        if moduleName:sub(1, 1) ~= moduleName:sub(1, 1):upper() then
            self:Log("warning", moduleName, "Module name should start with a capital letter")
            issues = issues + 1
        end
        
        -- Module methods should follow correct casing
        for name, func in pairs(module) do
            if type(func) == "function" and name:sub(1, 1) ~= "_" then -- Ignore private methods
                if name:sub(1, 1) ~= name:sub(1, 1):upper() and name ~= "eventFrame" then
                    self:Log("warning", moduleName, "Method name '" .. name .. "' should start with a capital letter")
                    issues = issues + 1
                end
            end
        end
    end
    
    -- Determine if module passed verification
    local modulePassed = (issues == 0) or (self.options.failOnWarning == false and self.results.modules[moduleName].errors == 0)
    
    if modulePassed then
        self.results.modulesPassed = self.results.modulesPassed + 1
        self:Log("success", moduleName, "Passed verification" .. (issues > 0 and " with " .. issues .. " warnings" or ""))
    else
        self.results.modulesFailed = self.results.modulesFailed + 1
        self:Log("error", moduleName, "Failed verification with " .. self.results.modules[moduleName].errors .. " errors and " .. self.results.modules[moduleName].warnings .. " warnings")
    end
    
    return modulePassed
end

-- Verify all modules in VUI table
function Verifier:VerifyAllModules()
    -- Reset results
    self:ResetResults()
    
    -- Count total modules
    local moduleCount = 0
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and type(name) == "string" and name ~= "ModuleVerifier" then
            moduleCount = moduleCount + 1
        end
    end
    
    self.results.total = moduleCount
    self:Log("info", "Verifier", "Verifying " .. moduleCount .. " modules...")
    
    -- Verify each module
    for name, module in pairs(VUI) do
        if type(module) == "table" and module.Initialize and type(name) == "string" and name ~= "ModuleVerifier" then
            self:VerifyModule(name)
        end
    end
    
    -- Generate results summary
    self:GenerateReport()
    
    return self.results.modulesFailed == 0
end

-- Generate verification report
function Verifier:GenerateReport()
    if not self.options.generateReport then
        return
    end
    
    local report = {
        "=== VUI Module Verification Report ===",
        "Total modules: " .. self.results.total,
        "Passed: " .. self.results.modulesPassed .. " (" .. math.floor(self.results.modulesPassed / self.results.total * 100) .. "%)",
        "Failed: " .. self.results.modulesFailed .. " (" .. math.floor(self.results.modulesFailed / self.results.total * 100) .. "%)",
        "Total errors: " .. self.results.errors,
        "Total warnings: " .. self.results.warnings,
        "Fixable issues: " .. self.results.fixableIssues,
        "",
        "--- Module Details ---"
    }
    
    -- Sort modules by error count
    local sortedModules = {}
    for name, data in pairs(self.results.modules) do
        table.insert(sortedModules, {name = name, data = data})
    end
    
    table.sort(sortedModules, function(a, b)
        if a.data.errors == b.data.errors then
            return a.data.warnings > b.data.warnings
        else
            return a.data.errors > b.data.errors
        end
    end)
    
    -- Add module details
    for _, module in ipairs(sortedModules) do
        local status = "PASS"
        if module.data.errors > 0 or (self.options.failOnWarning and module.data.warnings > 0) then
            status = "FAIL"
        end
        
        table.insert(report, module.name .. ": " .. status .. " (Errors: " .. module.data.errors .. ", Warnings: " .. module.data.warnings .. ", Fixable: " .. module.data.fixable .. ")")
    end
    
    -- Add recommendation if there are fixable issues
    if self.results.fixableIssues > 0 then
        table.insert(report, "")
        table.insert(report, "Recommendation: Run the Module Standardizer to fix " .. self.results.fixableIssues .. " issues")
        table.insert(report, "Command: /vui standardize")
    end
    
    -- Print report to chat
    if self.options.outputToChat then
        for _, line in ipairs(report) do
            VUI:Print(line)
        end
    end
    
    -- Store report
    self.results.report = table.concat(report, "\n")
    
    return self.results.report
end

-- Run verification with optional auto-fix
function Verifier:Run(autoFix)
    self.options.autoFix = autoFix or false
    return self:VerifyAllModules()
end

-- Register with slash command handler
if VUI.RegisterSlashCommand then
    VUI:RegisterSlashCommand("verify", function(input)
        -- Parse options
        local autoFix = false
        
        if input and input:match("autofix") then
            autoFix = true
        end
        
        -- Run verification
        Verifier:Run(autoFix)
    end, "Verify modules comply with standards. Use 'verify autofix' to automatically fix issues.")
end