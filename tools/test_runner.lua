-- VUI Test Runner
-- Comprehensive testing and validation suite for VUI addon
local addonName, VUI = ...

-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the Test Runner namespace
VUI.TestRunner = {
    version = "1.0.0",
    author = "VUI Team",
    results = {},
    options = {
        verboseOutput = true,
        outputToChat = true,
        generateReport = true,
        autoRun = false,
        testCategories = {
            "validation",
            "benchmark",
            "verification",
            "stress"
        }
    }
}

-- Test Runner reference
local TR = VUI.TestRunner

-- Load required testing modules
local function LoadTestModules()
    -- Validation Suite
    if not VUI.ValidationSuite then
        if LibStub:GetLibrary("AceAddon-3.0") and LibStub:GetLibrary("AceAddon-3.0"):GetAddon(addonName, true) then
            local addon = LibStub:GetLibrary("AceAddon-3.0"):GetAddon(addonName)
            addon:LoadModule("ValidationSuite")
        end
    end
    
    -- Performance Benchmarks
    if not VUI.PerformanceBenchmarks then
        if LibStub:GetLibrary("AceAddon-3.0") and LibStub:GetLibrary("AceAddon-3.0"):GetAddon(addonName, true) then
            local addon = LibStub:GetLibrary("AceAddon-3.0"):GetAddon(addonName)
            addon:LoadModule("PerformanceBenchmarks")
        end
    end
    
    -- Module Verifier
    if not VUI.ModuleVerifier then
        if LibStub:GetLibrary("AceAddon-3.0") and LibStub:GetLibrary("AceAddon-3.0"):GetAddon(addonName, true) then
            local addon = LibStub:GetLibrary("AceAddon-3.0"):GetAddon(addonName)
            addon:LoadModule("ModuleVerifier")
        end
    end
end

-- Log a message with color
function TR:Log(level, category, message)
    if not self.options.verboseOutput and level == "info" then
        return
    end
    
    local colors = {
        info = "ffffff",
        success = "00ff00",
        warning = "ffff00",
        error = "ff0000"
    }
    
    local prefix = "[TR:" .. category .. "] "
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

-- Initialize the results table
function TR:InitResults()
    self.results = {
        startTime = time(),
        endTime = nil,
        totalTime = nil,
        validation = nil,
        benchmark = nil,
        verification = nil,
        stress = nil
    }
end

-- Run validation tests
function TR:RunValidation()
    self:Log("info", "Validation", "Running validation tests...")
    
    if not VUI.ValidationSuite then
        self:Log("error", "Validation", "ValidationSuite not found")
        return false
    end
    
    -- Register and run tests
    VUI.ValidationSuite:RegisterStandardTests()
    VUI.ValidationSuite:RunAll()
    
    -- Store results
    self.results.validation = VUI.ValidationSuite.results
    
    local passRate = 0
    if self.results.validation.total > 0 then
        passRate = math.floor(self.results.validation.passed / self.results.validation.total * 100)
    end
    
    self:Log("info", "Validation", "Validation complete. Pass rate: " .. passRate .. "%")
    
    return self.results.validation.failed == 0 and self.results.validation.skipped == 0
end

-- Run performance benchmarks
function TR:RunBenchmarks()
    self:Log("info", "Benchmark", "Running performance benchmarks...")
    
    if not VUI.PerformanceBenchmarks then
        self:Log("error", "Benchmark", "PerformanceBenchmarks not found")
        return false
    end
    
    -- Register and run benchmarks
    VUI.PerformanceBenchmarks:RegisterStandardBenchmarks()
    VUI.PerformanceBenchmarks:RunAll()
    
    -- Store results
    self.results.benchmark = VUI.PerformanceBenchmarks.results
    
    self:Log("info", "Benchmark", "Benchmarks complete")
    
    return true
end

-- Run module verification
function TR:RunVerification()
    self:Log("info", "Verification", "Running module verification...")
    
    if not VUI.ModuleVerifier then
        self:Log("error", "Verification", "ModuleVerifier not found")
        return false
    end
    
    -- Run verification
    VUI.ModuleVerifier:Run(false) -- No auto-fix
    
    -- Store results
    self.results.verification = VUI.ModuleVerifier.results
    
    local passRate = 0
    if self.results.verification.total > 0 then
        passRate = math.floor(self.results.verification.modulesPassed / self.results.verification.total * 100)
    end
    
    self:Log("info", "Verification", "Verification complete. Pass rate: " .. passRate .. "%")
    
    return self.results.verification.modulesFailed == 0
end

-- Run stress tests
function TR:RunStressTests()
    self:Log("info", "Stress", "Running stress tests...")
    
    -- These are typically part of the validation suite
    -- but we might have additional stress tests here
    if not VUI.ValidationSuite then
        self:Log("error", "Stress", "ValidationSuite not found")
        return false
    end
    
    -- Find and run stress tests
    local stressTests = {}
    for category, tests in pairs(VUI.ValidationSuite.tests) do
        if category == "stress_test" then
            for name, _ in pairs(tests) do
                table.insert(stressTests, name)
            end
        end
    end
    
    if #stressTests == 0 then
        self:Log("warning", "Stress", "No dedicated stress tests found")
        return true
    end
    
    -- Store results (subset of validation results)
    self.results.stress = {
        total = #stressTests,
        passed = 0,
        failed = 0,
        tests = {}
    }
    
    for _, name in ipairs(stressTests) do
        local result = VUI.ValidationSuite.results.testResults["stress_test:" .. name]
        if result then
            self.results.stress.tests[name] = result
            if result.success then
                self.results.stress.passed = self.results.stress.passed + 1
            else
                self.results.stress.failed = self.results.stress.failed + 1
            end
        end
    end
    
    local passRate = 0
    if self.results.stress.total > 0 then
        passRate = math.floor(self.results.stress.passed / self.results.stress.total * 100)
    end
    
    self:Log("info", "Stress", "Stress tests complete. Pass rate: " .. passRate .. "%")
    
    return self.results.stress.failed == 0
end

-- Run all tests
function TR:RunAll()
    self:InitResults()
    LoadTestModules()
    
    self:Log("info", "TestRunner", "Starting comprehensive testing and validation")
    
    -- Run all test categories
    local validationResult = self:RunValidation()
    local benchmarkResult = self:RunBenchmarks()
    local verificationResult = self:RunVerification()
    local stressResult = self:RunStressTests()
    
    -- Record end time
    self.results.endTime = time()
    self.results.totalTime = self.results.endTime - self.results.startTime
    
    -- Generate combined report
    if self.options.generateReport then
        self:GenerateReport()
    end
    
    -- Return overall status
    return validationResult and benchmarkResult and verificationResult and stressResult
end

-- Generate a comprehensive test report
function TR:GenerateReport()
    local report = {
        "# VUI Validation Test Report",
        "",
        "## Summary",
        "This report contains the results of final testing and validation for VUI v1.0.0 release.",
        "",
        "Run Date: " .. date("%Y-%m-%d %H:%M:%S", self.results.startTime),
        "Total Test Duration: " .. self.results.totalTime .. " seconds",
        "",
        "## Test Results"
    }
    
    -- Add validation results
    if self.results.validation then
        table.insert(report, "")
        table.insert(report, "### Module Integration Tests")
        table.insert(report, "- Total Tests: " .. self.results.validation.total)
        table.insert(report, "- Passed: " .. self.results.validation.passed .. 
            " (" .. math.floor(self.results.validation.passed / self.results.validation.total * 100) .. "%)")
        table.insert(report, "- Failed: " .. self.results.validation.failed .. 
            " (" .. math.floor(self.results.validation.failed / self.results.validation.total * 100) .. "%)")
        table.insert(report, "- Skipped: " .. self.results.validation.skipped .. 
            " (" .. math.floor(self.results.validation.skipped / self.results.validation.total * 100) .. "%)")
        
        if self.results.validation.failed > 0 then
            table.insert(report, "")
            table.insert(report, "#### Failed Tests:")
            for testName, result in pairs(self.results.validation.testResults) do
                if not result.result and not result.skipped then
                    table.insert(report, "- " .. testName .. ": " .. (result.message or "No error message"))
                end
            end
        end
    end
    
    -- Add stress test results
    if self.results.stress then
        table.insert(report, "")
        table.insert(report, "### Stress Tests")
        table.insert(report, "- Total Tests: " .. self.results.stress.total)
        table.insert(report, "- Passed: " .. self.results.stress.passed .. 
            " (" .. math.floor(self.results.stress.passed / self.results.stress.total * 100) .. "%)")
        table.insert(report, "- Failed: " .. self.results.stress.failed .. 
            " (" .. math.floor(self.results.stress.failed / self.results.stress.total * 100) .. "%)")
        
        if self.results.stress.failed > 0 then
            table.insert(report, "")
            table.insert(report, "#### Failed Stress Tests:")
            for name, result in pairs(self.results.stress.tests) do
                if not result.success then
                    table.insert(report, "- " .. name .. ": " .. (result.message or "No error message"))
                end
            end
        end
    end
    
    -- Add verification results
    if self.results.verification then
        table.insert(report, "")
        table.insert(report, "### Module Verification Tests")
        table.insert(report, "- Total Modules: " .. self.results.verification.total)
        table.insert(report, "- Passed: " .. self.results.verification.modulesPassed .. 
            " (" .. math.floor(self.results.verification.modulesPassed / self.results.verification.total * 100) .. "%)")
        table.insert(report, "- Failed: " .. self.results.verification.modulesFailed .. 
            " (" .. math.floor(self.results.verification.modulesFailed / self.results.verification.total * 100) .. "%)")
        table.insert(report, "- Total Errors: " .. self.results.verification.errors)
        table.insert(report, "- Total Warnings: " .. self.results.verification.warnings)
        table.insert(report, "- Fixable Issues: " .. self.results.verification.fixableIssues)
        
        if self.results.verification.modulesFailed > 0 then
            table.insert(report, "")
            table.insert(report, "#### Failed Modules:")
            for name, data in pairs(self.results.verification.modules) do
                if data.errors > 0 then
                    table.insert(report, "- " .. name .. ": " .. data.errors .. " errors, " .. data.warnings .. " warnings")
                end
            end
        end
    end
    
    -- Add benchmarking results
    if self.results.benchmark then
        table.insert(report, "")
        table.insert(report, "## Performance Benchmarks")
        table.insert(report, "")
        table.insert(report, "### Memory Performance")
        table.insert(report, "- Memory Usage: " .. string.format("%.2f", self.results.benchmark.memoryBefore) .. "KB -> " .. 
            string.format("%.2f", self.results.benchmark.memoryAfter) .. "KB (" .. 
            string.format("%+.2f", self.results.benchmark.memoryChange) .. "KB)")
        
        -- Add benchmark category summaries
        for category, data in pairs(self.results.benchmark.categories) do
            if data.benchmarks > 0 then
                table.insert(report, "")
                table.insert(report, "### " .. category:gsub("^%l", string.upper) .. " Benchmarks")
                table.insert(report, "- Benchmarks: " .. data.benchmarks)
                table.insert(report, "- Average Time: " .. string.format("%.2f", data.avgTime) .. "ms")
                
                -- Add key benchmark details
                if category == "memory" or category == "cpu" or category == "database" then
                    table.insert(report, "")
                    table.insert(report, "#### Key Metrics:")
                    
                    -- Find relevant benchmarks for this category
                    for id, result in pairs(self.results.benchmark.benchmarkResults) do
                        if id:match("^" .. category) then
                            table.insert(report, "- " .. result.name .. ": " .. 
                                string.format("%.2f", result.avgTime) .. "ms avg, " .. 
                                string.format("%.2f", result.minTime) .. "ms min, " .. 
                                string.format("%.2f", result.maxTime) .. "ms max")
                        end
                    end
                end
            end
        end
    end
    
    -- Add certification section
    table.insert(report, "")
    table.insert(report, "## Certification")
    
    -- Calculate overall pass rate
    local overallPass = true
    local validationPass = self.results.validation and self.results.validation.failed == 0
    local stressPass = self.results.stress and self.results.stress.failed == 0
    local verificationPass = self.results.verification and self.results.verification.modulesFailed == 0
    
    if not validationPass or not stressPass or not verificationPass then
        overallPass = false
    end
    
    if overallPass then
        table.insert(report, "")
        table.insert(report, "**CERTIFICATION STATUS: PASSED**")
        table.insert(report, "")
        table.insert(report, "VUI v1.0.0 has passed all tests and is certified for release.")
    else
        table.insert(report, "")
        table.insert(report, "**CERTIFICATION STATUS: NOT CERTIFIED**")
        table.insert(report, "")
        table.insert(report, "VUI requires additional fixes before release. See details above.")
    end
    
    -- Add final summary
    table.insert(report, "")
    table.insert(report, "## Final Summary")
    table.insert(report, "- Validation Tests: " .. (validationPass and "PASSED" or "FAILED"))
    table.insert(report, "- Stress Tests: " .. (stressPass and "PASSED" or "FAILED"))
    table.insert(report, "- Module Verification: " .. (verificationPass and "PASSED" or "FAILED"))
    table.insert(report, "- Performance Benchmarks: Completed (see metrics above)")
    table.insert(report, "")
    table.insert(report, "Report Generated: " .. date("%Y-%m-%d %H:%M:%S"))
    
    -- Save report to variable
    self.report = table.concat(report, "\n")
    
    -- Save report to file
    if VUI_TestReport then
        VUI_TestReport = self.report
    end
    
    -- Also save to VUI_Validation_Test_Report.md if possible
    if VUI.test_report_file then
        VUI.test_report_file:Write(self.report)
    end
    
    -- Print summary
    self:Log("info", "Report", "Test Report Generated")
    
    return self.report
end

-- Register with slash command handler
if VUI.RegisterSlashCommand then
    VUI:RegisterSlashCommand("test", function(input)
        -- Parse options
        local category = nil
        if input and input ~= "" then
            category = input
        end
        
        -- Load required modules
        LoadTestModules()
        
        -- Run tests
        if category then
            if category == "validation" then
                TR:InitResults()
                TR:RunValidation()
            elseif category == "benchmark" then
                TR:InitResults()
                TR:RunBenchmarks()
            elseif category == "verification" then
                TR:InitResults()
                TR:RunVerification()
            elseif category == "stress" then
                TR:InitResults()
                TR:RunStressTests()
            else
                TR:Log("error", "TestRunner", "Unknown test category: " .. category)
            end
        else
            TR:RunAll()
        end
    end, "Run tests. Use '/test validation', '/test benchmark', '/test verification', or '/test stress' for specific tests.")
end

-- Run tests automatically on load if configured
if TR.options.autoRun then
    C_Timer.After(5, function()
        TR:RunAll()
    end)
end

-- Return the test runner
return TR