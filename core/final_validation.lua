-- VUI Final Validation System
-- Comprehensive validation and testing for VUI v1.0.0 release
local addonName, VUI = ...

-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the Final Validation namespace
VUI.FinalValidation = {
    version = "1.0.0",
    author = "VUI Team",
    isRunning = false,
    isComplete = false,
    results = {},
    options = {
        autoRunOnLoad = false, -- Set to true to automatically run validation on load
        generateReport = true,
        fullTesting = false, -- Set to true for more comprehensive tests (may impact performance)
        testCategories = {
            "module_integration",
            "performance",
            "error_handling",
            "compatibility",
            "stress"
        }
    }
}

-- Final Validation reference
local FV = VUI.FinalValidation

-- Initialize the Final Validation system
function FV:Initialize()
    self:Log("info", "System", "Final Validation system initialized")
    
    -- Load required testing modules
    self:LoadTestModules()
    
    -- Register slash command
    if VUI.RegisterSlashCommand then
        VUI:RegisterSlashCommand("validate", function(input)
            if input and input:match("full") then
                self.options.fullTesting = true
            end
            
            self:RunValidation()
        end, "Run final validation tests. Use 'validate full' for comprehensive tests.")
    end
    
    -- Auto-run on load if enabled
    if self.options.autoRunOnLoad then
        C_Timer.After(5, function()
            self:RunValidation()
        end)
    end
    
    return true
end

-- Log a message with color
function FV:Log(level, category, message)
    local colors = {
        info = "ffffff",
        success = "00ff00",
        warning = "ffff00",
        error = "ff0000"
    }
    
    local prefix = "[FV:" .. category .. "] "
    local coloredMessage = "|cff" .. (colors[level] or "ffffff") .. prefix .. message .. "|r"
    
    if VUI.Print then
        VUI:Print(coloredMessage)
    else
        print(coloredMessage)
    end
    
    return coloredMessage
end

-- Load required testing modules
function FV:LoadTestModules()
    -- Check if test runner is available
    if not VUI.TestRunner then
        self:Log("warning", "System", "TestRunner not found, final validation will be limited")
    end
    
    -- Check if validation suite is available
    if not VUI.ValidationSuite then
        self:Log("warning", "System", "ValidationSuite not found, module integration tests will be skipped")
    end
    
    -- Check if performance benchmarks are available
    if not VUI.PerformanceBenchmarks then
        self:Log("warning", "System", "PerformanceBenchmarks not found, performance tests will be skipped")
    end
    
    -- Check if module verifier is available
    if not VUI.ModuleVerifier then
        self:Log("warning", "System", "ModuleVerifier not found, module verification will be skipped")
    end
    
    -- Check if error testing is available
    if not VUI.ErrorTesting then
        self:Log("warning", "System", "ErrorTesting not found, error handling tests will be skipped")
    end
    
    -- Check if compatibility tester is available
    if not VUI.CompatibilityTester then
        self:Log("warning", "System", "CompatibilityTester not found, compatibility tests will be skipped")
    end
    
    return true
end

-- Run the validation process
function FV:RunValidation()
    -- Check if validation is already running
    if self.isRunning then
        self:Log("warning", "System", "Validation is already running")
        return false
    end
    
    -- Check if validation is already complete
    if self.isComplete and not self.options.fullTesting then
        self:Log("warning", "System", "Validation already complete. Use '/validate full' to run again.")
        return false
    end
    
    -- Mark as running
    self.isRunning = true
    
    -- Start time
    self.startTime = time()
    
    -- Initialize results
    self.results = {
        startTime = self.startTime,
        endTime = nil,
        totalTime = nil,
        validationResults = nil,
        benchmarkResults = nil,
        verificationResults = nil,
        errorTestResults = nil,
        compatibilityResults = nil,
        overallStatus = "INCOMPLETE"
    }
    
    -- Log start
    self:Log("info", "System", "Starting final validation (v" .. self.version .. ")")
    
    -- Use TestRunner if available
    if VUI.TestRunner then
        self:Log("info", "System", "Using integrated TestRunner")
        
        -- Run all tests
        local success = VUI.TestRunner:RunAll()
        
        -- Store results
        self.results.testRunnerResults = VUI.TestRunner.results
        
        -- Update overall status based on TestRunner results
        if success then
            self.results.overallStatus = "PASSED"
        else
            self.results.overallStatus = "FAILED"
        end
        
        -- Generate report
        if self.options.generateReport then
            self:GenerateReport()
        end
        
        -- Mark as complete
        self.isComplete = true
        self.isRunning = false
        
        -- Log completion
        self:Log("info", "System", "Final validation complete. Status: " .. self.results.overallStatus)
        
        return success
    else
        -- TestRunner not available, run individual components
        self:Log("info", "System", "TestRunner not available, running individual test components")
        
        -- Start individual tests asynchronously
        self:RunIndividualTests()
        
        return true
    end
end

-- Run individual test components asynchronously
function FV:RunIndividualTests()
    local testsCompleted = 0
    local totalTests = 0
    
    -- Check which test components are available
    if VUI.ValidationSuite then totalTests = totalTests + 1 end
    if VUI.PerformanceBenchmarks then totalTests = totalTests + 1 end
    if VUI.ModuleVerifier then totalTests = totalTests + 1 end
    if VUI.ErrorTesting then totalTests = totalTests + 1 end
    if VUI.CompatibilityTester then totalTests = totalTests + 1 end
    
    -- Function to check if all tests are complete
    local function checkCompletion()
        testsCompleted = testsCompleted + 1
        
        if testsCompleted >= totalTests then
            -- All tests complete
            self:FinalizeResults()
        end
    end
    
    -- Run validation suite
    if VUI.ValidationSuite then
        self:Log("info", "System", "Running validation suite")
        
        -- Register tests
        VUI.ValidationSuite:RegisterStandardTests()
        
        -- Run async
        C_Timer.After(0.5, function()
            VUI.ValidationSuite:RunAll()
            self.results.validationResults = VUI.ValidationSuite.results
            self:Log("info", "System", "Validation suite complete")
            checkCompletion()
        end)
    end
    
    -- Run performance benchmarks
    if VUI.PerformanceBenchmarks then
        self:Log("info", "System", "Running performance benchmarks")
        
        -- Register benchmarks
        VUI.PerformanceBenchmarks:RegisterStandardBenchmarks()
        
        -- Run async (after validation suite)
        C_Timer.After(1.5, function()
            VUI.PerformanceBenchmarks:RunAll()
            self.results.benchmarkResults = VUI.PerformanceBenchmarks.results
            self:Log("info", "System", "Performance benchmarks complete")
            checkCompletion()
        end)
    end
    
    -- Run module verifier
    if VUI.ModuleVerifier then
        self:Log("info", "System", "Running module verifier")
        
        -- Run async (after performance benchmarks)
        C_Timer.After(2.5, function()
            VUI.ModuleVerifier:Run(false) -- No auto-fix
            self.results.verificationResults = VUI.ModuleVerifier.results
            self:Log("info", "System", "Module verification complete")
            checkCompletion()
        end)
    end
    
    -- Run error testing
    if VUI.ErrorTesting then
        self:Log("info", "System", "Running error testing")
        
        -- Register tests
        VUI.ErrorTesting:RegisterStandardTests()
        
        -- Run async (after module verifier)
        C_Timer.After(3.5, function()
            VUI.ErrorTesting:RunAll()
            self.results.errorTestResults = VUI.ErrorTesting.results
            self:Log("info", "System", "Error testing complete")
            checkCompletion()
        end)
    end
    
    -- Run compatibility tester
    if VUI.CompatibilityTester then
        self:Log("info", "System", "Running compatibility tester")
        
        -- Register tests
        VUI.CompatibilityTester:RegisterStandardTests()
        
        -- Run async (last)
        C_Timer.After(4.5, function()
            VUI.CompatibilityTester:RunAll()
            self.results.compatibilityResults = VUI.CompatibilityTester.results
            self:Log("info", "System", "Compatibility testing complete")
            checkCompletion()
        end)
    end
    
    -- If no tests were run
    if totalTests == 0 then
        self:Log("error", "System", "No test components available")
        self.results.overallStatus = "INCOMPLETE"
        self.isComplete = true
        self.isRunning = false
    end
end

-- Finalize the results after all individual tests complete
function FV:FinalizeResults()
    -- Record end time
    self.results.endTime = time()
    self.results.totalTime = self.results.endTime - self.results.startTime
    
    -- Determine overall status
    local passedTests = 0
    local totalTests = 0
    
    -- Check validation results
    if self.results.validationResults then
        totalTests = totalTests + 1
        if self.results.validationResults.failed == 0 then
            passedTests = passedTests + 1
        end
    end
    
    -- Check verification results
    if self.results.verificationResults then
        totalTests = totalTests + 1
        if self.results.verificationResults.modulesFailed == 0 then
            passedTests = passedTests + 1
        end
    end
    
    -- Check error test results
    if self.results.errorTestResults then
        totalTests = totalTests + 1
        if self.results.errorTestResults.failed == 0 then
            passedTests = passedTests + 1
        end
    end
    
    -- Check compatibility results
    if self.results.compatibilityResults then
        totalTests = totalTests + 1
        if self.results.compatibilityResults.failed == 0 then
            passedTests = passedTests + 1
        end
    end
    
    -- Set overall status
    if totalTests == 0 then
        self.results.overallStatus = "INCOMPLETE"
    elseif passedTests == totalTests then
        self.results.overallStatus = "PASSED"
    else
        self.results.overallStatus = "FAILED"
    end
    
    -- Generate report
    if self.options.generateReport then
        self:GenerateReport()
    end
    
    -- Mark as complete
    self.isComplete = true
    self.isRunning = false
    
    -- Log completion
    self:Log("info", "System", "Final validation complete. Status: " .. self.results.overallStatus)
    
    return self.results.overallStatus == "PASSED"
end

-- Generate a comprehensive validation report
function FV:GenerateReport()
    local report = {
        "# VUI Final Validation Report",
        "",
        "## Summary",
        "- Version: " .. VUI.version,
        "- Validation Date: " .. date("%Y-%m-%d %H:%M:%S", self.results.startTime),
        "- Total Validation Time: " .. (self.results.totalTime or 0) .. " seconds",
        "- Overall Status: " .. self.results.overallStatus,
        ""
    }
    
    -- Add section for validation suite results
    if self.results.validationResults then
        table.insert(report, "## Module Integration Tests")
        table.insert(report, "- Total Tests: " .. self.results.validationResults.total)
        table.insert(report, "- Passed: " .. self.results.validationResults.passed .. 
            " (" .. math.floor(self.results.validationResults.passed / self.results.validationResults.total * 100) .. "%)")
        table.insert(report, "- Failed: " .. self.results.validationResults.failed .. 
            " (" .. math.floor(self.results.validationResults.failed / self.results.validationResults.total * 100) .. "%)")
        table.insert(report, "- Skipped: " .. self.results.validationResults.skipped .. 
            " (" .. math.floor(self.results.validationResults.skipped / self.results.validationResults.total * 100) .. "%)")
        
        -- Add details of failed tests
        if self.results.validationResults.failed > 0 then
            table.insert(report, "")
            table.insert(report, "### Failed Integration Tests:")
            for testName, result in pairs(self.results.validationResults.testResults) do
                if not result.result and not result.skipped then
                    table.insert(report, "- " .. testName .. ": " .. (result.message or "No error message"))
                end
            end
        end
        
        table.insert(report, "")
    end
    
    -- Add section for performance benchmark results
    if self.results.benchmarkResults then
        table.insert(report, "## Performance Benchmarks")
        
        -- Add memory usage information
        table.insert(report, "- Memory Usage: " .. 
            string.format("%.2f", self.results.benchmarkResults.memoryBefore) .. "KB -> " .. 
            string.format("%.2f", self.results.benchmarkResults.memoryAfter) .. "KB (" .. 
            string.format("%+.2f", self.results.benchmarkResults.memoryChange) .. "KB)")
        
        -- Add benchmark categories
        for category, data in pairs(self.results.benchmarkResults.categories) do
            if data.benchmarks > 0 then
                table.insert(report, "")
                table.insert(report, "### " .. category:gsub("^%l", string.upper) .. " Benchmarks")
                table.insert(report, "- Benchmarks: " .. data.benchmarks)
                table.insert(report, "- Average Time: " .. string.format("%.2f", data.avgTime) .. "ms")
                
                -- Add key metrics for important categories
                if category == "memory" or category == "cpu" or category == "framerate" then
                    table.insert(report, "")
                    table.insert(report, "#### Key Metrics:")
                    
                    -- Find benchmarks for this category
                    local maxMetrics = 5 -- Limit the number of metrics shown
                    local metricCount = 0
                    
                    for id, result in pairs(self.results.benchmarkResults.benchmarkResults) do
                        if id:match("^" .. category) and metricCount < maxMetrics then
                            metricCount = metricCount + 1
                            table.insert(report, "- " .. result.name .. ": " .. 
                                string.format("%.2f", result.avgTime) .. "ms avg, " .. 
                                string.format("%.2f", result.minTime) .. "ms min, " .. 
                                string.format("%.2f", result.maxTime) .. "ms max")
                        end
                    end
                end
            end
        end
        
        table.insert(report, "")
    end
    
    -- Add section for module verification results
    if self.results.verificationResults then
        table.insert(report, "## Module Verification")
        table.insert(report, "- Total Modules: " .. self.results.verificationResults.total)
        table.insert(report, "- Passed: " .. self.results.verificationResults.modulesPassed .. 
            " (" .. math.floor(self.results.verificationResults.modulesPassed / self.results.verificationResults.total * 100) .. "%)")
        table.insert(report, "- Failed: " .. self.results.verificationResults.modulesFailed .. 
            " (" .. math.floor(self.results.verificationResults.modulesFailed / self.results.verificationResults.total * 100) .. "%)")
        table.insert(report, "- Total Errors: " .. self.results.verificationResults.errors)
        table.insert(report, "- Total Warnings: " .. self.results.verificationResults.warnings)
        table.insert(report, "- Fixable Issues: " .. self.results.verificationResults.fixableIssues)
        
        -- Add details of problematic modules
        if self.results.verificationResults.modulesFailed > 0 then
            table.insert(report, "")
            table.insert(report, "### Problematic Modules:")
            
            -- Sort modules by error count
            local sortedModules = {}
            for name, data in pairs(self.results.verificationResults.modules) do
                if data.errors > 0 or data.warnings > 0 then
                    table.insert(sortedModules, {name = name, data = data})
                end
            end
            
            table.sort(sortedModules, function(a, b)
                if a.data.errors == b.data.errors then
                    return a.data.warnings > b.data.warnings
                else
                    return a.data.errors > b.data.errors
                end
            end)
            
            -- Add top 5 problematic modules
            local maxModules = 5
            for i, module in ipairs(sortedModules) do
                if i <= maxModules then
                    table.insert(report, "- " .. module.name .. ": " .. 
                        module.data.errors .. " errors, " .. 
                        module.data.warnings .. " warnings")
                end
            end
            
            if #sortedModules > maxModules then
                table.insert(report, "- ...and " .. (#sortedModules - maxModules) .. " more")
            end
        end
        
        table.insert(report, "")
    end
    
    -- Add section for error testing results
    if self.results.errorTestResults then
        table.insert(report, "## Error Handling Tests")
        table.insert(report, "- Total Tests: " .. self.results.errorTestResults.total)
        table.insert(report, "- Passed: " .. self.results.errorTestResults.passed .. 
            " (" .. math.floor(self.results.errorTestResults.passed / self.results.errorTestResults.total * 100) .. "%)")
        table.insert(report, "- Failed: " .. self.results.errorTestResults.failed .. 
            " (" .. math.floor(self.results.errorTestResults.failed / self.results.errorTestResults.total * 100) .. "%)")
        
        -- Add details of categories
        if self.results.errorTestResults.total > 0 then
            table.insert(report, "")
            table.insert(report, "### Error Test Categories:")
            
            for _, category in ipairs({"capture", "recovery", "resilience"}) do
                local data = self.results.errorTestResults[category]
                if data and data.total > 0 then
                    table.insert(report, "- " .. category:gsub("^%l", string.upper) .. ": " .. 
                        data.passed .. "/" .. data.total .. " passed (" .. 
                        math.floor(data.passed / data.total * 100) .. "%)")
                end
            end
        end
        
        table.insert(report, "")
    end
    
    -- Add section for compatibility testing results
    if self.results.compatibilityResults then
        table.insert(report, "## Compatibility Tests")
        table.insert(report, "- Total Tests: " .. self.results.compatibilityResults.total)
        table.insert(report, "- Passed: " .. self.results.compatibilityResults.passed .. 
            " (" .. math.floor(self.results.compatibilityResults.passed / self.results.compatibilityResults.total * 100) .. "%)")
        table.insert(report, "- Failed: " .. self.results.compatibilityResults.failed .. 
            " (" .. math.floor(self.results.compatibilityResults.failed / self.results.compatibilityResults.total * 100) .. "%)")
        table.insert(report, "- Warnings: " .. self.results.compatibilityResults.warnings .. 
            " (" .. math.floor(self.results.compatibilityResults.warnings / self.results.compatibilityResults.total * 100) .. "%)")
        
        -- Add WoW version information
        if self.results.compatibilityResults.buildInfo then
            table.insert(report, "")
            table.insert(report, "### WoW Client Information:")
            table.insert(report, "- Version: " .. self.results.compatibilityResults.buildInfo.version)
            table.insert(report, "- Build: " .. self.results.compatibilityResults.buildInfo.build)
            table.insert(report, "- Interface: " .. self.results.compatibilityResults.buildInfo.interface)
            table.insert(report, "- Locale: " .. self.results.compatibilityResults.buildInfo.locale)
        end
        
        -- Add details of categories
        if self.results.compatibilityResults.total > 0 then
            table.insert(report, "")
            table.insert(report, "### Compatibility Test Categories:")
            
            for _, category in ipairs({"api", "addons", "libraries", "ui"}) do
                local data = self.results.compatibilityResults[category]
                if data and data.total > 0 then
                    table.insert(report, "- " .. category:gsub("^%l", string.upper) .. ": " .. 
                        data.passed .. "/" .. data.total .. " passed (" .. 
                        math.floor(data.passed / data.total * 100) .. "%), " ..
                        data.warnings .. " warnings")
                end
            end
        end
        
        table.insert(report, "")
    end
    
    -- Add certification section
    table.insert(report, "## Certification")
    
    if self.results.overallStatus == "PASSED" then
        table.insert(report, "")
        table.insert(report, "**CERTIFICATION STATUS: PASSED**")
        table.insert(report, "")
        table.insert(report, "VUI v" .. VUI.version .. " has passed all tests and is certified for release.")
    elseif self.results.overallStatus == "INCOMPLETE" then
        table.insert(report, "")
        table.insert(report, "**CERTIFICATION STATUS: INCOMPLETE**")
        table.insert(report, "")
        table.insert(report, "VUI validation could not be completed due to missing test components.")
    else
        table.insert(report, "")
        table.insert(report, "**CERTIFICATION STATUS: NOT CERTIFIED**")
        table.insert(report, "")
        table.insert(report, "VUI requires additional fixes before release. See details above.")
    end
    
    -- Add final summary
    table.insert(report, "")
    table.insert(report, "## Final Summary")
    
    -- Add module validation status
    if self.results.validationResults then
        local validationPassed = self.results.validationResults.failed == 0
        table.insert(report, "- Module Integration Tests: " .. (validationPassed and "PASSED" or "FAILED"))
    else
        table.insert(report, "- Module Integration Tests: SKIPPED")
    end
    
    -- Add verification status
    if self.results.verificationResults then
        local verificationPassed = self.results.verificationResults.modulesFailed == 0
        table.insert(report, "- Module Verification: " .. (verificationPassed and "PASSED" or "FAILED"))
    else
        table.insert(report, "- Module Verification: SKIPPED")
    end
    
    -- Add error testing status
    if self.results.errorTestResults then
        local errorTestsPassed = self.results.errorTestResults.failed == 0
        table.insert(report, "- Error Handling Tests: " .. (errorTestsPassed and "PASSED" or "FAILED"))
    else
        table.insert(report, "- Error Handling Tests: SKIPPED")
    end
    
    -- Add compatibility status
    if self.results.compatibilityResults then
        local compatibilityPassed = self.results.compatibilityResults.failed == 0
        table.insert(report, "- Compatibility Tests: " .. (compatibilityPassed and "PASSED" or "FAILED"))
    else
        table.insert(report, "- Compatibility Tests: SKIPPED")
    end
    
    -- Add performance benchmark status
    if self.results.benchmarkResults then
        table.insert(report, "- Performance Benchmarks: Completed (see metrics above)")
    else
        table.insert(report, "- Performance Benchmarks: SKIPPED")
    end
    
    table.insert(report, "")
    table.insert(report, "Report Generated: " .. date("%Y-%m-%d %H:%M:%S"))
    
    -- Save report to variable
    self.report = table.concat(report, "\n")
    
    -- Save report to global for extraction
    _G.VUI_ValidationReport = self.report
    
    -- Try to write to the file
    if VUI.WriteFile then
        VUI:WriteFile("VUI_Validation_Test_Report.md", self.report)
    end
    
    -- Print report summary
    self:Log("info", "Report", "Validation report generated")
    
    return self.report
end

-- Return the Final Validation system
return FV