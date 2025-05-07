-- VUI Validation Suite
-- Comprehensive testing framework for final validation before release
local addonName, VUI = ...

-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the Validation Suite namespace
VUI.ValidationSuite = {
    version = "1.0.0",
    author = "VUI Team",
    results = {},
    tests = {},
    options = {
        verboseOutput = true,
        outputToChat = true,
        generateReport = true,
        testCategories = {
            "module_integration",
            "performance",
            "error_handling",
            "compatibility",
            "stress_test"
        }
    }
}

-- Validation Suite reference
local VS = VUI.ValidationSuite

-- Initialize the results table
function VS:InitResults()
    self.results = {
        total = 0,
        passed = 0,
        failed = 0,
        skipped = 0,
        categories = {},
        testResults = {},
        startTime = time(),
        endTime = nil,
        totalTime = nil
    }
    
    -- Initialize categories
    for _, category in ipairs(self.options.testCategories) do
        self.results.categories[category] = {
            total = 0,
            passed = 0,
            failed = 0,
            skipped = 0
        }
    end
end

-- Log a message with color
function VS:Log(level, category, message)
    if not self.options.verboseOutput and level == "info" then
        return
    end
    
    local colors = {
        info = "ffffff",
        success = "00ff00",
        warning = "ffff00",
        error = "ff0000",
        skipped = "888888"
    }
    
    local prefix = "[VS:" .. category .. "] "
    local coloredMessage = "|cff" .. (colors[level] or "ffffff") .. prefix .. message .. "|r"
    
    if self.options.outputToChat then
        if VUI.Print then
            VUI:Print(coloredMessage)
        else
            print(coloredMessage)
        end
    end
    
    return coloredMessage
end

-- Register a test
function VS:RegisterTest(category, name, func, dependencies)
    if not self.tests[category] then
        self.tests[category] = {}
    end
    
    self.tests[category][name] = {
        func = func,
        dependencies = dependencies or {},
        executed = false,
        result = nil
    }
    
    self:Log("info", "Registration", "Registered test: " .. category .. " - " .. name)
end

-- Run a specific test
function VS:RunTest(category, name)
    if not self.tests[category] or not self.tests[category][name] then
        self:Log("error", "Execution", "Test not found: " .. category .. " - " .. name)
        return false
    end
    
    local test = self.tests[category][name]
    
    -- Skip if already executed
    if test.executed then
        return test.result
    end
    
    -- Check dependencies
    for _, dep in ipairs(test.dependencies) do
        local depCategory, depName = strsplit(":", dep)
        if not self.tests[depCategory] or not self.tests[depCategory][depName] then
            self:Log("error", "Execution", "Dependency not found: " .. dep .. " for test " .. category .. " - " .. name)
            return false
        end
        
        if not self.tests[depCategory][depName].executed then
            local depResult = self:RunTest(depCategory, depName)
            if not depResult then
                self:Log("warning", "Execution", "Skipping test " .. category .. " - " .. name .. " due to failed dependency: " .. dep)
                
                -- Record the skip
                self.results.skipped = self.results.skipped + 1
                self.results.categories[category].skipped = self.results.categories[category].skipped + 1
                
                -- Mark as executed but skipped
                test.executed = true
                test.result = false
                test.skipped = true
                
                -- Record the result
                self.results.testResults[category .. ":" .. name] = {
                    result = false,
                    skipped = true,
                    error = "Dependency failed: " .. dep
                }
                
                return false
            end
        end
    end
    
    -- Execute the test
    self:Log("info", "Execution", "Running test: " .. category .. " - " .. name)
    
    local success, result = pcall(test.func)
    
    -- Record the result
    test.executed = true
    
    if not success then
        self:Log("error", "Execution", "Test failed with error: " .. tostring(result))
        test.result = false
        
        self.results.failed = self.results.failed + 1
        self.results.categories[category].failed = self.results.categories[category].failed + 1
        
        self.results.testResults[category .. ":" .. name] = {
            result = false,
            error = tostring(result)
        }
    else
        test.result = result.success
        
        if result.success then
            self:Log("success", "Execution", "Test passed: " .. category .. " - " .. name)
            self.results.passed = self.results.passed + 1
            self.results.categories[category].passed = self.results.categories[category].passed + 1
        else
            self:Log("error", "Execution", "Test failed: " .. category .. " - " .. name .. " - " .. (result.message or "No error message"))
            self.results.failed = self.results.failed + 1
            self.results.categories[category].failed = self.results.categories[category].failed + 1
        end
        
        self.results.testResults[category .. ":" .. name] = result
    end
    
    return test.result
end

-- Run all tests in a category
function VS:RunCategory(category)
    if not self.tests[category] then
        self:Log("error", "Execution", "Category not found: " .. category)
        return false
    end
    
    self:Log("info", "Execution", "Running all tests in category: " .. category)
    
    local allPassed = true
    for name, _ in pairs(self.tests[category]) do
        -- Count tests
        self.results.total = self.results.total + 1
        self.results.categories[category].total = self.results.categories[category].total + 1
        
        -- Run the test
        local result = self:RunTest(category, name)
        if not result then
            allPassed = false
        end
    end
    
    return allPassed
end

-- Run all tests
function VS:RunAll()
    self:InitResults()
    
    self:Log("info", "Execution", "Running all tests")
    
    local allPassed = true
    for category, _ in pairs(self.tests) do
        local categoryResult = self:RunCategory(category)
        if not categoryResult then
            allPassed = false
        end
    end
    
    -- Record end time
    self.results.endTime = time()
    self.results.totalTime = self.results.endTime - self.results.startTime
    
    -- Generate report
    if self.options.generateReport then
        self:GenerateReport()
    end
    
    return allPassed
end

-- Generate a test report
function VS:GenerateReport()
    local report = {
        "=== VUI Validation Suite Report ===",
        "Run Date: " .. date("%Y-%m-%d %H:%M:%S", self.results.startTime),
        "Total Time: " .. self.results.totalTime .. " seconds",
        "",
        "--- Summary ---",
        "Total Tests: " .. self.results.total,
        "Passed: " .. self.results.passed .. " (" .. math.floor(self.results.passed / self.results.total * 100) .. "%)",
        "Failed: " .. self.results.failed .. " (" .. math.floor(self.results.failed / self.results.total * 100) .. "%)",
        "Skipped: " .. self.results.skipped .. " (" .. math.floor(self.results.skipped / self.results.total * 100) .. "%)",
        "",
        "--- Category Details ---"
    }
    
    -- Add category details
    for category, data in pairs(self.results.categories) do
        if data.total > 0 then
            table.insert(report, category .. ": " .. data.passed .. "/" .. data.total .. " passed (" .. 
                math.floor(data.passed / data.total * 100) .. "%), " .. 
                data.failed .. " failed, " .. data.skipped .. " skipped")
        end
    end
    
    table.insert(report, "")
    table.insert(report, "--- Failed Tests ---")
    
    -- Add details of failed tests
    local failedCount = 0
    for testName, result in pairs(self.results.testResults) do
        if not result.result and not result.skipped then
            failedCount = failedCount + 1
            table.insert(report, testName .. ": " .. (result.message or result.error or "No error message"))
        end
    end
    
    if failedCount == 0 then
        table.insert(report, "No failed tests!")
    end
    
    -- Save report to variable
    self.report = table.concat(report, "\n")
    
    -- Print summary
    self:Log("info", "Report", "Test Summary: " .. self.results.passed .. "/" .. self.results.total .. " tests passed")
    
    -- Save report to file
    if VUI_TestReport then
        VUI_TestReport = self.report
    end
    
    return self.report
end

-- Register standard test modules
function VS:RegisterStandardTests()
    -- Module Integration Tests
    self:RegisterModuleIntegrationTests()
    
    -- Performance Tests
    self:RegisterPerformanceTests()
    
    -- Error Handling Tests
    self:RegisterErrorHandlingTests()
    
    -- Compatibility Tests
    self:RegisterCompatibilityTests()
    
    -- Stress Tests
    self:RegisterStressTests()
end

-- Register module integration tests
function VS:RegisterModuleIntegrationTests()
    -- Test core module registration
    self:RegisterTest("module_integration", "core_module_registry", function()
        local moduleCount = 0
        local missingModules = {}
        local moduleList = {}
        
        -- Check if VUI.modules exists
        if not VUI.modules then
            return { success = false, message = "VUI.modules table not found" }
        end
        
        -- Count modules and gather names
        for name, module in pairs(VUI.modules) do
            moduleCount = moduleCount + 1
            table.insert(moduleList, name)
            
            -- Check if module has required methods
            for _, methodName in ipairs({"Initialize", "Enable", "Disable", "ApplyTheme"}) do
                if not module[methodName] or type(module[methodName]) ~= "function" then
                    table.insert(missingModules, name .. ":" .. methodName)
                end
            end
        end
        
        -- Report findings
        if #missingModules > 0 then
            return { 
                success = false, 
                message = "Modules missing required methods: " .. table.concat(missingModules, ", "),
                moduleCount = moduleCount,
                moduleList = moduleList
            }
        end
        
        return { 
            success = true, 
            message = "All " .. moduleCount .. " modules have required methods",
            moduleCount = moduleCount,
            moduleList = moduleList
        }
    end)
    
    -- Test theme integration across modules
    self:RegisterTest("module_integration", "theme_integration", function()
        local result = { success = true, message = "", issues = {} }
        
        -- Check if theme system exists
        if not VUI.theme then
            return { success = false, message = "VUI.theme not found" }
        end
        
        -- Check each module's theme integration
        for name, module in pairs(VUI.modules) do
            if module.ApplyTheme and type(module.ApplyTheme) == "function" then
                -- Make sure it accepts a theme parameter
                local info = debug.getinfo(module.ApplyTheme)
                if info.nparams < 1 then
                    table.insert(result.issues, name .. ": ApplyTheme method does not accept theme parameter")
                    result.success = false
                end
                
                -- Test with current theme
                local success, error = pcall(function() module:ApplyTheme(VUI.theme.current) end)
                if not success then
                    table.insert(result.issues, name .. ": ApplyTheme failed with error: " .. tostring(error))
                    result.success = false
                end
            else
                table.insert(result.issues, name .. ": Missing ApplyTheme method")
                result.success = false
            end
        end
        
        if not result.success then
            result.message = #result.issues .. " modules have theme integration issues"
        else
            result.message = "All modules have proper theme integration"
        end
        
        return result
    end)
    
    -- Test module dependencies
    self:RegisterTest("module_integration", "module_dependencies", function()
        local result = { success = true, message = "", issues = {} }
        
        -- Check if module manager exists
        if not VUI.ModuleManager then
            return { success = false, message = "VUI.ModuleManager not found" }
        end
        
        -- Check each module's dependencies
        for name, module in pairs(VUI.modules) do
            if module.dependencies then
                for _, dep in ipairs(module.dependencies) do
                    if not VUI.modules[dep] then
                        table.insert(result.issues, name .. ": Required dependency not found: " .. dep)
                        result.success = false
                    end
                end
            end
        end
        
        if not result.success then
            result.message = #result.issues .. " modules have dependency issues"
        else
            result.message = "All module dependencies are satisfied"
        end
        
        return result
    end)
    
    -- Test profile system integration
    self:RegisterTest("module_integration", "profile_integration", function()
        local result = { success = true, message = "", issues = {} }
        
        -- Check if profile system exists
        if not VUI.db or not VUI.db.profiles then
            return { success = false, message = "VUI.db.profiles not found" }
        end
        
        -- Check each module's profile integration
        for name, module in pairs(VUI.modules) do
            local moduleDB = VUI.db.profile[name:lower()]
            if not moduleDB and name ~= "Core" then
                table.insert(result.issues, name .. ": Missing database entry in profile")
                result.success = false
            end
        end
        
        if not result.success then
            result.message = #result.issues .. " modules have profile integration issues"
        else
            result.message = "All modules have proper profile integration"
        end
        
        return result
    end)
end

-- Register performance tests
function VS:RegisterPerformanceTests()
    -- Test texture atlas optimization
    self:RegisterTest("performance", "texture_atlas", function()
        local result = { success = true, message = "", metrics = {} }
        
        -- Check if texture atlas system exists
        if not VUI.Atlas then
            return { success = false, message = "VUI.Atlas not found" }
        end
        
        -- Check atlas functionality
        local atlasLoaded = VUI.Atlas:IsLoaded()
        if not atlasLoaded then
            return { success = false, message = "Atlas not loaded" }
        end
        
        -- Get texture metrics if available
        if VUI.Atlas.GetMetrics and type(VUI.Atlas.GetMetrics) == "function" then
            result.metrics = VUI.Atlas:GetMetrics()
            result.message = "Texture atlas system operational with " .. 
                (result.metrics.textureCount or "unknown") .. " textures"
        else
            result.message = "Texture atlas system operational, but metrics unavailable"
        end
        
        return result
    end)
    
    -- Test frame pooling system
    self:RegisterTest("performance", "frame_pooling", function()
        local result = { success = true, message = "", metrics = {} }
        
        -- Modules that should have frame pooling
        local modulesWithPools = {
            "BuffOverlay",
            "MultiNotification",
            "TrufiGCD",
            "OmniCD"
        }
        
        local poolCount = 0
        local missingPools = {}
        
        for _, name in ipairs(modulesWithPools) do
            local module = VUI.modules[name]
            if module then
                if module.frames and module.frames.pool then
                    poolCount = poolCount + 1
                else
                    table.insert(missingPools, name)
                    result.success = false
                end
            end
        end
        
        if not result.success then
            result.message = "Frame pooling missing in modules: " .. table.concat(missingPools, ", ")
        else
            result.message = "Frame pooling implemented in all required modules"
        end
        
        result.metrics = {
            poolCount = poolCount,
            expectedCount = #modulesWithPools
        }
        
        return result
    end)
    
    -- Test database optimization
    self:RegisterTest("performance", "database_optimization", function()
        local result = { success = true, message = "", metrics = {} }
        
        -- Check if database optimization exists
        if not VUI.db_optimizer then
            return { success = false, message = "VUI.db_optimizer not found" }
        end
        
        -- Check optimization status
        if VUI.db_optimizer.GetStatus and type(VUI.db_optimizer.GetStatus) == "function" then
            local status = VUI.db_optimizer:GetStatus()
            result.metrics = status
            result.message = "Database optimization operational with cache hit rate: " .. 
                (status.cacheHitRate and math.floor(status.cacheHitRate * 100) .. "%" or "unknown")
        else
            result.message = "Database optimization operational, but metrics unavailable"
        end
        
        return result
    end)
    
    -- Test resource cleanup system
    self:RegisterTest("performance", "resource_cleanup", function()
        local result = { success = true, message = "", metrics = {} }
        
        -- Check if resource cleanup exists
        if not VUI.resource_cleanup then
            return { success = false, message = "VUI.resource_cleanup not found" }
        end
        
        -- Check cleanup functionality
        if VUI.resource_cleanup.GetStatus and type(VUI.resource_cleanup.GetStatus) == "function" then
            local status = VUI.resource_cleanup:GetStatus()
            result.metrics = status
            
            if status.lastCleanup then
                result.message = "Resource cleanup system operational, last cleanup: " .. 
                    (status.lastCleanup and date("%Y-%m-%d %H:%M:%S", status.lastCleanup) or "never")
            else
                result.message = "Resource cleanup system operational"
            end
        else
            result.message = "Resource cleanup system operational, but metrics unavailable"
        end
        
        return result
    end)
end

-- Register error handling tests
function VS:RegisterErrorHandlingTests()
    -- Test general error handling
    self:RegisterTest("error_handling", "error_capture", function()
        local result = { success = true, message = "" }
        
        -- Check if error handling exists
        if not VUI.error_capture or not VUI.error_capture.CaptureError then
            return { success = false, message = "VUI.error_capture.CaptureError not found" }
        end
        
        -- Test error handling with a simulated error
        local success, response = pcall(function()
            return VUI.error_capture:CaptureError(
                "Test error", 
                "validation_suite.lua", 
                123,
                "test_error_handling"
            )
        end)
        
        if not success then
            result.success = false
            result.message = "Error capture system failed: " .. tostring(response)
        else
            result.message = "Error capture system operational"
        end
        
        return result
    end)
    
    -- Test module error recovery
    self:RegisterTest("error_handling", "module_error_recovery", function()
        local result = { success = true, message = "", recoveryModules = {} }
        
        -- Count modules with error recovery
        for name, module in pairs(VUI.modules) do
            if module.OnError and type(module.OnError) == "function" then
                table.insert(result.recoveryModules, name)
            end
        end
        
        if #result.recoveryModules == 0 then
            result.success = false
            result.message = "No modules implement error recovery"
        else
            result.message = #result.recoveryModules .. " modules implement error recovery"
        end
        
        return result
    end)
end

-- Register compatibility tests
function VS:RegisterCompatibilityTests()
    -- Test Blizzard API compatibility
    self:RegisterTest("compatibility", "blizzard_api", function()
        local result = { success = true, message = "", testedAPIs = {} }
        
        -- List of critical Blizzard APIs used by VUI
        local criticalAPIs = {
            "CreateFrame",
            "GetAddOnMetadata",
            "IsAddOnLoaded",
            "GetCVar",
            "GetSpellInfo",
            "UnitClass",
            "UnitName",
            "GetRealmName"
        }
        
        -- Test each API
        for _, api in ipairs(criticalAPIs) do
            if not _G[api] then
                result.success = false
                table.insert(result.testedAPIs, { api = api, available = false })
            else
                table.insert(result.testedAPIs, { api = api, available = true })
            end
        end
        
        if not result.success then
            result.message = "Missing critical Blizzard APIs"
        else
            result.message = "All critical Blizzard APIs available"
        end
        
        return result
    end)
    
    -- Test library dependencies
    self:RegisterTest("compatibility", "library_dependencies", function()
        local result = { success = true, message = "", libraries = {} }
        
        -- List of required libraries
        local requiredLibraries = {
            "LibStub",
            "AceAddon-3.0",
            "AceConfig-3.0",
            "AceConsole-3.0",
            "AceDB-3.0",
            "AceEvent-3.0",
            "AceGUI-3.0",
            "AceHook-3.0",
            "AceLocale-3.0",
            "AceSerializer-3.0",
            "AceTimer-3.0",
            "CallbackHandler-1.0",
            "LibDeflate"
        }
        
        -- Test each library
        for _, lib in ipairs(requiredLibraries) do
            local available = false
            
            if lib == "LibStub" then
                available = LibStub ~= nil
            else
                available = LibStub and LibStub:GetLibrary(lib, true) ~= nil
            end
            
            if not available then
                result.success = false
                table.insert(result.libraries, { name = lib, available = false })
            else
                table.insert(result.libraries, { name = lib, available = true })
            end
        end
        
        -- Test internal library usage
        if result.success then
            -- Check if VUI is using AceDB properly
            if not VUI.db or type(VUI.db) ~= "table" or not VUI.db.profile then
                result.success = false
                result.message = "VUI is not properly using AceDB"
            end
        end
        
        if not result.success then
            result.message = "Missing required libraries"
        else
            result.message = "All required libraries available"
        end
        
        return result
    end)
end

-- Register stress tests
function VS:RegisterStressTests()
    -- Test rapid theme switching
    self:RegisterTest("stress_test", "rapid_theme_switching", function()
        local result = { success = true, message = "", metrics = {} }
        
        -- Check if theme system exists
        if not VUI.theme or not VUI.theme.SetTheme then
            return { success = false, message = "VUI.theme.SetTheme not found" }
        end
        
        -- Get available themes
        local availableThemes = {}
        if VUI.theme.themes then
            for name, _ in pairs(VUI.theme.themes) do
                table.insert(availableThemes, name)
            end
        end
        
        if #availableThemes < 2 then
            return { success = false, message = "Not enough themes available for testing" }
        end
        
        -- Save current theme
        local currentTheme = VUI.theme.current and VUI.theme.current.name or nil
        
        -- Test rapid theme switching
        local switchCount = math.min(5, #availableThemes)
        local startTime = debugprofilestop()
        local errors = {}
        
        for i = 1, switchCount do
            local themeName = availableThemes[i]
            local success, error = pcall(function() VUI.theme:SetTheme(themeName) end)
            
            if not success then
                table.insert(errors, "Theme " .. themeName .. ": " .. tostring(error))
                result.success = false
            end
        end
        
        local totalTime = debugprofilestop() - startTime
        result.metrics.avgSwitchTime = totalTime / switchCount
        
        -- Restore original theme
        if currentTheme then
            pcall(function() VUI.theme:SetTheme(currentTheme) end)
        end
        
        if not result.success then
            result.message = "Theme switching errors: " .. table.concat(errors, ", ")
        else
            result.message = "Successfully switched between " .. switchCount .. 
                " themes. Average switch time: " .. string.format("%.2f", result.metrics.avgSwitchTime) .. " ms"
        end
        
        return result
    end)
    
    -- Test configuration panel stress
    self:RegisterTest("stress_test", "config_panel_stress", function()
        local result = { success = true, message = "", metrics = {} }
        
        -- Check if configuration panel exists
        if not VUI.config_panel or not VUI.config_panel.Show then
            return { success = false, message = "VUI.config_panel.Show not found" }
        end
        
        -- Test opening and closing the panel multiple times
        local iterationCount = 5
        local startTime = debugprofilestop()
        local errors = {}
        
        for i = 1, iterationCount do
            local success, error = pcall(function() 
                VUI.config_panel:Show()
                VUI.config_panel:Hide()
            end)
            
            if not success then
                table.insert(errors, "Iteration " .. i .. ": " .. tostring(error))
                result.success = false
            end
        end
        
        local totalTime = debugprofilestop() - startTime
        result.metrics.avgOperationTime = totalTime / iterationCount
        
        if not result.success then
            result.message = "Config panel errors: " .. table.concat(errors, ", ")
        else
            result.message = "Successfully opened/closed config panel " .. iterationCount .. 
                " times. Average operation time: " .. string.format("%.2f", result.metrics.avgOperationTime) .. " ms"
        end
        
        return result
    end)
end

-- Register with slash command handler
if VUI.RegisterSlashCommand then
    VUI:RegisterSlashCommand("validate", function(input)
        -- Parse options
        local category = nil
        if input and input ~= "" then
            category = input
        end
        
        -- Register standard tests
        VS:RegisterStandardTests()
        
        -- Run validation
        if category and VS.tests[category] then
            VS:InitResults()
            VS:RunCategory(category)
        else
            VS:RunAll()
        end
    end, "Run validation tests. Use 'validate [category]' to run specific test categories.")
end

-- Return the validation suite
return VS